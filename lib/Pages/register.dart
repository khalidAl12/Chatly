import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'home.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _username;
  String _email;
  String _password;

  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _cloud = Firestore.instance;

  _register(username, email, password) async {
    await _auth
        .createUserWithEmailAndPassword(email: _email, password: _password)
        .then((db) {
      _cloud.collection("Users").document(db.user.uid).setData({
        "username": username,
        "email": email,
        "ID": db.user.uid,
        "isActive": false,
      });
    }).whenComplete(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    });
  }

  bool _call = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _call,
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FlutterLogo(
                      size: 120.0,
                      colors: Colors.teal,
                    ),
                    SizedBox(height: 48.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      onChanged: (val) => _username = val,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ), // icon is 48px widget.
                        ), // icon is 48px widget.
                        hintText: 'أسم المستخدم',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      onChanged: (val) => _email = val,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ), // icon is 48px widget.
                        ), // icon is 48px widget.
                        hintText: 'البريد الإلكتروني',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      obscureText: true,
                      onChanged: (val) => _password = val,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                        ),
                        hintText: 'الرقم السري',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () {
                          setState(()=> _call = true);
                          _register(_username, _email, _password).whenComplete((){
                            setState(()=> _call = false);
                          });

                        },
                        padding: EdgeInsets.all(12),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'إنشاء الحساب',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
