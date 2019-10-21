import 'package:flutter/material.dart';
import 'package:location_app/employee_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location_app/boss_page.dart';
import 'package:fluttertoast/fluttertoast.dart';



class login_page extends StatelessWidget {//экран входа в учетную запись
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:auth()
    );
  }
}

class auth extends StatefulWidget {
  @override
  _authState createState() => _authState();
}

class _authState extends State<auth> {
  String _uid;
  String _role;
  int _company;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child:  CircularProgressIndicator(),);
          } else {
            if (snapshot.hasData) {
              _uid = snapshot.data.uid; 
              Firestore.instance.collection('employee').where('uid', isEqualTo: _uid).snapshots().listen((data)  async {
                _role = data.documents[0]['position'];//сохраняем в переменную роль пользователя и id его организации
                _company = data.documents[0]['id_company'];
                if (_role == 'boss') {//если роль начальника перенаправление на соответсующий экран
                var route = MaterialPageRoute(builder: (BuildContext context) => BossPage(id: _company,uid: _uid,),);
                Navigator.pushReplacement(context, route);
                }else {//иначе перенапрвление на экран сотрудника
                var route = MaterialPageRoute(builder: (BuildContext context) => EmployeePage(id: _company, uid: _uid),);
                Navigator.pushReplacement(context, route);
                }
              }); 
            }
            return HomeScreen();
          }
      }
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  String _uid;
  String _role;
  int _company;

  @override
  Widget build(BuildContext context) {//построение экрана авторизации
    return Scaffold(
      body:
      Center(
        child: SingleChildScrollView(
      child:
        Form(
          key: this._formKey,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Авторизация пользователя'),
                SizedBox(height: 15.0),
                TextField(//поле для вода логина
                    decoration: InputDecoration(hintText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    }),
                TextField(//поле для ввода пароля
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Password'),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    }),
                RaisedButton(// кнопка для обработки введенных данных и входа в учетную запись
                    elevation: 5.0,
                    shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    child: Text('Вход'),color: Colors.blue, textColor: Colors.white,
                    onPressed: () {
                      if (_email == null || _password == null ){//если поля пустые вывести соотвествующее сообщение
                        Fluttertoast.showToast(
                            msg: "Поля не должны быть пустыми",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 2,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }else{
                        FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password).then((FirebaseUser user) {// если поля непустые проверяем сузествование пользователя с такими данными
                          _uid = user.uid;//если такой пользователь существует мы берм его id и на его основе составляем запрос к БД
                          Firestore.instance.collection('employee').where('uid', isEqualTo: _uid).snapshots().listen((data)  async {
                            _role = data.documents[0]['position'];//сохраняем в переменную роль пользователя и id его организации
                            _company = data.documents[0]['id_company'];
                            if (_role == 'boss') {//если роль начальника перенаправление на соответсующий экран
                              var route = MaterialPageRoute(builder: (BuildContext context) => BossPage(id: _company,uid: _uid,),);
                              Navigator.pushReplacement(context, route);
                            }
                            else {//иначе перенапрвление на экран сотрудника
                              var route = MaterialPageRoute(builder: (BuildContext context) => EmployeePage(id: _company, uid: _uid),);
                              Navigator.pushReplacement(context, route);
                            }
                          });
                        }).catchError((e) {//если веденные данные неверны вывести соответсующее сообщение
                          Fluttertoast.showToast(
                              msg: "Неверный логин или пароль",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                          print(e);
                        });
                      }
                    }
                ),
              ],
            ),
          ),
        ),
        )
      ),
    );
  }
}

