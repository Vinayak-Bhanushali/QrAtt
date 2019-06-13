import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qratt/constants.dart';
import 'package:qratt/ui/home.dart';
import 'package:qratt/ui/scanner.dart';
import 'package:qratt/ui/viewattendance.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:http/http.dart'as http;
import 'package:qratt/attdata.dart';

class Dashboard extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
     return DashboardState();
  }
}

class DashboardState extends State<Dashboard>{

  String _userName='', _password='', _name ='', _rollno='', _classname='', _percent='';
  
  var formatter = new DateFormat("MMMM '-' yyyy");

  Future<SharedPreferences> _preferences = SharedPreferences.getInstance();

  var attdata = <AttData>[];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  //getting shared pref data and loading in variable
  Future<Null> _getData() async {
    final SharedPreferences prefs = await _preferences;

    String u = prefs.getString("userName");
    String p = prefs.getString("password");
    String n = prefs.getString("name");
    String r = prefs.getString("rollno");
    String c = prefs.getString("classname");

    this.setState(() {
      if(n != null && r != null && c != null) {
        _userName = u;
        _password = p;
        _name = n;
        _rollno = r;
        _classname = c;
      }else {
        _userName = u;
        _password = p;
        _name = 'name';
        _rollno = 'no';
        _classname = 'class';
      }

    });
  }


  Future _validateLogin() async{

    var responseobjectApp = await http.post(Constants.apiLink+"app.php", body: {'username': '$_userName', 'password': '$_password'});
    var responseApp;

    try{
       responseApp= json.decode(responseobjectApp.body);
    }
    catch(e){
      print(e);
    }

    if(responseApp['myheader']['login'] != "Successfull"){
      _logout();
    }else{
      //update Shared Prefrences
      if(_name == 'name' || _rollno == 'no' || _classname == 'class')
      {
        _setData("name",responseApp['myheader']['name']);
        _setData("rollno",responseApp['myheader']['rollno'].toString());
        _setData("classname",responseApp['myheader']['classname']);
        await _getData();
      } 
    }
  }

  void initialize() async{
    await _getData();
    await _validateLogin();
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

  //last 5 attendance
  Future<Map> _getRecentAtt() async{

    //remove previous data
    attdata.clear();
    
    if(_userName != ''){
      //send request  
      var responseobjectPercent = await http.post(Constants.apiLink+"percent.php", body: {'username': '$_userName'});
      var responsePercent;
      try{
        responsePercent = json.decode(responseobjectPercent.body);
      }
      catch(e) {
        return null;
      }

      _percent = responsePercent['myheader']['percent'].toString();

      //add items in map
      for (var i = 0; i < responsePercent.length-1; i++) {
        attdata.add(AttData(responsePercent["$i"]["date"],responsePercent["$i"]["subname"],responsePercent["$i"]["status"]));
      }

      return responsePercent;
    }
    else return null;
  }

  _logout() async {
    final SharedPreferences prefs = await _preferences;
    await prefs.clear();
    print("logout");
  }

  Future<void>_showAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('INFO'),
        content: new Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Name: $_name"),
              Text("User Name: $_userName"),
              Text("Roll No: $_rollno"),
              Text("Class: $_classname"),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {

    TextStyle headingStyle = new TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w700);
    TextStyle cellstyle = new TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500);

    return Scaffold(
      body: new Center(

        child: new FutureBuilder(
          future: _getRecentAtt(), 
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            
            return new Column(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      AppBar(
                        title: new InkWell(
                          onLongPress: (){_showAlert(context);},
                          child: new Text(
                            _name.toUpperCase(),
                            style: new TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        centerTitle: true,
                        elevation: 0,
                        actions: <Widget>[
                         Tooltip(
                           message: "LOGOUT",
                           child:  new FlatButton(
                            child: Icon(Icons.exit_to_app,color: Colors.white70,), 
                            onPressed: () {
                              _logout();
                              Navigator.pushAndRemoveUntil(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => Home()
                                ), 
                                ModalRoute.withName("/Home")
                              );
                            },
                          ),
                         )
                        ],
                      ),

                      SizedBox(height: 20),

                      new Text(
                        formatter.format(DateTime.now()),
                        style: new TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                      ),

                      SizedBox(height: 20),
                      
                      new Text(
                        _percent+"%",
                        style: new TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).accentColor
                        ),
                      )

                    ],
                  ),
                  
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black87,
                ),

                new Container(
                  decoration: new BoxDecoration(color: Colors.white,),
                  padding: EdgeInsets.all(5),
                  child: new Column(
                    children: <Widget>[

                      SizedBox(height: 10),

                      new Text(
                        "RECENT LECTURES",
                        style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.w700),
                      ),

                      new DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text("DATE",style: headingStyle),
                          ),
                          DataColumn(
                            label: Text("SUBJECT",style: headingStyle),
                          ),
                          DataColumn(
                            label: Text("STATUS",style: headingStyle),
                          ),
                        ],
                        rows: attdata.map((att)=>DataRow(
                          cells: [
                            DataCell(
                              Text(att.date,style: cellstyle),
                              showEditIcon: false,
                              placeholder: false
                            ),
                            DataCell(
                              Text(att.subname,style: cellstyle),
                              showEditIcon: false,
                              placeholder: false
                            ),
                            DataCell(
                              Text(att.status,style: cellstyle),
                              showEditIcon: false,
                              placeholder: false
                            ),
                          ]
                        )).toList()    
                        ),

                        SizedBox(height: 10),

                        RaisedButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Viewattendance(username: _userName,)),
                          );
                          },
                          child: Text("View More >>"),
                          padding: const EdgeInsets.all(10.0),
                          color: Color.fromRGBO(34, 34, 34, 0.8),
                          textColor: Colors.white,
                        ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width,
                )
              ],
            ); 
          },
        )
      ),
      floatingActionButton: new FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Scanner(username: _userName,password: _password,)),
            ); 
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}