import React, { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { useHistory } from 'react-router';
import { Button, Table, TableBody, TableCell, TableHead, TableRow, Chip, TextField, InputBase } from '@material-ui/core';
import { Card, Progress, ReturnButton } from '../../../components';
import { useBackend, useSnackbar } from '../../../contexts';
import { Customer, CustomerResponse } from '../../../contexts/backend/Customers';
import { Search } from '@material-ui/icons';
import './NewCustomer.scss';

export default function NewCustomer() {

    //const [customers, setCustomers] = useState<CustomerResponse[]>();

    const snackbar = useSnackbar();
    const { customer } = useBackend();
    //const history = useHistory();


    const tryAddNewCustomer = async (e: React.FormEvent) => {
        e.preventDefault();
        const form = e.target as HTMLFormElement;
        const new_customer = getFormData(form);
    
        const response = await customer.addCustomer(new_customer);
    
        if (!response.name) snackbar.push(`Could not add ${response.name}`);
        else {
          snackbar.push(`Added ${new_customer.name}.`);
          form.reset();
        }
      };

      const getFormData = (form: HTMLFormElement) => {
        const formData = new FormData(form);
        const email = formData.get('email') as string;
        const name = formData.get('name') as string;
        return { email, name };
      };

    return (
        <div className="Customers">
            <div className="customers__top">
                <div className="top">
                    <ReturnButton to="/sales/customers" />
                    <h1 className="title">New Customer</h1>
                </div>
            </div>
            <Card>
                <p className="label">Provide New Customer Information Below</p>
                <div className="customer">
                    <form className="AddCustomerForm" onSubmit={tryAddNewCustomer} autoComplete="off">
                        <div className="AddCustomerForm__input">
                            <input
                                name="name"
                                className="AddCustomerForm__input__name"
                                type="name"
                                placeholder="Name"
                                autoComplete="off"
                                required
                            />
                            <input
                                name="email"
                                className="AddUserForm__input__email"
                                type="email"
                                placeholder="Email"
                                autoComplete="off"
                                required
                            />
                        </div>
                        <Button color="primary" variant="contained" type="submit">
                            Add Customer
                        </Button>
                    </form>
                </div>
            </Card>
        </div>

    );
}
