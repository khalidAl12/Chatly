import 'package:flutter/cupertino.dart';

import 'chat.dart';
import 'package:flutter/material.dart';

import '../Controllers/utils.dart';
import '../Widgets/customHeading.dart';
import 'home.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          customHeading(title: "إستكشف المستخدمين"),
          Expanded(
            child: StreamBuilder(
                stream: cloud.collection('Users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        var db = snapshot.data.documents[index];
                        if(db["ID"] == myID) return Container();
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 8.0),
                            Material(
                              child: InkWell(
                                onTap: () {
                                  String chatID = makeChatId(myID, db["ID"]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Chat(
                                        myID,myName,db["ID"],chatID,db["username"]
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: new CircleAvatar(
                                        backgroundImage: new NetworkImage("https://picsum.photos/200/300"),
                                        radius: 25.0,
                                        child: db["isActive"] != null?Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: db["isActive"]?Colors.blue:Colors.red,width: 2,),
                                              borderRadius: BorderRadius.circular(100.0)
                                          ),
                                        ):Container(),
                                      ),
                                      title: new Text(db["username"]),
                                      trailing: Icon(Icons.arrow_right,color: Colors.green),
                                      isThreeLine: false,
                                    ),
                                    new Container(
                                      height: 0.15, width: double.infinity,
                                      color: Colors.black26, margin: EdgeInsets.only(left: 60.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
            ),
          ),
        ],
      ),
    );
  }
}
