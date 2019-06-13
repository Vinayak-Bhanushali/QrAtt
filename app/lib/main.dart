import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qratt/ui/home.dart';

void main() async{
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(
        new MaterialApp(
          title: 'QrAtt',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(34, 34, 34, 1.0),
            accentColor: Color.fromRGBO(15, 156, 213, 1.0)
          ),
          home: new Home(),
        )
      );
    });
}

