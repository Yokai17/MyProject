import 'package:flutter/material.dart';
import 'package:news/pages/page.dart';

class MyNews extends StatelessWidget {
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
  int id ;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            title: TabBar(
              tabs: [
                Tab(text: 'Бизнес'),
                Tab(text: 'Спорт'),
                Tab(text: 'Технологии'),
                Tab(text: 'Развлечения'),
                Tab(text: 'Наука'),
                Tab(text: 'Здоровье'),
              ],
                isScrollable: true,
            ),
            backgroundColor: Colors.black26,
          ),
          body: TabBarView(
            children: [
              FeedPage(id=1),
              FeedPage(id=2),
              FeedPage(id=3),
              FeedPage(id=4),
              FeedPage(id=5),
              FeedPage(id=6),
            ],
          ),
        ),
      ),
    );
  }
}


