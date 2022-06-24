*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.Windows
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.FileSystem
Library    RPA.Dialogs

*** Variables ***

*** Tasks ***
Do the order
    Open the robot order website
    Ask User Input
    Read excel and make the order 
    Create Zip file


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
Ask User Input
    Add text input    search    label=URL 
    ${response}=    Run dialog
    Download    ${response.search}
Get the orders
    Download    https://robotsparebinindustries.com/orders.csv
Pop up
    Click Button    OK
Read excel and make the order 
    ${orders}=    Read table from CSV    orders.csv    header=True
    FOR    ${orders}    IN    @{orders}
        Set Wait Time    3
        Pop up
        Wait Until Keyword Succeeds
        ...    5x
        ...    3s
        ...    Make the order    ${orders}
    END

TestCase
    Set Wait Time    3
    Pop up
    Select From List By Value    id:head    1
    Select Radio Button    body    2
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input   3
    Input Text    id:address    123
    Click Button    preview
    Wait Until Element Is Visible    id:robot-preview
    Click Button    order
    Wait Until Element Is Visible    id:receipt
    Create PDF and Modify it    1
    Order Another
Make the order
    [Arguments]    ${orders}
    Select From List By Value    id:head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input   ${orders}[Legs]
    Input Text    id:address    ${orders}[Address]
    Click Button    preview
    Wait Until Element Is Visible    id:robot-preview
    Click Button    order
    Wait Until Element Is Visible    id:receipt
    Create PDF and Modify it    ${orders}
    Order Another

Create PDF and Modify it
    [Arguments]    ${orders}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML 
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}recipt${/}${orders}[Order number]-receipt.pdf
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}recipt${/}${orders}[Order number]-receipt.png
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}recipt${/}${orders}[Order number]-receipt.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}recipt${/}${orders}[Order number]-receipt.pdf    true
    Remove File    ${OUTPUT_DIR}${/}recipt${/}${orders}[Order number]-receipt.png    



Order Another
    Wait Until Element Is Visible    id:order-another
    Click Button    order-another
    
Create Zip file
    Archive Folder With Zip  ${CURDIR}${/}recipt  receipts.zip