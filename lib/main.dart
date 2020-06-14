import 'package:flutter/material.dart';

import 'Pages/login.dart';

/*
  إذا أستفدت من التطبيق لا تنساني من دعوة :)
*/
void main() => runApp(Chatly());

class Chatly extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "F",
      home: Login(),
    );
  }
}
