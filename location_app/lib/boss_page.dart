import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location_app/login_page.dart';
import 'package:url_launcher/url_launcher.dart';



class BossPage extends StatelessWidget {// экран начальника

  final int id;
  final String uid;
  BossPage({Key key, this.id,this.uid}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      MyPage(id: id,uid: uid,),
    );
  }
}

class MyPage extends StatefulWidget {
  final int id;
  final String uid;
  MyPage({Key key, this.id,this.uid}): super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}


class _MyPageState extends State<MyPage>{
  Future data;
  Future _data;
  String Cname;
  int _currentIndex = 0;

  Future getCname() async {//метод получения названия компании
    Firestore.instance.collection('companies').where('id_company', isEqualTo: widget.id).snapshots().listen((data)  async {
      setState(() {
        Cname = data.documents[0]['company_name'];
      });
    });
  }

  @override
  void initState() {//вызов методов при прорисовки экрана
    // TODO: implement initState
    super.initState();
    setState(() {
      getCname();
    });
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _children = [// список с экранами 
      StrBoss(id: widget.id,uid: widget.uid,),
     // ListEmp(id: widget.id,uid: widget.uid,),
      Elist(id: widget.id,uid: widget.uid,),
    ];

    return Scaffold(
      appBar: AppBar(
        title:
        Text(Cname ?? '',style: TextStyle(color: Colors.white, fontSize: 25.0)),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          // action button
          IconButton(//прорисовка кнопки дял выходы из аккаунта
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              signOut();
              var route = MaterialPageRoute(builder: (BuildContext context) => HomeScreen(),);
              Navigator.pushReplacement(context, route);//метод для перехода на экран входа и удаление сушествующего экрана из памяти устройства
            },
          ),],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(//прорисовка кнопок навигации в приложении
        onTap: onTabTapped,
        currentIndex: _currentIndex, 
        items: [
          BottomNavigationBarItem(//создание иконки и надписи для пункта навигации
            icon: new Icon(Icons.format_align_justify),
            title: new Text('Главная'),
          ),
          BottomNavigationBarItem(//создание иконки и надписи для пункта навигации
            icon: new Icon(Icons.group),
            title: new Text('Персонал'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {//вспомогательный метод для навигации
    setState(() {
      _currentIndex = index;
    });
  }


}

class CastomCircleAvatar extends StatefulWidget {// класс для визуального представления о местоположении сотрудника

  bool value;
  CastomCircleAvatar({this.value});

  @override
  _CastomCircleAvatar createState() => _CastomCircleAvatar();
}

class _CastomCircleAvatar extends State<CastomCircleAvatar> {
  @override
  Widget build(BuildContext context) {
    //return widget.value == true ?  CircleAvatar(backgroundColor: Colors.green ) :// если сотрудник прибыл цвет зеленый иначе красный
    //CircleAvatar(backgroundColor: Colors.red);
    return widget.value == true ? Container(
                            width: 35,
                            height: 35,
                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withGreen(200),
                                  blurRadius: 5.0,
                                ),
                              ]
                            ),
                          )
                          :
                          Container(
                            width: 35,
                            height: 35,
                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withRed(200),
                                  blurRadius: 5.0,
                                ),
                              ]
                            ),
                          );
  }
}



class StrBoss extends StatefulWidget {//стартовый экран начальника с информацией о количестве сотрудников
  final int id;
  final String uid;
  
  StrBoss({Key key, this.id,this.uid}): super(key: key);

  @override
  _StrBossState createState() => _StrBossState();
}

class _StrBossState extends State<StrBoss> {
  String url;
  int emp_on,emp_off;


  Future getEmp() async {//метод для получения общего количества сотрудников и пришедших сотрудников компании
  
    QuerySnapshot getUrl = await Firestore.instance.collection('companies').where('id_company', isEqualTo: widget.id).getDocuments();
    QuerySnapshot employee =  await Firestore.instance.collection('employee').where('id_company', isEqualTo: widget.id).where('position', isEqualTo: 'employee').where('employee_loc', isEqualTo: true ).getDocuments();
    QuerySnapshot emp = await Firestore.instance.collection('employee').where('id_company', isEqualTo: widget.id).where('position', isEqualTo: 'employee').getDocuments();
    
   if (!mounted) return ;
    setState(() {
      emp_on = employee.documents.length;
      url = getUrl.documents[0]['logo'];
      emp_off = emp.documents.length;
      print(emp_off);
    });

  }
  


