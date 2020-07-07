import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_verification_flutter/HomePage.dart';
class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  String smsCode;
  String verificationCode;
  String number;
  @override
  Widget build(BuildContext context) {
    double width=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 100, 10, 10),
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Text("Enter Your Phone NUmber",
                  style: TextStyle(
                    color: Colors.green[900],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
              TextField(
                obscureText: true,
                onChanged: (val){
                  number=val;
                },
                cursorColor: Colors.green[900],
                style: TextStyle(
                  height: 1,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.green[200],
                  filled: true,
                  prefixIcon: Icon(Icons.phone
                  ,color: Colors.green[900],
                  ),
                  hintText: "Enter Phone Number",
                  hintStyle: TextStyle(
                    color: Colors.green[900],
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: ButtonTheme(
                  height: 50,
                  minWidth: width,
                  child: RaisedButton.icon(
                      onPressed: (){
                        _submit();
                      },
                      icon: Icon(Icons.send,color: Colors.white,),
                      label: Text("Send code"),
                    color: Colors.green[900],
                    textColor: Colors.white,
                    splashColor: Colors.green[800],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _submit() async {
    final PhoneVerificationCompleted verificationSuccess = (AuthCredential credential) {
      setState(() {
        print("Verification");
        print(credential);

      });
    };

    final PhoneVerificationFailed phoneVerificationFailed = (
        AuthException exception) {
      print("${exception.message}");
    };
    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationCode = verId;
      smsCodeDialog(context).then((value) => print("Signed In"));
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {

      this.verificationCode = verId;
    };


    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.number,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationSuccess,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout
    );
  }
  Future<bool> smsCodeDialog(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Enter Code",
            style: TextStyle(
              color: Colors.green[900],
            ),
          ),
          content: TextField(
            onChanged: (Value){
              smsCode=Value;
            },
          ),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            FlatButton(
              child: Text("Verify",
                style: TextStyle(
                  color: Colors.green[900],
                ),
              ),
              onPressed: (){
                FirebaseAuth.instance.currentUser().then((user){
                  if(user!=null){
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                  else{
                    Navigator.of(context).pop();
                    signIn();
                  }
                });
                },
            )
          ],
        );
      }
    );
  }
  signIn() {
    AuthCredential phoneAuthCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationCode, smsCode: smsCode);
    FirebaseAuth.instance.signInWithCredential(phoneAuthCredential)
        .then((user) =>  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    )).catchError((e) => print(e));
  }
}

//run code
