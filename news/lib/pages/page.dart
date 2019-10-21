import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:news/NewsData.dart';

class FeedPage extends StatelessWidget {
  int id;
FeedPage(this.id);
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: new SafeArea(
          child: new Column(
            children: [
              new Expanded(
                flex: 1,
                child: new Container(
                    width: width,
                    color: Colors.white,
                    child: new GestureDetector(
                      child: new FutureBuilder<List<News>>(
                        future: fatchNews(http.Client(),id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? NewsList(news: snapshot.data, )
                              : Center(child: CircularProgressIndicator());
                        },
                      ),
                    )),
              ),
            ],
          )),
    );
  }
}

Future<List<News>> fatchNews(http.Client client, id) async {
  String url;
  switch (id) {
    case 1:
      url = Constant.base_url + "top-headlines?country=ru&category=business&apiKey=" + Constant.key;
      break;
    case 2:
      url = Constant.base_url + "top-headlines?country=ru&category=sports&apiKey=" + Constant.key;
      break;
    case 3:
      url = Constant.base_url + "top-headlines?country=ru&category=technology&apiKey=" + Constant.key;
      break;
    case 4:
      url = Constant.base_url + "top-headlines?country=ru&category=entertainment&apiKey=" + Constant.key;
      break;
    case 5:
      url = Constant.base_url + "top-headlines?country=ru&category=science&apiKey=" + Constant.key;
      break;
    case 6:
      url = Constant.base_url + "top-headlines?country=ru&category=health&apiKey=" + Constant.key;
      break;
  }
  final response = await client.get(url);
  return compute(parsenews, response.body);
}


List<News> parsenews(String responsebody) {
  final parsed = json.decode(responsebody);
  return (parsed["articles"] as List)
      .map<News>((json) => new News.fromJson(json))
      .toList();
}


class NewsList extends StatelessWidget {
  final List<News> news;

  NewsList({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,

      itemBuilder: (context, index) {
        return new Card(
          child: new ListTile(

              title:
              Image.network(
                news[index].urlToImage ?? 'https://www.gaming-jobs.fr/images/template/no-logo.png?1492552080',
                fit: BoxFit.fitWidth,
              ),

              subtitle: Text(news[index].title),
              onTap: (){Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(news[index].title),
                            actions: <Widget>[
                              new IconButton(
                                icon: new Icon(Icons.open_in_browser),
                                tooltip: "Открыть в браузере",
                                onPressed: () async {
                                  if (await canLaunch(news[index].url)) {
                                    await launch(news[index].url);
                                  }
                                },
                              )
                            ],

                          ),
                          body: ListView(
                              children: [
                                Image.network(
                                  news[index].urlToImage ?? 'https://www.gaming-jobs.fr/images/template/no-logo.png?1492552080',
                                  fit: BoxFit.fitWidth,
                                ),

                                Container(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(news[index].title,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0
                                      )
                                  ),
                                ),

                                Container(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                        news[index].description ?? '',
                                      softWrap: true,
                                        style: TextStyle(
                                            fontSize: 16.0
                                        )
                                    )
                                )
                              ]
                          )
                      )
                  )
              );}
          ),
        );
      },
    );
  }
}
