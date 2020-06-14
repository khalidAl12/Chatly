import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'explore.dart';
import 'inbox.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String myID;
String myName;

Firestore cloud = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class _HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;

  void getCurrentUser() async {
    try {
      final user = await auth.currentUser();
      if (user != null) {
        myID = user.uid;
        var db = await cloud.collection("Users").document(myID).get();
        myName = db.data["username"];
        print(myID);
        print(myName);
      }
    } catch (e) {
      print(e);
    }
  }

  setIsActive() async {
    await cloud.collection("Users").document(myID).updateData({
      "isActive": true,
    });
  }
  setUnActive() async {
    await cloud.collection("Users").document(myID).updateData({
      "isActive": false,
    });
  }
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    getCurrentUser();

    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setUnActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatly"),
        elevation: 0.7,
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          tabs: <Widget>[
            Tab(text: "الصندوق الوارد"),
            Tab(text: "إستكشف"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Inbox(),
          Explore(),
        ],
      ),
    );
  }
}
