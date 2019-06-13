import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:http/http.dart'as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:qratt/ui/home.dart';
import 'package:qratt/constants.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login>{

  final TextEditingController _userController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
              child: Text('Retry'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => Home()
                  ), 
                ModalRoute.withName("/Home")
                );
              },
            ),
          ],
        );
      },
    );

  }

  //validate username and password
  _checkLogin(BuildContext context,String username, String password) async{
    var url = Constants.apiLink+'applogin.php';
    var responseobject = await http.post(url, body: {'username': '$username', 'password': '$password'});
    var response;

    try {
      response = json.decode(responseobject.body);
    } catch (e) {
      _showAlert(context,"Cannot Connect");
      return;
    }

    if(responseobject.statusCode==200)
    {
      if(response['status']=="Successfull"){
        _saveData(username,password);
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(
            builder: (context) => Home()
          ), 
        ModalRoute.withName("/Home")
        );
      }
      else if(response['status']=="error"){
        _showAlert(context,"Invalid Credentials");        
      }
    }else{
      _showAlert(context,"Cannot Connect");
    }
  }

  //Store Data
  _saveData(String u, String p) async{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("userName", u);
      preferences.setString("password", p);
   }

   _launchURL() async {
      String url = Constants.serverUrl+"/reset/forgotpassword.php";
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

  Widget build(BuildContext context) {
    
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 80.0,
        child: Image.asset('images/logoinv.png'),
      ),
    );

    final username = TextFormField(
      controller: _userController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        icon: new Icon(
          Icons.person,
          color: Theme.of(context).primaryColor
        ),
        hintText: 'username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: UnderlineInputBorder()
      ),
    );

    final password = TextFormField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        icon: new Icon(
          Icons.lock,
          color: Theme.of(context).primaryColor
        ),
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: UnderlineInputBorder()
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _scaffoldKey.currentState.showSnackBar(
                      new SnackBar(duration: new Duration(seconds: 30), content:
                      new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Signing-In...")
                        ],
                      ),
                      ));
          _checkLogin(context,_userController.text, _passwordController.text);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).accentColor,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {_launchURL();},
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: false,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 150.0),
            logo,
            SizedBox(height: 100.0),
            username,
            SizedBox(height: 20.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}