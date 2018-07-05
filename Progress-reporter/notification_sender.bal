
function sendTextMessage(string fromMobile, string toMobile, string message) returns boolean {
    var details = twilioClient->sendSms(fromMobile, toMobile, message);
    match details {
        twilio:SmsResponse smsResponse => {
            if (smsResponse.sid != null) {
                log:printDebug("Twilio Connector -> SMS successfully sent to " + toMobile);
                return true;
            }
        }
        twilio:TwilioError err => {
            log:printDebug("Twilio Connector -> SMS failed sent to " + toMobile);
            log:printError(err.message);
        }
    }
    return false;
}