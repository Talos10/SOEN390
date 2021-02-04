import React from 'react';
import { render, screen } from '@testing-library/react';
import { Home } from './components/Home';
import Login from './components/Login';

test('renders title', () => {
  render(<Home />);
  const linkElement = screen.getByText(/Welcome to ERP app frontend/i);
  expect(linkElement).toBeInTheDocument();
});

test('renders login', () => {
  render(<Login />);
  const linkElement = screen.getByText(/Log in/i);
  expect(linkElement).toBeInTheDocument();
});