  @override
  void initState() {//вызов методов при загрузке экрана
    // TODO: implement initState
    super.initState();
    setState(() {
        getEmp();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {//построение экрана с лого компании и количеством сотрудников
  
    return SingleChildScrollView(
      child:
      Center(child:
      Column(children: <Widget>[
        Container (
          padding:  EdgeInsets.all(50.0),
          child:url != null ? Image.network(url) : Container(),//если лого отсутвует рисуется пустое поле
        ),
          Container(
            padding:  EdgeInsets.all(20.0),
            child: Column(children: <Widget>[
              Text('Сотрудников по штату: $emp_off',style: TextStyle(fontSize: 20.0)),//прорисовка текста с количеством сотрудников
              Text('Сотрудников прибыло: $emp_on',style: TextStyle(fontSize: 20.0)),
            ],)
          ),
      ],),
      ),
    ); 
  }
}


class Elist extends StatefulWidget {

   final int id;
  final String uid;
  Elist({Key key, this.id,this.uid}): super(key: key);

  @override
  _ElistState createState() => _ElistState();
}

class _ElistState extends State<Elist> {

Future _data;
  String Dlist;
  var Deplist;
  List<String> arTime;

  Future getDeplist() async {
    QuerySnapshot list = await Firestore.instance.collection('companies').where('id_company', isEqualTo: widget.id).getDocuments();
    setState(()  {
      Dlist =  list.documents[0]['department_list'];
      Deplist = (Dlist.split(','));
    });
    print(Deplist);
  }
  Future getListEmp(String dep) async {//метод для получения дынных о сотрудниках из БД
    var firestore = Firestore.instance;
    QuerySnapshot qn = await  firestore.collection('employee').where('id_company', isEqualTo: widget.id).where('position', isEqualTo: 'employee').where('department', isEqualTo: dep).getDocuments();
    return qn.documents;
  }

  @override
  void initState() {//загрузка данных при прорисовке экрана
    // TODO: implement initState
    super.initState();
    setState(() {
      getDeplist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:RefreshIndicator(child:
      ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  Deplist[index],
                  style:  TextStyle(
                    fontSize: 15.0,
                  ),
                ),
                FutureBuilder(
                  future: getListEmp(Deplist[index]),
                   builder: (_, snapshot){
                     if(snapshot.connectionState == ConnectionState.waiting){//если данные не загруженны 
                       return Center(child:  CircularProgressIndicator(),);//показать индикатор загрузки
                       }else{
                         return Card(child: 
                         ListView.builder(//прорисовка списка сотрудников
                           itemCount: snapshot.data.length,
                           shrinkWrap: true, 
                           physics: ClampingScrollPhysics(),
                           itemBuilder: (_, index){
                             return ListTile(//прорисовка данных сотрудника из списка
                               title: Text(snapshot.data[index].data['fio']),
                               subtitle: Text('Время прибытия: ' + (snapshot.data[index].data['time'] ?? '-')),
                               trailing:  CastomCircleAvatar(value: snapshot.data[index].data['employee_loc']) ,
                               onTap: (){
                                 Navigator.push(//переход на экран с подробной информацией о сотруднике
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) => Scaffold(
                                       appBar: AppBar(
                                         backgroundColor: Colors.blueAccent,
                                         ),
                                        body: ListView(
                                           children: [
                                             Container(
                                               padding: EdgeInsets.all(10.0),
                                               child: Text(snapshot.data[index].data['fio'],
                                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)
                                               ),
                                             ),
                                              Container(
                                                padding: EdgeInsets.all(10.0),
                                                child: Row(children: <Widget>[
                                                  Text('Статус прибытия: ', style: TextStyle(fontSize: 20.0)),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 25),
                                                    child: CastomCircleAvatar(value: snapshot.data[index].data['employee_loc']),
                                                    )
                                                ],)
                                              ),
                                              Container(
                                               padding: const EdgeInsets.all(10.0),
                                               child: Text(
                                                 snapshot.data[index].data['department'],
                                                 softWrap: true,
                                                 style: TextStyle(fontSize: 20.0)
                                               )
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(10.0),
                                                child:Row(children: <Widget>[
                                                  Text('Телефон: ', style: TextStyle(fontSize: 20.0)),
                                                  InkWell(
                                                    child: Text(snapshot.data[index].data['phonenumber'].toString(),style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 20.0),),
                                                    onTap: () => launch("tel://"+ snapshot.data[index].data['phonenumber'].toString()),//метод выполнения вызова на телефон по нажатию на номер
                                                  ),
                                                ],)
                                              ),
                                              Row(children: <Widget>[
                                                Expanded(
                                                  flex: 5,
                                                child: Icon(Icons.trending_up,color: Colors.green,)
                                                ,),
                                                Expanded(
                                                  flex: 5,
                                                child: Icon(Icons.trending_down,color: Colors.red,)
                                                ,)
                                              ],),
                                              
                                              Row(children: <Widget>[
                                                Expanded(
                                                  flex: 5,
                                                child: Card(
                                                  child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: snapshot.data[index].data['artime'].length,
                                                          itemBuilder: (_, ind){
                                                            return Text(snapshot.data[index].data['artime'][ind].toString(),style: TextStyle(fontSize: 18),textAlign:TextAlign.center,);
                                                          }
                                                  ),
                                                )
                                                ,),
                                                
                                                Expanded(
                                                  flex: 5,
                                                  child: Card(
                                                    child: ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: snapshot.data[index].data['qtime'].length,
                                                          itemBuilder: (_, ind){
                                                            return Text(snapshot.data[index].data['qtime'][ind],style: TextStyle(fontSize: 18),textAlign:TextAlign.center,);
                                                          }
                                                    ),
                                                  ),
                                                )
                                              ],
                                              ),
                                           ]
                                        )
                                     )
                                   )
                                 );},
                             );
                           }),);
                       }
                   }),
              ],
            ),
          );
        },
        itemCount: Deplist?.length ?? 0,
      ),
      onRefresh: _Refresh),
    );
  }

  Future<Null> _Refresh() async {// метод для обновления страницы
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      //_data = getListEmp();
    });
    return null;
  }
}



