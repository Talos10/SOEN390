-- Create a local db user in order for the backend to be able to access the data.
drop user if exists 'admin'@'localhost';
create user 'admin'@'localhost' identified by 'admin';
grant all privileges on * . * to 'admin'@'localhost';
ALTER USER 'admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'admin';
flush PRIVILEGES;

drop schema if exists `soen_390_db`;

create schema `soen_390_db`;

USE `soen_390_db`;

-- Table to store the users.
CREATE TABLE `soen_390_db`.`user` (
  `userID` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `role` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `password` CHAR(60) NOT NULL,
  `resetPasswordToken` VARCHAR(60),
  `resetPasswordExpires` BIGINT,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  PRIMARY KEY (`userID`))

  collate = utf8mb4_unicode_ci;

-- Table to store the customers.
CREATE TABLE `soen_390_db`.`customer` (
  `customerId` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `archived` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`customerId`))

  collate = utf8mb4_unicode_ci;

-- Table to store the raw materials, semi-finished goods, and finished goods all
-- under one table.
CREATE TABLE `soen_390_db`.`inventory_good` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NOT NULL,
  `processTime` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `uploadDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `archived` TINYINT(1) NOT NULL DEFAULT 0,
  `cost` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `validItemType`
    CHECK (`type` IN ("raw", "semi-finished", "finished")))
  
  collate = utf8mb4_unicode_ci;

-- Table to store the raw goods (materials) needed to build the semi-finished goods.
CREATE TABLE `soen_390_db`.`raw_good` (
  `id` INT NOT NULL,
  `vendor` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `rawMaterialInventoryItemIDForeignKey`
    FOREIGN KEY (`id`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
  
  collate = utf8mb4_unicode_ci;

-- Table to store the semi-finished goods needed to build the finished goods.
CREATE TABLE `soen_390_db`.`semi-finished_good` (
  `id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `semiFinishedInventoryItemIDForeignKey`
    FOREIGN KEY (`id`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
  
  collate = utf8mb4_unicode_ci;

-- Table to store the finished goods that will be sold to the customers.
CREATE TABLE `soen_390_db`.`finished_good` (
  `id` INT NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `finishedInventoryItemIDForeignKey`
    FOREIGN KEY (`id`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
  
  collate = utf8mb4_unicode_ci;

-- Table to store the various properties of the inventory items.
CREATE TABLE `soen_390_db`.`property_of_good` (
  `compositeId` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `value` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`compositeId`, `name`),
  CONSTRAINT `inventoryItemIDPropertyForeignKey`
    FOREIGN KEY (`compositeId`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
    
	collate = utf8mb4_unicode_ci;

CREATE TABLE `soen_390_db`.`composition_of_good` (
  `compositeId` INT NOT NULL,
  `componentId` INT NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`compositeId`, `componentId`),
  CONSTRAINT `inventoryItemIDComposedOfForeignKey`
    FOREIGN KEY (`compositeId`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `madeFromInventoryItemIDComposedOfForeignKey`
    FOREIGN KEY (`componentId`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `notMadeFromSameItem`
    CHECK (`compositeId` != `componentId`))
    
	collate = utf8mb4_unicode_ci;

-- Table to store the different orders given by the manufacturing division
-- in order to buy raw goods and to create semi-finished and finished goods.
CREATE TABLE `soen_390_db`.`manufacturing_order` (
  `orderId` INT NOT NULL AUTO_INCREMENT,
  `status` VARCHAR(45) NOT NULL,
  `totalCost` DECIMAL(10,2) NOT NULL,
  `creationDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `startDate` DATETIME,
  `estimatedEndDate` DATETIME,
  `completionDate` DATETIME,
  PRIMARY KEY (`orderId`),
  CONSTRAINT `validItemStatus`
  CHECK (`status` IN ("confirmed", "cancelled", "processing", "completed")))
  
  collate = utf8mb4_unicode_ci;

-- Table to store the bought raw goods and to store the various semi-finished goods that
-- the manufacturing division has given an order to produce for each manufacturing order.
CREATE TABLE `soen_390_db`.`manufacturing_ordered_good` (
  `orderId` INT NOT NULL,
  `compositeId` INT NOT NULL,
  `totalCost` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`orderId`, `compositeId`),
  CONSTRAINT `manufacturingOrderIDForeignKey`
    FOREIGN KEY (`orderId`)
    REFERENCES `soen_390_db`.`manufacturing_order` (`orderId`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `orderedGoodInventoryItemIDForeignKey`
    FOREIGN KEY (`compositeId`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
    
	collate = utf8mb4_unicode_ci;

-- Table to store the different orders of finished goods put in by customers.
CREATE TABLE `soen_390_db`.`customer_order` (
  `orderId` INT NOT NULL AUTO_INCREMENT,
  `customerId` INT NOT NULL,
  `status` VARCHAR(45) NOT NULL,
  `totalPrice` DECIMAL(10,2) NOT NULL,
  `creationDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completionDate` DATETIME,
  PRIMARY KEY (`orderId`),
  CONSTRAINT `customerIdForeignKey`
    FOREIGN KEY (`customerId`)
    REFERENCES `soen_390_db`.`customer` (`customerId`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `validItemStatusCustomerOrder`
  CHECK (`status` IN ("confirmed", "cancelled", "completed")))
  
  collate = utf8mb4_unicode_ci;

-- Table to store events
CREATE TABLE `soen_390_db`.`event` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date` DATE NOT NULL,
  `time` TIME NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`))

	collate = utf8mb4_unicode_ci;

-- Table to store goals
CREATE TABLE `soen_390_db`.`goal` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `completed` BOOLEAN NOT NULL,
  `targetDate` DATE NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`))
               
  collate = utf8mb4_unicode_ci;

-- date is of the format yyyy-mm-dd and the price can be given with a maximum of two digits after the dot.


-- Table to store the various finished goods that are associated with each customer order.
CREATE TABLE `soen_390_db`.`customer_ordered_good` (
  `orderId` INT NOT NULL,
  `compositeId` INT NOT NULL,
  `totalPrice` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`orderId`, `compositeId`),
  CONSTRAINT `customerOrderIDForeignKey`
    FOREIGN KEY (`orderId`)
    REFERENCES `soen_390_db`.`customer_order` (`orderId`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `ordersInventoryItemIDForeignKey`
    FOREIGN KEY (`compositeId`)
    REFERENCES `soen_390_db`.`inventory_good` (`id`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
    
	collate = utf8mb4_unicode_ci;

-- date is of the format yyyy-mm-dd and the price can be given with a maximum of two digits after the dot.

INSERT `customer` (`name`, `email`) 
VALUES
("Francois Legault", "legault@govt.qc.ca"),
("Jackie Chan", "chan@hotmail.com"),
("Pauline Marois", "marois@outlook.com")
;

INSERT `inventory_good` (`name`, `type`, `quantity`, `processTime`, `cost`) 
VALUES
("carbon fiber", "raw", 5, 1440, 5),
("steel", "raw", 10, 1440, 10.5),
("rubber", "raw", 7, 1440, 15.5),
("leather", "raw", 5, 720, 20.5),
("titanum dioxide", "raw", 5, 800, 30.5),
("ethylene glycol", "raw", 5, 30, 40.5),
("alkyd", "raw", 7, 5, 50.5),
("paint", "semi-finished", 4, 10, 55.5),
("bike seat", "semi-finished", 2, 60, 32.23),
("carbon frame", "semi-finished", 3, 24, 34.43),
("rubber tire", "semi-finished", 4, 365, 24.23),
("steel wheel frame", "semi-finished", 4, 10, 25.25),
("steel bike handles", "semi-finished", 2, 40, 26.25),
("bike gears", "semi-finished", 3, 400, 24.52),
("steel breaks", "semi-finished", 2, 100, 251.21),
("le sebastien", "finished", 2, 2000, 21.24)
;

INSERT `raw_good` (`id`, `vendor`) 
VALUES
(1, "Maxon Factory"),
(2, "Steelworks Laval"),
(3, "Rubber.co"),
(4, "Tanning Frank"),
(5, "Chemical Facility Quebec"),
(6, "Chemical Facility Quebec"),
(7, "Chemical Facility Quebec")
;

INSERT `semi-finished_good` (`id`) 
VALUES
(8),
(9),
(10),
(11),
(12),
(13),
(14),
(15)
;

INSERT `finished_good` (`id`, `price`) 
VALUES
(16, 1245.99)
;

INSERT `manufacturing_order` (`status`, `creationDate`, `totalCost`) 
VALUES
("processing", '2015-05-10 13:17:17', 55.55),
("processing", '2015-05-10 13:17:17', 55.60)
;

INSERT `manufacturing_order` (`status`, `creationDate`, `totalCost`, `completionDate`) 
VALUES
("completed", '2015-05-10 13:17:17', 55.76, NOW())
;

INSERT `customer_order` (`customerId`, `status`, `creationDate`, `totalPrice`) 
VALUES
(1, "confirmed", '2015-05-10 13:17:17', 1245.99),
(2, "cancelled", '2015-05-10 13:17:17', 0)
;

INSERT `customer_order` (`customerId`, `status`, `creationDate`, `totalPrice`, `completionDate`) 
VALUES
(3, "completed", '2015-05-10 13:17:17', 2491.98, NOW())
;

INSERT `composition_of_good` (`compositeId`, `componentId`, `quantity`)
VALUES
(8, 5, 1),
(8, 6, 1),
(8, 7, 1),
(9, 2, 1),
(9, 4, 1),
(10, 1, 2),
(11, 3, 2),
(12, 2, 1),
(13, 2, 1),
(14, 2, 2),
(15, 2, 1),
(16, 8, 1),
(16, 9, 1),
(16, 10, 1),
(16, 11, 2),
(16, 12, 2),
(16, 13, 2),
(16, 14, 1),
(16, 15, 2)
;

INSERT `manufacturing_ordered_good` (`orderId`, `compositeId`, `quantity`, `totalCost`)
VALUES
(1, 16, 1, 20.55),
(2, 1, 1, 25.10),
(2, 2, 1, 21.23),
(2, 3, 1, 22.14),
(3, 11, 1, 25.66)
;

INSERT `customer_ordered_good` (`orderId`, `compositeId`, `quantity`, `totalPrice`)
VALUES
(1, 16, 1, 1245.99),
(3, 16, 1, 2491.98)
;

INSERT `property_of_good` (`compositeId`, `name`, `value`)
VALUES
(4, "leather quality", "full-grain"),
(8, "color", "red"),
(10, "size", "18"),
(14, "number of speeds", "12"),
(16, "finish", "chrome"),
(16, "color", "red"),
(16, "number of speeds", "12")
;

INSERT `event` (`date`, `time`, `title`)
VALUES
("2021-02-17", "10:00:00", "Bruno's birthday celebration"),
("2021-03-29", "12:30:00", "Lunch and Learn"),
("2021-03-30", "11:00:00", "CEO company wide meeting"),
("2021-04-01", "11:00:00", "Easter chocolate bunny giveaway"),
("2021-05-07", "11:00:00", "Meeting with vendors for new raw materials")
;

INSERT `goal` (`completed`, `targetDate`, `title`)
VALUES
(TRUE, "2021-04-10", "Build 2000 bikes"),
(FALSE, "2021-05-05", "Make $200 000 of profit"),
(FALSE, "2021-12-01", "Sell 1000 bikes")
;

-- run the line below by itself if you want to delete the adminuser from your sql db:
-- drop user if exists 'admin'@'localhost';

-- https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql
