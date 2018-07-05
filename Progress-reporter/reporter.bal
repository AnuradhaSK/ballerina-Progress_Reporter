import ballerina/config;
import ballerina/log;
import ballerina/io;
import wso2/gsheets4;
import wso2/gmail;
import wso2/twilio;

string accessToken = config:getAsString("ACCESS_TOKEN");
string clientId = config:getAsString("CLIENT_ID");
string clientSecret = config:getAsString("CLIENT_SECRET");
string refreshToken = config:getAsString("REFRESH_TOKEN");
string spreadsheetId = config:getAsString("SPREADSHEET_ID");
string sheetName = config:getAsString("SHEET_NAME");
string senderEmail = config:getAsString("SENDER");
string userId = config:getAsString("USER_ID");
string phone_from = config:getAsString("TWILIO_FROM_MOBILE");
string msg= config:getAsString("TWILIO_MESSAGE");

endpoint gsheets4:Client spreadsheetClient {
    clientConfig: {
        auth: {
            accessToken: accessToken,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    }
};

endpoint gmail:Client gmailClient {
    clientConfig: {
        auth: {
            accessToken: accessToken,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    }
};

endpoint twilio:Client twilioClient {
    accountSId: config:getAsString("TWILIO_ACCOUNT_SID"),
    authToken: config:getAsString("TWILIO_AUTH_TOKEN")

};
string[] averages=[];
function main(string... args) {
    sendNotification();

}



function sendNotification() {
    //Retrieve the students' details from spreadsheet.

    string[][] values = getStudentDetailsFromGSheet();
    string[] coulmns=["B","C","D","E"];
    int j=0;
    foreach column in coulmns {
        averages[j]=calculateAverage(column);
        j+=1;
    }


    int i = 0;
    //Iterate through each student details and send customized email.
    foreach value in values {
        //Skip the first row as it contains header values.
        if (i > 0) {
            float total=0;
            string phone="+";
            string name = value[0];

            string maths = value[1];
            string physics = value[2];
            string chemistry = value[3];
            string english = value[4];

            string email= value[5];
            phone= phone+value[6];
            total=total+strintToFloat(maths)+strintToFloat(physics)+strintToFloat(chemistry)+strintToFloat(english);

            var tot=  <string>total;

            string subject = "Progress Report of "+name;

            sendMail(email, subject, getReportEmailTemplate(name,maths,physics,chemistry,english,tot));
            boolean isSent=sendTextMessage(phone_from,phone,name+"'s "+msg);
        }
        i = i + 1;
    }
}

function strintToFloat(string str) returns(float){
    float result=0;
    var intValue = <float>str;
    match intValue {
        float value => result = value;
        error err => io:println("error: " + err.message);
    }
    return result;

}


function getStudentDetailsFromGSheet() returns (string[][]) {
    //Read all the values from the sheet.
    string[][] values = check spreadsheetClient->getSheetValues(spreadsheetId, sheetName, "", "");
    log:printInfo("Retrieved student details from spreadsheet id:" + spreadsheetId + " ;sheet name: "
            + sheetName);
    return values;
}


function getReportEmailTemplate(string name, string maths, string physics,string chemistry, string english,string total) returns (string) {
    string emailTemplate =

"
<head>
<h2> "+name+"'s Report Card </h2>


    <style>
    html {
    font-family:arial;
    font-size: 18px;
    }

    td {
    border: 1px solid #726E6D;
    padding: 15px;
    }

    thead{
    font-weight:bold;
    text-align:center;
    background: #625D5D;
    color:white;
    }

    table {
    border-collapse: collapse;
    }

    .footer {
    text-align:right;
    font-weight:bold;
    }

    tbody >tr:nth-child(odd) {
    background: #D1D0CE;
    }

    </style>
     <body>
     <table>
    <thead>
      <tr>
        <td colspan='2'>Subject </td>

        <td colspan='2'> Grade </td>
        <td colspan='2'> Class Average </td>
      </tr>
      <tr>

        <td colspan='2'>  </td>
        <td> Mark </td>
        <td> Letter </td>
        <td colspan='2'>  </td>
      </tr>
    </thead>
    <tbody>
      <tr>

        <td colspan='2'>Mathematics</td>
        <td>"+maths+"</td>
        <td> "+gradeGenerator(maths)+"</td>
        <td>"+averages[0]+"</td>
      </tr>
      <tr>

        <td colspan='2'>Physics</td>

        <td> "+physics+" </td>
        <td> "+gradeGenerator(physics)+"</td>
         <td>"+averages[1]+"</td>
      </tr>
      <tr>

        <td colspan='2'>Chemistry</td>
        <td> "+chemistry+" </td>
        <td> "+gradeGenerator(chemistry)+"</td>
         <td>"+averages[2]+"</td>
      </tr>
      <tr>

        <td colspan='2'>English</td>

        <td>"+english+"</td>
        <td> "+gradeGenerator(english)+"</td>
         <td>"+averages[3]+"</td>
      </tr>

    </tbody>
    <tfoot>
      <tr>
        <td colspan='2' class='footer'>Total</td>
        <td colspan='3'>"+total+"</td>
      </tr>
      <tr>
        <td colspan='2' class='footer'>Average</td>
        <td colspan='3'>"+<string>(strintToFloat(total)/4)+" </td>
      </tr>
  </table>";


        emailTemplate = emailTemplate + "<p> If you have any questions regarding " + name+
        "'s report, please contact us</p>
</body>
        ";
    return emailTemplate;
}


function sendMail(string customerEmail, string subject, string messageBody) {
    //Create html message
    gmail:MessageRequest messageRequest;
    messageRequest.recipient = customerEmail;
    messageRequest.sender = senderEmail;
    messageRequest.subject = subject;
    messageRequest.messageBody = messageBody;
    messageRequest.contentType = gmail:TEXT_HTML;

    //Send mail
    var sendMessageResponse = gmailClient->sendMessage(userId, untaint messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            log:printInfo("Sent email to " + customerEmail + " with message Id: " + messageId + " and thread Id:"
                    + threadId);
        }
        gmail:GmailError e => log:printInfo(e.message);
    }
}




function gradeGenerator(string result) returns (string){
    float intResult=strintToFloat(result);
    string grade;
    if(85<=intResult && intResult<=100){
        grade="A+";
    }
    else if(75<=intResult && intResult<85){
        grade="A";
    }
    else if(65<=intResult && intResult<75){
        grade="B+";
    }
    else if(55<=intResult && intResult<65){
        grade="B";
    }
    else if(35<=intResult && intResult<55){
        grade="C";
    }
    else{
        grade="F";
    }

    return grade;
}

function  calculateAverage(string column) returns (string){
    float average=0;
    float subTotal=0;
    string[] marks = check spreadsheetClient-> getColumnData(spreadsheetId, sheetName,column);
    int k=0;
    foreach m in marks{
        if(k>0){
            subTotal=subTotal+strintToFloat(m);
        }
        k+=1;
    }
    average=subTotal/(lengthof marks-1);
    return <string>average;

}