import 'dart:async';
import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qratt/constants.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart'as http;
import 'package:qratt/ui/friend.dart';

class Scanner extends StatefulWidget {
  final username,password;
  Scanner({Key key, @required this.username, @required this.password}) : super(key: key);
  @override
  _ScannerState createState() => _ScannerState(username,password);
}

class _ScannerState extends State<Scanner> {

  //get vars from previous activity
  String _userName,_password;
  _ScannerState(this._userName,this._password);
  
  String barcode = "";
  String attUrl = "";
  bool error = false;

  String _udid = "", _ipad = "";

  bool attendanceMarked = false;
  String errorMsg = 'Please Scan Code';

  @override
  initState() {
    super.initState();
    operations();
  }

   //Alert Dialog
  Future<void> _showAlert(BuildContext context,String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ERROR'),
          content: new Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                 Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  

  Future _scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      if(barcode.startsWith(Constants.serverUrl)){
        setState(() { 
          this.barcode = barcode;
          attUrl = barcode;
        });
      }
      else {
        setState(() { 
          this.barcode = barcode;
          attUrl = "";
          _showAlert(context,"Invalid Qr Code");
          error = true;
        });

      }      
    } on PlatformException catch (e) {
      error = true;
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = "Camera access was denied. Please enable Camera permission from your device settings";
          _showAlert(context,this.barcode.toString());
        });
      } else {
        setState(() {
          this.barcode = 'Unknown error: $e';
          _showAlert(context,this.barcode.toString());
        });
      }
    } on FormatException{
      setState(() {
        this.barcode = 'No Qr Code Found';
        _showAlert(context,this.barcode.toString());
      });
    } catch (e) {
      this.barcode = 'Unknown error: $e';
      _showAlert(context,this.barcode.toString());
    }
  }

  Future _loadparas() async{

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    setState(() {
      _udid = androidInfo.androidId;
      _ipad = "111";
    });
  }

  Future _makeRequest() async{

    var responseobjectApp = await http.post(attUrl, body: {'username': '$_userName', 'password': '$_password', 'uid': '$_udid', 'ipad': '$_ipad'});
    var responseApp;

    try {
      responseApp = json.decode(responseobjectApp.body);
    } catch (e) {
        error = true;
       _showAlert(context, "Code Expired. Please try Again");
    }

    if(!error) {
      switch (responseApp['status']) {
        case "success":
          errorMsg = "Success";
          setState(() {
            attendanceMarked = true; 
          });
          break;
        case "error":
          errorMsg = "Something went wrong";
          setState(() {
            attendanceMarked = false; 
          });
          break;
        case "blocked":
          errorMsg = "Your account is blocked. Please contact respective administrator";
          setState(() {
            attendanceMarked = false; 
          });          
          break;
        case "creds":
          errorMsg = "Invalid Creds";
          setState(() {
            attendanceMarked = false; 
          });   
          break;
        case "over":
          errorMsg ="The respective attendance for the code scanned is already completed";
          setState(() {
            attendanceMarked = false; 
          });   
          break;
        default:
           errorMsg = "Invalid Operation";
          setState(() {
            attendanceMarked = false; 
          });   
      }
      
    }
  }

  void operations() async{
    await _scan();
    await _loadparas();
    if(attUrl != ""){
      await _makeRequest();
    }
  }

  Widget buildfeedback(BuildContext context){
    if (attendanceMarked) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.check_circle,size: 200.0, color: Colors.green,),
          SizedBox(height: 150),
          Text("Attendance Marked Successfully!",textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 100),
          Container(
            height: 50,
            width: 200,
            child: FlatButton.icon(
              icon: Icon(Icons.dashboard), 
              label: Text("DASHBOARD"), 
              color: Theme.of(context).primaryColor, 
              textColor: Colors.white70, 
              splashColor: Theme.of(context).accentColor,
              onPressed: () {Navigator.of(context).pop();},
            )
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            width: 200,
            child: FlatButton.icon(
              icon: Icon(Icons.person_pin), 
              label: Text("HELP A FRIEND"), 
              color: Theme.of(context).primaryColor, 
              textColor: Colors.white70, 
              splashColor: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Friend(uid: _udid, ipad: _ipad)),
                );
              },
            )
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error,size: 200.0, color: Colors.red,),
          SizedBox(height: 150),
          Text(errorMsg, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 100),
          Container(
            height: 50,
            width: 200,
            child: FlatButton.icon(
              icon: Icon(Icons.dashboard), 
              label: Text("DASHBOARD"), 
              color: Theme.of(context).primaryColor, 
              textColor: Colors.white70, 
              splashColor: Theme.of(context).accentColor,
              onPressed: () {Navigator.of(context).pop();},
            )
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            width: 200,
            child: FlatButton.icon(
              icon: Icon(Icons.replay), 
              label: Text("RETRY"), 
              color: Theme.of(context).primaryColor, 
              textColor: Colors.white70, 
              splashColor: Theme.of(context).accentColor,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scanner(username: _userName,password: _password,)),
                ); 
                },
            )
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildfeedback(context),
      )
    );
  }
}