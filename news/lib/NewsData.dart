class News {
  String name;
  String title;
  String description;
  String url;
  String urlToImage;

  News({this.name, this.title, this.description, this.url, this.urlToImage});

 // final List<News> results;

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      name: json['source']['name'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      urlToImage: json['urlToImage'] as String,
      url: json['url'] as String,
    );
  }
}


class CCData{
  String name;
  String symbole;
  int rank;
  double price;

  CCData({this.name, this.symbole, this.rank, this.price});
}

class CBData{
  String name;
  String symbole;

  double price;

  CBData({this.name, this.symbole, this.price});
}

class Constant{
  static String base_url ="https://newsapi.org/v2/";
  static String key = "e63a2696de1c4fc69a9f8f5515f88a54";
}