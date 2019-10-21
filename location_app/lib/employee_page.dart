import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location_app/login_page.dart';
import 'package:ntp/ntp.dart';


class EmployeePage extends StatelessWidget {//экран сотрудника

  final int id;
  final String uid;
  EmployeePage({Key key, this.id,this.uid}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Employee(id: id,uid: uid,),
    );
  }
}

class Employee extends StatefulWidget {
  final int id;
  final String uid;
  Employee({Key key, this.id, this.uid}): super(key: key);

  @override
  _EmployeePageState createState() => _EmployeePageState();
}


class _EmployeePageState extends State<Employee>{
  Position _position;
  double _distance;
  BuildContext _scaffoldContext;
  bool WS = true, WSS = false, loc;
  String Cname, url, Latitude, Longitude, r , ti, qti;
  var ListLatitude, ListLongitude, ListR, listTi, lti ,qlistTi ,qlti;
  DateTime startDate, outTime;

  bool WidgetStatus(int a){//вспомогательный метод для управления видимостью объектов
    if (a == 1){
      setState(() {
        WS = true;
        WSS = false;
      });
    }
    else {
      setState(() {
        WS = false;
        WSS = true;
      });
    }
  }

  Future getData() async {//метод для получения данных с БД
    Firestore.instance.collection('companies').where('id_company', isEqualTo: widget.id).snapshots().listen((data)  async {
      setState(() {
        Cname = data.documents[0]['company_name'];//название компании
        url = data.documents[0]['logo'];//лого компании
      });
    }).onError((e) {
      print(e);
    });
  }

  Future gd() async {//метод для получения данных с БД
  QuerySnapshot emp =  await Firestore.instance.collection('employee').where('id_company', isEqualTo: widget.id).where('uid', isEqualTo: widget.uid).getDocuments();
  if (!mounted) return ;
    setState(() {
      if (emp.documents[0]['employee_loc'] == true) {WidgetStatus(2); }else{WidgetStatus(1);}
    });
  }



  @override
  void initState() {//вызов методо при происове экрана
    // TODO: implement initState
    super.initState();
    setState(() {
      getData();
      gd();
    });

  }


  Future<void> _initPlatformState() async {//метод для получения текущего местоположения устройства
    Position position;
    try {
      final Geolocator geolocator = Geolocator()
        ..forceAndroidLocationManager = true;
      position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } on PlatformException {
      position = null;
    }
    if (!mounted) {
      return;
    }

    setState(() {//сохранение позиции устройства
      _position = position;
      print('/////////');
      print(_position);
    });
  }

  Future<void> _onCalculatePressed(double Latitude,double Longitude,double endLatitude,double endLongitude) async {//расчет растояния между двумя географическими координатами
       double startLatitude = Latitude;
       double startLongitude = Longitude;

       double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);

