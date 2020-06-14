import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import '../Controllers/FBController.dart';
import '../Controllers/utils.dart';
import '../Widgets/customHeading.dart';
import 'chat.dart';
import 'home.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  @override
  void initState() {
    FirebaseController.instanace.getUnreadMSGCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("1"),
      onVisibilityChanged: ((visibility) {
        print(visibility.visibleFraction);
        if (visibility.visibleFraction == 1.0) {
          FirebaseController.instanace.getUnreadMSGCount();
        }
      }),
      child: Column(
        children: <Widget>[
          customHeading(title: "الصندوق الوارد"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cloud.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    color: Colors.white.withOpacity(0.7),
                  );
                }
                return ListView(
                  children: snapshot.data.documents.map((data) {
                    if (data['ID'] == myID) return Container();
                      return StreamBuilder<QuerySnapshot>(
                      stream: cloud.collection('Users').document(myID).collection('Messages')
                          .where('chatWith',isEqualTo: data['ID']).snapshots(),
                      builder: (context, chatListSnapshot) {
                        if(chatListSnapshot.data == null){
                          return Container();
                        }else if(chatListSnapshot.data.documents.length == 0 ){
                          return Container();
                        }
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 8.0),
                            Material(
                              child: InkWell(
                                onTap: () {
                                  _moveTochatRoom(
                                    selectedUserID: data["ID"],
                                    selectedUserName: data["username"],
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: new CircleAvatar(
                                        backgroundImage: new NetworkImage(
                                            "https://picsum.photos/200/300"),
                                        radius: 25.0,
                                        child: data["isActive"] != null?Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(color: data["isActive"]?Colors.blue:Colors.red,width: 2,),
                                              borderRadius: BorderRadius.circular(100.0)
                                          ),
                                        ):Container(),
                                      ),
                                      title: new Text(data["username"]),
                                      subtitle: new Text(
                                        chatListSnapshot.data.documents[0]
                                        ['lastChat'],
                                        maxLines: 1,
                                      ),
                                      trailing: StreamBuilder<QuerySnapshot>(
                                        stream: cloud
                                            .collection("ChatRoom")
                                            .document(chatListSnapshot
                                            .data.documents[0]['chatID'])
                                            .collection(chatListSnapshot
                                            .data.documents[0]['chatID'])
                                            .where('idTo', isEqualTo: myID)
                                            .where('isread', isEqualTo: false)
                                            .snapshots(),
                                        builder:
                                            (context, notReadMSGSnapshot) {
                                          return Column(
                                            children: <Widget>[
                                              Text(
                                                (chatListSnapshot.hasData &&
                                                    chatListSnapshot
                                                        .data
                                                        .documents
                                                        .length >
                                                        0)
                                                    ? readTimestamp(
                                                    chatListSnapshot.data
                                                        .documents[0]
                                                    ['timestamp'])
                                                    : '',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                              SizedBox(height: 3.0),
                                              checkReadMSGUI(chatListSnapshot,
                                                  notReadMSGSnapshot),
                                            ],
                                          );
                                        },
                                      ),
                                      isThreeLine: false,
                                    ),
                                    new Container(
                                      height: 0.15,
                                      width: double.infinity,
                                      color: Colors.black26,
                                      margin: EdgeInsets.only(left: 60.0),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList()
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  CircleAvatar checkReadMSGUI(chatListSnapshot, notReadMSGSnapshot) {
    return CircleAvatar(
      radius: 9,
      child: Text(
        (chatListSnapshot.hasData && chatListSnapshot.data.documents.length > 0)
            ? ((notReadMSGSnapshot.hasData &&
                    notReadMSGSnapshot.data.documents.length > 0)
                ? '${notReadMSGSnapshot.data.documents.length}'
                : '')
            : '',
        style: TextStyle(fontSize: 10),
      ),
      backgroundColor: (notReadMSGSnapshot.hasData &&
              notReadMSGSnapshot.data.documents.length > 0 &&
              notReadMSGSnapshot.hasData &&
              notReadMSGSnapshot.data.documents.length > 0)
          ? Colors.red[400]
          : Colors.transparent,
      foregroundColor: Colors.white,
    );
  }
  Future<void> _moveTochatRoom({selectedUserID, selectedUserName}) async {
    try {
      String chatID = makeChatId(myID, selectedUserID);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Chat(myID,myName,selectedUserID,chatID,selectedUserName),
        ),
      );
    } catch (e) {
      print(e.message);
    }
  }
}
