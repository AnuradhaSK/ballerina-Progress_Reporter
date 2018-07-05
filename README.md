
# Progress Reporter
# Gmail- Google Sheets- Twilio Integration

[Google Sheets](https://www.google.com/sheets/about/) is an online spreadsheet that lets users create and format 
spreadsheets and simultaneously work with other people. 
[Gmail](https://www.google.com/gmail/) is a free, web-based 
e-mail service provided by Google.
 [Twilio](https://www.twilio.com/) is a cloud communications platform for building SMS, Voice, and Messaging applications on an API built for global scale.

## What is Progress Reporter

This project uses Ballerina API connectors, such as spreadsheet API connector, gmail API connector and Twilio API connector. The scenario can be used to understand how we Spreadsheet connector to get 
data from a Google Sheet and send those data in an email using Gmail connector and send SMS to mobiles inorder to notify the sent email. 

The real world use case scenario of a Educational Institute:
At the end of a semster, the teacher wants to send students' progress reports to their parents. Thus, it is comfortable and matches with today's technology to send the progree report via email. However, people will miss their mails due to tight schedules. Thus, sending a notification regarding the sent mail is useful.


![sample-mailed progress report](https://lh3.googleusercontent.com/iPQ7HGqsqhFctawnglzYn_V9UXLS1XZrUS17-TkXwOnZXHpkjVg1L2wJsk5kSVfLVJSCRFPq1XzP)
                 

![diagram](https://lh3.googleusercontent.com/9Y_xZ3NeriRb_wi7ymVoTAuPIAineKB3-cbaybKdBcAo6d4JWoARkPsHTVOSRwWv4FUL5dg3grls)


Ballerina Google Spreadsheet connector to read the spreadsheet, iterate through the rows and pick 
up the student name, parent's email address,   parent's mobile number and marks of each subject from the columns. Then subjects' class average can be calculated by reading the data through columns.
Then,  Gmail connector is used to add the body of a html mail template and send the email to the relevant sudent's parent. At the same time a notification is sent to the parent through Twilio connector.


