-- create a user
CREATE USER 'robotuser'@'localhost' IDENTIFIED BY 'Password';
DROP USER 'robotuser'@'localhost';

-- create role
CREATE ROLE robotrole;
DROP ROLE robotrole;

-- Give role right to the user
GRANT robotrole TO 'robotuser'@'localhost';

-- Set roles to be enabled by default for the user when logging in
SET DEFAULT ROLE ALL TO 'robotuser'@'localhost';

-- Grant permission to a role in the desired database
USE rpacourse;
GRANT SELECT, INSERT, UPDATE ON invoiceheader TO robotrole;
GRANT SELECT, INSERT, UPDATE ON invoicerow TO robotrole;
GRANT SELECT ON invoicestatus TO robotrole;