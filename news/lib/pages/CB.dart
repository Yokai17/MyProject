import 'package:flutter/material.dart';
import 'package:news/NewsData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CBList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return CBListState();
  }
}

class CBListState extends State<CBList>{
  List<CBData> data;
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
//        onPressed: () => _loadCB(),
//      ),
    );
  }

  _loadCB() async{
    final response = await http.get('https://www.cbr-xml-daily.ru/daily_json.js');
    if (response.statusCode == 200) {
      var allData = (json.decode(response.body) as Map)['Valute'] as Map<String,dynamic>;
      var cbDataList = List<CBData>();
      allData.forEach((String key, dynamic val){
        var record = CBData(name: val['Name'],symbole: val['CharCode'],
            price: val['Value']);

        cbDataList.add(record);
      });
      setState(() {
        data = cbDataList;
      });
    }
  }

  List<Widget> _buildList (){
    return data.map((CBData f)=> ListTile(
      title: Text(f.symbole),
      trailing: Text('${f.price.toStringAsFixed(2)}\RUB'),
    )).toList();
  }
  @override
  void initState(){
    super.initState();
    _loadCB();
  }

}