*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Library    validationcode.py
Resource    authentication.robot

*** Variables ***
@{ListToDB}
${InvoiceNumber}    empty

*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}


*** Keywords ***
Add Row Data to List
    [Arguments]    ${items}

    @{AddInvoiceRowData}    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}


*** Keywords ***
Add Invoice Header To DB
    [Arguments]    ${items}    ${rows}
    Make Connection    ${dbname}

    # Set dateformat
    ${invoiecDate}    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

    # Invoice status variable
    ${invoiceStatus}    Set Variable    0
    ${invoiceComment}    Set Variable    'All okay'

    # Validate reference number
    ${refStatus}    Is Reference Number Correct    ${items}[2]

    IF    not ${refStatus}
        ${invoiceStatus}    Set Variable    1
        ${invoiceComment}    Set Variable    'Reference number error'
    END

    # Validate IBAN number
    ${ibanStatus}    Check IBAN    ${items}[6]

    IF    not ${ibanStatus}
        ${invoiceStatus}    Set Variable    2
        ${invoiceComment}    Set Variable    'IBAN number error'
    END

    # Validate IBAN number
    ${sumStatus}    Check Amounts From Invoice    ${items}[9]    ${rows}

    IF    not ${sumStatus}
        ${invoiceStatus}    Set Variable    2
        ${invoiceComment}    Set Variable    'Amount difference'
    END

    ${foreignKeyChecks0}    Set Variable    SET FOREIGN_KEY_CHECKS=0;

    ${insertStmt}    Set Variable    INSERT INTO InvoiceHeader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, InvoiceStatus_id, comments) VALUES ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${invoiecDate}', '${dueDate}', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', ${invoiceStatus} , ${invoiceComment});

    ${foreignKeyChecks1}    Set Variable    SET FOREIGN_KEY_CHECKS=1;

    Execute Sql String    ${foreignKeyChecks0}
    Execute Sql String    ${insertStmt}
    Execute Sql String    ${foreignKeyChecks1}


*** Keywords ***
Check Amounts From Invoice
    [Arguments]    ${totalSumFromHeader}    ${invoiceRows}
    ${status}    Set Variable    ${False}
    ${totalAmountFromRows}    Evaluate    0

    FOR    ${element}    IN    @{invoiceRows}
        ${totalAmountFromRows}    Evaluate    ${totalAmountFromRows} + ${element}[8]
        
    END
    
    ${diff}    Convert To Number    0.01
    ${totalSumFromHeader}    Convert To Number    ${totalSumFromHeader}
    ${totalAmountFromRows}    Convert To Number    ${totalAmountFromRows}
    ${status}    Is Equal    ${totalSumFromHeader}    ${totalAmountFromRows}    ${diff}


    [Return]    ${status}



*** Keywords ***
Check IBAN 
    [Arguments]    ${iban}
    ${iban}    Remove String    ${iban}    ${SPACE}
    ${status}    Set Variable    ${False}
    # Log To Console    ${iban}

    ${length}    Get Length    ${iban} 

    IF    ${length} == 18
        ${status}    Set Variable    ${True}
    END   
    [Return]    ${status}

*** Keywords ***
Add invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}

    
    ${foreignKeyChecks0}    Set Variable    SET FOREIGN_KEY_CHECKS=0;

    ${insertStmt}    Set Variable    INSERT INTO InvoiceRow (invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, vat, total) VALUES ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]', '${items}[7]', '${items}[8]');

    ${foreignKeyChecks1}    Set Variable    SET FOREIGN_KEY_CHECKS=1;

    Execute Sql String    ${insertStmt}
    Execute Sql String    ${foreignKeyChecks0}
    Execute Sql String    ${foreignKeyChecks1}

*** Test Cases ***
Read CSV file to list
    Make Connection    ${dbname}
    ${outputHeader}    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}    Get File    ${PATH}InvoiceRowData.csv

    Log    ${outputHeader}
    Log    ${outputRows}
    
    # Process each row as a separate element?? 
    @{headers}    Split String    ${outputHeader}    \n
    @{rows}    Split String    ${outputRows}    \n 
    
    # Remove the first Header line and the last empty line
    ${length}    Get Length    ${headers}
    ${length}    Evaluate    ${length}-1
    ${index}    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}
    
    # Remove from the rows
    ${length}    Get Length    ${rows}
    ${length}    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}

    FOR    ${element}    IN    @{headers}
        Log    ${element}
        
    END

    FOR    ${element}    IN    @{rows}
        Log    ${element}
            
    END

    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

*** Test Cases ***
Loop through all invoicerows
    
    # Loop through all invoice rows
     FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        # Place each row into its own element
        @{items}    Split String    ${element}    ,
        

        # Get invoice number of row
        ${rowInvoiceNumber}    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}

        #Check if the invoiceNumber bring processed changes
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Adding rows to the invoice

            # Add the details of the invoice to be processed into the list
            Add Row Data to List    ${items}
        
        ELSE
            Log    We need to check if there are already rows in the database list
            ${length}    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    First invoice case

                # Update invoice number
                ${InvoiceNumber}    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Add the details of the invoice to be processed into the list
                Add Row Data to List    ${items}
            ELSE
                Log    The invoice has changed, the header data must also be processed

                # Find invoice Header row 
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}    Split String    ${headerElement}    ,
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    Invoice found

                        # Validations when adding

                        # Insert invoice header into the database
                        Add Invoice Header To DB    ${headerItems}    ${ListToDB}

                        # Insert the invoice rows into the database
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add invoice Row To DB    ${rowElement}
                            
                        END

                    END
                    
                END
                

                # Selection process for the next invoice
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}
                
                # Add the details of the invoice to be processed into the list
                Add Row Data to List    ${items}
            END
            
        END
        
    END


    # Last invoice instance
    ${length}    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Header processing of the last invoice 
        
        # Find invoice Header row 
        FOR    ${headerElement}    IN    @{headers}
            ${headerItems}    Split String    ${headerElement}    ,
            IF    '${headerItems}[0]' == '${InvoiceNumber}'
                Log    Invoice found

                # Validations when adding

                # Insert invoice header into the database
                Add Invoice Header To DB    ${headerItems}    ${ListToDB}

                # Insert the invoice rows into the database
                FOR    ${rowElement}    IN    @{ListToDB}
                    Add invoice Row To DB    ${rowElement}
                    
                END

            END
            
        END
    END