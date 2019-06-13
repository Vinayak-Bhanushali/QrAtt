import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qratt/ui/dashboard.dart';
import 'package:qratt/ui/login.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
  
}

class HomeState extends State<Home> {
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

   Future _loadSavedData() async{
     SharedPreferences preferences = await SharedPreferences.getInstance();
     setState(() {
       if(preferences.getString("userName")!=null && preferences.getString("userName").isNotEmpty)
       { 
        _userName = preferences.getString("userName");
       }else{
         _userName = "empty";
       }
     });
   }

  @override
  Widget build(BuildContext context) {
    if(_userName != "empty"){
      return new Dashboard();
    }else{
      return new Login();
    }
  }
}