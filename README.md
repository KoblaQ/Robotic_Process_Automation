# Invoice Automation Project
---
## Overview
This project aims to automate the handling of PDF invoices for [Company Name], an organization operating in the [Industry]. The objective is to streamline the process of verifying and approving invoices received from various suppliers, including both electronic and paper formats.

The current operating model involves scanning paper invoices into PDF files and storing them in a designated directory for processing. While automation already exists for managing electronic invoices, paper invoices present challenges that need to be addressed.

## Project Objectives
#### Automate PDF Invoice Handling:
Develop a solution to read PDF invoices from the designated directory into a MySQL database.
#### Verify Invoice Accuracy: 
Validate the correctness of IBAN number, reference number, and line item amounts against the total amount.
### Implement Error Handling: 
Include a "Status" column in the database to indicate invoice errors and a "Comments" column for noting any findings.
### Integration with Approval Process:
Ensure compatibility with another process within the organization to send invoices for relevant approvals.
## Project Components
### UiPath Process: 
Responsible for extracting data from PDF invoices into a temporary CSV structure in a standardized format.
### Robot Framework Process:

Handles validation of CSV file data, tests for accuracy, and writes invoice details into the MySQL database.
## Usage
To utilize this automation solution, follow these steps:

>- Ensure proper setup of the UiPath and Robot Framework environments.
>- Run the UiPath process to extract data from PDF invoices and generate CSV files.
>- Execute the Robot Framework process to validate CSV data, perform accuracy checks, and write invoice details to the MySQL database.
>- Monitor the database for invoice errors and review any findings in the "Comments" column.
>- Integrate the invoice approval process with the automated solution for seamless workflow management.
