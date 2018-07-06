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
string[] subjects;
int[] index;


function main(string... args) {
    sendEmail_Notification();
}

//Iterate through each student details and send customized email and notification
function sendEmail_Notification() {
    //Retrieve the students' details from spreadsheet.
    string[][] values = getStudentDetailsFromGSheet();

    //calculate class average of each subject
    string[] coulmns=["D","E","F","G"];
    int j=0;
    foreach column in coulmns {
        averages[j]=calculateAverage(column);
        j+=1;
    }

    int i = 0;
    foreach value in values {
        if (i==0) {
            int subIndex=0;
            int n=0;
            //Iterate through the header and find subject names
            foreach sub in value{
                //skip student name, parent's email and mobile number fields
                if (subIndex>2 && sub!=null){
                    subjects[n]=value[subIndex];
                    n+=1;
                }
                subIndex+=1;
            }
        }

        //Skip the first row as it contains header values.
        else if (i > 0) {
            float total=0;
            string[] studentMarks;
            string phone="+";
            string name = value[0];
            string email= value[1];
            phone= phone+value[2];
            //get subject marks
            int x=0;
            int pointer=0;
            foreach sMark in value{
                if(pointer>=lengthof subjects){
                    break;
                }
                if(x>2){
                    studentMarks[pointer]=sMark;
                    pointer+=1;
                }
                x+=1;
            }
            io:println(studentMarks);

            // get the total of a student
            foreach mark in studentMarks{
                total+=strintToFloat(mark);
            }

            var tot=  <string>total;
            string subject = "Progress Report of "+name;

            index=0...(lengthof (subjects)-1);
            //send an email
            sendMail(email, subject, getReportEmailTemplate(name,studentMarks,tot));
            //send a notification
            boolean isSent=sendTextMessage(phone_from,phone,name+"'s "+msg);
        }
        i = i + 1;
    }
}

//convert string to floats
function strintToFloat(string str) returns(float){
    float result=0;
    var intValue = <float>str;
    match intValue {
        float value => result = value;
        error err => io:println("error: " + err.message);
    }
    return result;

}

//Read all values from the sheet.
function getStudentDetailsFromGSheet() returns (string[][]) {
    string[][] values = check spreadsheetClient->getSheetValues(spreadsheetId, sheetName, "", "");
    log:printInfo("Retrieved student details from spreadsheet id:" + spreadsheetId + " ;sheet name: "
            + sheetName);
    return values;
}


function getReportEmailTemplate(string name, string[] marks,string total) returns (string) {
    string template =
        "<head>
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
        <td colspan='2'>"+subjects[0]+"</td>
        <td>"+marks[0]+"</td>
        <td> "+gradeGenerator(marks[0])+"</td>
        <td>"+averages[0]+"</td>
        </tr>

        <tr>
        <td colspan='2'>"+subjects[1]+"</td>
        <td>"+marks[1]+"</td>
        <td> "+gradeGenerator(marks[1])+"</td>
        <td>"+averages[1]+"</td>
        </tr>

        <tr>
        <td colspan='2'>"+subjects[2]+"</td>
        <td>"+marks[2]+"</td>
        <td> "+gradeGenerator(marks[2])+"</td>
        <td>"+averages[2]+"</td>
        </tr>

        <tr>
        <td colspan='2'>"+subjects[3]+"</td>
        <td>"+marks[3]+"</td>
        <td> "+gradeGenerator(marks[3])+"</td>
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
        </table>

        <p> If you have any questions regarding " + name+
        "'s report, please contact us</p>
        </body>";

    return template;
}

//generate the corresponding letter to the mark
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

//read column data of subjects and return the average
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