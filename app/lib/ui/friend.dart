import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:http/http.dart'as http;

import 'package:qratt/constants.dart';


class Friend extends StatefulWidget {
  final uid,ipad;
  Friend({Key key, @required this.uid, @required this.ipad}) : super(key: key);

  @override
  _FriendState createState() => _FriendState(uid,ipad);
}

class _FriendState extends State<Friend> {
  String _udid, _ipad;
  String _fusername = 'recent', _fpass;

  _FriendState(this._udid,this._ipad);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _userController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<Null> _getData() async {
    final SharedPreferences prefs = await _preferences;
    String _u = prefs.getString("fname");
    String _p = prefs.getString("fpass");
    this.setState(() {
      if(_u != null && _u.isNotEmpty ){
        _fusername = _u;
        _fpass = _p;
      }
    });
  }

  //add new value to shared prefs
  Future<Null> _setData(String key, String val)  async  {
    final SharedPreferences prefs = await _preferences;
    if (this.mounted){
      setState(() {
        prefs.setString(key,val);
      });
    }
  }

   //Alert Dialog
  Future<void> _showAlert(BuildContext context,String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('RESPONSE'),
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

  //validate username and password
  _checkLogin(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey,String username, String password) async{
    var url = Constants.apiLink+'help.php';
    var responseobject = await http.post(url, body: {'fusername': '$username', 'fpass': '$password', 'imei': '$_udid', 'ipaddr': '$_ipad'});
    var response;
    try {
      response = json.decode(responseobject.body);
      _scaffoldKey.currentState.removeCurrentSnackBar();
    } 
    catch (e) {
      _showAlert(context,"Soemthing Went Wrong");
      _scaffoldKey.currentState.removeCurrentSnackBar();
      return;
    }
    if(responseobject.statusCode==200)
    {
      _showAlert(context,response['message']); 
      if(response['message'] == "Successfull"){
        _setData("fname",username);
        _setData("fpass",password);
      }       
    }else{
      _showAlert(context,"Cannot Connect");
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Icon(Icons.person_pin, color: Theme.of(context).primaryColor, size: 150,),
      ),
    );

    final recent = FlatButton.icon(
      icon: Icon(Icons.person_add), 
      label: Text(_fusername), 
      onPressed: () {
        _scaffoldKey.currentState.showSnackBar(
                      new SnackBar(duration: new Duration(seconds: 30), content:
                      new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("  Connecting...")
                        ],
                      ),
                      ));
        _checkLogin(context,_scaffoldKey,_fusername,_fpass);
      },

    );

    final username = TextFormField(
      controller: _userController,
      keyboardType: TextInputType.text,
      autofocus: true,
      decoration: InputDecoration(
        icon: new Icon(
          Icons.person,
          color: Theme.of(context).primaryColor
        ),
        hintText: 'Username',
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
                          new Text("  Connecting...")
                        ],
                      ),
                      ));
          _checkLogin(context,_scaffoldKey,_userController.text, _passwordController.text);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).accentColor,
        child: Text('SUBMIT', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Help A Friend"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ListView(
          shrinkWrap: false,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 150.0),
            logo,
            SizedBox(height: 100.0),
            recent,
            SizedBox(height: 20.0),
            username,
            SizedBox(height: 20.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          ],
        ),
      ),
    );
  }
}