import 'dart:convert';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:qratt/constants.dart';
import 'package:http/http.dart'as http;
import 'package:qratt/attdata.dart';

class Viewattendance extends StatefulWidget{
  final username;
  Viewattendance({Key key, @required this.username}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ViewattendanceState(username);
  }
}

class ViewattendanceState extends State{
  String _userName;

  ViewattendanceState(this._userName);
  
  static var formatter = new DateFormat('yyyy-MM-dd');
  static final today = DateTime.now();
  static String _startDate = formatter.format(DateTime(today.year,today.month,01));
  static String _endDate = formatter.format(DateTime.now());
  
  String selected;


  var attdata = <AttData>[];
  
  

  Future _selectDate(int id) async {
    DateTime iniDate ;
    if(id == 01){
      iniDate = DateTime.parse(_startDate);
    }else if(id == 02){
      iniDate = DateTime.parse(_endDate);
    }
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: iniDate,
        firstDate: new DateTime(2018),
        lastDate: new DateTime.now()
    );
    
    if(picked != null && id == 01) {
      selected = formatter.format(picked);
      setState(() {
        _startDate = selected;
      });
    }

    if(picked != null && id == 02) {
      selected = formatter.format(picked);
      setState(() {
        _endDate = selected;
      });
    }
    
  }

   //get attendance
  Future<Map> _getAtt() async{

    //remove previous data
    attdata.clear();
    
    if(_userName != ''){

      //send request  
      var responseobjectAtt = await http.post(Constants.apiLink+"detail.php", body: {'username': '$_userName', 'sdate': '$_startDate', 'edate': '$_endDate'});
      var responseAtt;
      try{
        responseAtt = json.decode(responseobjectAtt.body);
      }
      
      catch(e) {
        return null;
      }

      if(responseAtt['myheader']['response'] == true){

        //add items in map
        for (var i = 0; i < responseAtt.length-1; i++) {
          attdata.add(AttData(responseAtt["$i"]["date"],responseAtt["$i"]["subname"],responseAtt["$i"]["status"]));
        }
        return responseAtt;
      }
      else return null;
    }
    else return null;
  }

  @override
  Widget build(BuildContext context) {

    TextStyle headingStyle = new TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w700);
    TextStyle cellstyle = new TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500);

    Widget _percentText(int val){
      Color col;
      if (val <=25) {
        col = Colors.red;
      }else if (val > 25 && val < 75) {
        col = Colors.blue;
      }else if (val >= 75) {
        col = Colors.green;
      }
      return Text(
        val.toString()+"%",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 75, fontWeight: FontWeight.w600,color: col),
        
      );
    }

    return new Scaffold(
      appBar: AppBar(
        title: Text("My Attendance"),
        elevation: 0,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: FutureBuilder(
                future: _getAtt(), 
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //if no data is available
                  if(snapshot.data == null){
                    return  Center(
                        child: Text("No Data...")
                    );
                  }
                  else{
                    return new Expanded(
                        child: ListView(
                          shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(25.0),
                                child: _percentText(snapshot.data['myheader']['percent']),
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
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
                                  )
                              )
                            ]
                        ),
                      );
                  }
                }
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  new Column(
                    children: <Widget>[
                      Text("Start Date",style: TextStyle(color: Colors.white70),),
                      new RaisedButton(
                        color: Color.fromRGBO(15, 156, 213, 0.9),
                        onPressed: () {_selectDate(01);}, 
                        child: new Text(_startDate, style: TextStyle(color: Colors.white)),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      )
                    ],
                  ),

                  SizedBox(width: 70),
                  
                  new Column(
                    children: <Widget>[
                      Text("End Date",style: TextStyle(color: Colors.white70),),
                      new RaisedButton(
                        color: Color.fromRGBO(15, 156, 213, 0.9),
                        onPressed: () {_selectDate(02);}, 
                        child: new Text(_endDate, style: TextStyle(color: Colors.white)),
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                      )
                    ],
                  ),
  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}