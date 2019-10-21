/* Copyright 2019 Osnovin Egor

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: 
      MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

List<String> aa = ['0','1'];
String Rnum = ' ';
String img = 'assets/images/coin.png';

void getNum (){
  setState(() {
   Rnum =  aa[Random().nextInt(aa.length)];
  });
}

AnimationController controller;
  Animation flip_anim;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 3000), vsync: this);

    flip_anim = Tween(begin: 0.0, end: 10.0).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 0.5, curve: Curves.easeInOutQuart)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget child) {
              return Column(children: <Widget>[
                Container(padding: EdgeInsets.all(60),),

                Text("I'll win ??", style: TextStyle(fontSize: 20),),

                Center(
                  child:
                InkWell(
                  onTap: ()  async {
                   getNum();
                   await controller.forward();
                   if (Rnum == '1') {
                     img = 'assets/images/coinyes.png';
                     Scaffold.of(context).showSnackBar(SnackBar(content: Text('YES'),backgroundColor: Colors.green));
                     }
                   else if (Rnum == '0' ) {
                     img = 'assets/images/coinno.png';
                     Scaffold.of(context).showSnackBar(SnackBar(content: Text('NO'),backgroundColor: Colors.red,));
                     }
                   controller.reset();
                  },
                  child: Container(
                    height: 300.0,
                    width: 300.0,
                    child: Transform(
                      transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.005)
                      ..rotateY(2 * pi * flip_anim.value),
                      alignment: Alignment.center,
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        child: RotationTransition(
                          turns: flip_anim,
                           child:  
                           Image.asset(img),
                        )
                      ),
                    ),
                  ),
                ),
              ),

              ],);
            }
      )
    );
  }
}

