
# Progress Reporter
# Gmail-Google Sheets-Twilio Integration

## What is Progress Reporter

This project uses Ballerina API connectors, such as spreadsheet API connector, gmail API connector and Twilio API connecotr. The scenario can be used to understand how we use spreadsheet connector to get 
data from a Google Sheet, then send those data in an email using Gmail connector and send SMS to mobiles inorder to notify the sent email. 

The real world use case scenario of a Educational Institute:
At the end of a semster/year, the teacher/institute's admin  wants to send students' progress reports to thier parents. Thus, it is comfortable and matches with today's technology to send the progress report via email. However, people will miss their mails due to tight schedules. Thus, sending a notification regarding the sent mail is useful.

The format of progress report which is sent via email.
![sample-mailed progress report](https://lh3.googleusercontent.com/iPQ7HGqsqhFctawnglzYn_V9UXLS1XZrUS17-TkXwOnZXHpkjVg1L2wJsk5kSVfLVJSCRFPq1XzP)
                 
The following diagram illustrates the interation and integration of connectors and APIs.
![diagram](https://lh3.googleusercontent.com/9Y_xZ3NeriRb_wi7ymVoTAuPIAineKB3-cbaybKdBcAo6d4JWoARkPsHTVOSRwWv4FUL5dg3grls)

Template of Google Spreadsheet which is used for this application.
![spread sheet](https://lh3.googleusercontent.com/DZAS1nnSMOAqwXn_ZsaWXkFJrU03suD30NixsCyxGVZ7ZUHx8oGFJT2UyY59u_fgKH8u5zFA2Vsv "spreadsheet")

You must configure the `ballerina.conf` configuration file with the tokens, credentials and 
  other important parameters as follows.
  ```
  ACCESS_TOKEN="access token"
  CLIENT_ID="client id"
  CLIENT_SECRET="client secret"
  REFRESH_TOKEN="refresh token"
  SPREADSHEET_ID="spreadsheet id you have extracted from the sheet url"
  SHEET_NAME="sheet name of your Goolgle Sheet."
  SENDER="email address of the sender"
  USER_ID="mail address of the authorized user."

TWILIO_ACCOUNT_SID="Twilio account sid"  
TWILIO_AUTH_TOKEN=""auth token  
TWILIO_FROM_MOBILE="mobile number which is used to send messages"  
TWILIO_MESSAGE="customized message"
  ```
Ballerina Google Spreadsheet connector to read the spreadsheet, iterate through the rows and pick 
up the student name, parent's email address,   parent's mobile number and marks of each subject from the columns. Then subjects' class average can be calculated by reading the data through columns.
Then,  Gmail connector is used to add the body of a html mail template and send the email to the relevant sudent's parent. At the same time a notification is sent to the parent through Twilio connctor.

