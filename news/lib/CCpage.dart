import 'package:flutter/material.dart';
import 'package:news/pages/CC.dart';
import 'package:news/pages/CB.dart';


class MyCourse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TabBarNews(),
    );
  }
}

class TabBarNews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: TabBar(
              tabs: [
                Tab(text: 'Криптовалюты'),
                Tab(text: 'Валюты'),
              ],
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            children: [
              CCList(),
              CBList(),
            ],
          ),
        ),
      ),
    );
  }
}