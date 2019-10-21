import 'package:flutter/material.dart';
import 'package:news/NewsData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CCList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {

    return CCListState();
  }
}

class CCListState extends State<CCList>{
  List<CCData> data;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: new ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildList()[index];
        },
      ),
//      floatingActionButton: FloatingActionButton(child: Icon(Icons.refresh),
//        onPressed: () => _loadCC(),
//      ),
    );

  }

  _loadCC() async{
    final response = await http.get('https://api.coinmarketcap.com/v2/ticker/?limit=10');
    if (response.statusCode == 200) {
      var allData = (json.decode(response.body) as Map)['data'] as Map<String,dynamic>;
      var ccDataList = List<CCData>();
      allData.forEach((String key, dynamic val){
        var record = CCData(name: val['name'],symbole: val['symbol'],rank: val['rank'],
            price: val['quotes']['USD']['price']);

        ccDataList.add(record);
      });
      setState(() {
        data = ccDataList;

      });
    }

  }

  List<Widget> _buildList (){

    return data.map<ListTile>((CCData f)=>
        ListTile(
          subtitle: Text(f.symbole),
          title: Text(f.name),
          leading: CircleAvatar(child: Text(f.rank.toString()),),
          trailing: Text('\$${f.price.toStringAsFixed(2)}'),
        )).toList();
  }
  @override
  void initState(){
    super.initState();
    _loadCC();
  }

}