      setState(() {
        _distance = distance;//сохранение результата в переменную
      });

  }

  Future<void> _companyLoc () async{//метод для получения данных о местоположении организации 
    await Firestore.instance.collection('companies').where('id_company', isEqualTo: widget.id).snapshots().listen((data)  async {
      setState(() {//сохранение данных в переменные
        Latitude = data.documents[0]['company_Latitude'];
        Longitude = data.documents[0]['company_Longitude'];
        r = data.documents[0]['company_r'];
      });
      print(Latitude);
      print(Longitude);
      print(r);
    });
  }

  Future<void> _employee_loc(bool q, String d,t,qt) async {//метод для обновления дынных о местоположении сотрудника в БД
    QuerySnapshot employee = await Firestore.instance.collection('employee').where('uid', isEqualTo: widget.uid).getDocuments();
      final DocumentReference postRef = Firestore.instance.collection('employee').document(employee.documents[0].documentID);
      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(postRef);
        if (postSnapshot.exists) {
          await tx.update(postRef,{'employee_loc': q});
          await tx.update(postRef,{'time': t});
          if(q == true){
            await tx.update(postRef, <String, dynamic>{
                'artime': FieldValue.arrayUnion([d +' '+ t])
              });
          }else{
            await tx.update(postRef, <String, dynamic>{
                'qtime': FieldValue.arrayUnion([qt])
              });
          }
        }
      });
  }

  void time() async {     
    startDate = await NTP.now();
    ti = startDate.toString();
     listTi = ti.split('.');
     lti = listTi[0].split(' ');
    setState(() {
      listTi[0]; 
      lti;
    });
    print(listTi[0]);
    //print('NTP DateTime: ${startDate}');
  }

  void outtime() async {     
    outTime = await NTP.now();
    qti = outTime.toString();
     qlistTi = qti.split('.');
    setState(() {
      qlistTi[0]; 
    });
  }



  Future<void> signOut() async {//метод для выхода из аккаунта
    return FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {//построение экрана
    return Scaffold(
      appBar: AppBar(
        title: Text(Cname ?? '',style: TextStyle(color: Colors.white, fontSize: 25.0)),//название компнии в заголовке
        actions: <Widget>[
          // action button
          IconButton(//кнопка для выходи из аккаунта
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              signOut();
              var route = MaterialPageRoute(builder: (BuildContext context) => HomeScreen(),);
              Navigator.pushReplacement(context, route);
            },
          ),],
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child:  Builder(
          builder: (BuildContext context) {
            return  Center(
              child: Column(
                  children:  <Widget>[
                    Container(//логотип компании
                      padding:  EdgeInsets.all(50.0),
                     child: url != null ? Image.network(url) : Container(),
                    ),
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          Text('Подтвердите свое местоположение.',style: TextStyle(color: Colors.black, fontSize: 20.0)),

                          RaisedButton(//кнопка при нажатии на которую вычисляется местоположение сотрудника
                              elevation: 10.0,
                              padding: EdgeInsets.all(40.0),
                              child: Icon(Icons.accessibility, size: 75, color: Colors.green) ,
                              shape: CircleBorder() ,
                              onPressed: () async {
                                await time();
                                await _companyLoc();//вызов метода для получение координат компании
                                await _initPlatformState();//вызов метода для получения координат сотрудника
                                ListLatitude = Latitude.split(',');//координаты берутся с сервера единой стракой, данная строчка разбивает полученные данные на отдельыне части
                                ListLongitude = Longitude.split(',');
                                ListR = (r.split(','));
                                for (var i = 0; i < ListLatitude.length; i++) {//цикл для проверки растояния сотрудника 
                                  await _onCalculatePressed(double.parse(ListLatitude[i]), double.parse(ListLongitude[i]),_position.latitude ,_position.longitude);//расчет растояни от сотрудника до зданий огранизации
                                  if (_distance <= double.parse(ListR[i])){//если сотрудник на територии огранизации, выход из цикала и запись результата в переменную
                                    loc = true;
                                    break;
                                  }else{
                                    loc = false;
                                  }
                                }
                                if (loc == true) {//исходя из результата предыдущей операции всплывает окно с соответсвующим результату текстом 
                                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Вы приыбли на место работы'), backgroundColor: Colors.green,));
                                  _employee_loc(true, lti[0],lti[1],'');//если результат положительный происход внесение данных в БД и изменение сотояния видимости объектов экрана
                                  WidgetStatus(2);
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Вы не прибыли на место работы'), backgroundColor: Colors.red,));
                                }
                              }
                          ),
                        ],
                      ),
                    visible: WS,//состояние видимости
                    ),

                    Visibility(
                      child: Column(
                        children: <Widget>[
                          Center(child: Text('Нажмите на кнопку  если вы ',style: TextStyle(color: Colors.black, fontSize: 17.0)),),
                          Center(child: Text('собираетесь покинуть место работы',style: TextStyle(color: Colors.black, fontSize: 17.0)),),

                          RaisedButton(//кнопка для внесения данных в БД если сотрудник покинул место работы
                              elevation: 15.0,
                              padding: EdgeInsets.all(40.0),
                              child: Icon(Icons.directions_run, size: 50, color: Colors.red) ,
                              shape: CircleBorder() ,
                              onPressed: () async {//при нажатии происход внесение данных в БД и изменение сотояния видимости объектов экрана, а также высплывает окно с соответсвуюшим текстом
                              await outtime();
                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Вы покинули место работы'), backgroundColor: Colors.green,));
                                WidgetStatus(1);
                                _employee_loc(false, '','', qlistTi[0]);
                              }
                          )
                        ],
                      ),
                      visible: WSS,
                    ),
                    Container(padding: EdgeInsets.all(30),)
                  ]),
            );
          }
      ),
        ),
    );
  }

}





