import 'package:flutter/material.dart';
import 'package:location_app/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//void main() => runApp(MyApp());
void main() async {
  final Firestore firestore = Firestore();
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: login_page(),
    );
  }
}

