import 'dart:async';
import 'dart:io';
import 'package:chatly/Widgets/Bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controllers/utils.dart';
import '../Widgets/customTextField.dart';
import 'home.dart';

class Chat extends StatefulWidget {
  Chat(this.myID, this.myName, this.selectedUserID, this.chatID,
      this.selectedUserName);

  final String myID;
  final String myName;
  final String selectedUserID;
  final String chatID;
  final String selectedUserName;

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String messageType = 'text';

  final TextEditingController _msgTextController = new TextEditingController();

  Future<void> _getUnreadMSGCount() async {
    try {
      int unReadMSGCount = 0;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String myId = (prefs.get('userId') ?? 'NoId');

      final QuerySnapshot chatListResult = await cloud
          .collection('Users')
          .document(myId)
          .collection('Messages')
          .getDocuments();

      final List<DocumentSnapshot> chatListDocuments = chatListResult.documents;
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await cloud
            .collection('ChatRoom')
            .document(data['chatID'])
            .collection(data['chatID'])
            .where('idTo', isEqualTo: myId)
            .where('isread', isEqualTo: false)
            .getDocuments();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.documents;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }

      print('unread MSG count is $unReadMSGCount');
      FlutterAppBadger.updateBadgeCount(unReadMSGCount);
    } catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade50,
        elevation: 0.9,
        title: widget.selectedUserName == null || widget.selectedUserName == ""
            ? ""
            : Text(widget.selectedUserName,
                style: TextStyle(color: Colors.green)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.green,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: Colors.green,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: VisibilityDetector(
        key: Key("1"),
        onVisibilityChanged: ((visibility) {
          print(visibility.visibleFraction);
          if (visibility.visibleFraction == 1.0) {
            _getUnreadMSGCount();
          }
        }),
        child: StreamBuilder<QuerySnapshot>(
          stream: cloud
              .collection('ChatRoom')
              .document(widget.chatID)
              .collection(widget.chatID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            if (snapshot.hasData) {
              _getUnreadMSGCount();
              for (var data in snapshot.data.documents) {
                if (data['idTo'] == widget.myID) {
                  cloud.runTransaction((Transaction myTransaction) async {
                    await myTransaction
                        .update(data.reference, {'isread': true});
                  });
                }
              }
            }
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                      reverse: true,
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(4.0, 10, 4, 10),
                      children: snapshot.data.documents.reversed.map((data) {
                        return data['idFrom'] == widget.selectedUserID
                            ? Bubble(
                                time: returnTimeStamp(data['timestamp']),
                                delivered: data['isread'],
                                message: data['content'],
                                type: data['type'],
                                isMe: true,
                              )
                            : Bubble(
                                time: returnTimeStamp(data['timestamp']),
                                delivered: data['isread'],
                                message: data['content'],
                                type: data['type'],
                                isMe: false,
                              );
                      }).toList()),
                ),
                customTextField(
                   sendText: () {
                        setState(()=> messageType = 'text');
                        _handleSubmitted(_msgTextController.text);
                        _msgTextController.clear();
                      },
                   sendImage: ()async{
                        // ignore: deprecated_member_use
                        File imageFileFromLibrary = await ImagePicker.pickImage(source:ImageSource.gallery);
                        if(imageFileFromLibrary != null){
                          setState(()=> messageType = "image");
                          _saveUserImageToFirebaseStorage(imageFileFromLibrary);
                        }else{
                          _showDialog('حدث خطأ ما');
                        }
                      },
                   msgTextController: _msgTextController,
                 ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    try {
      cloud
          .collection('ChatRoom')
          .document(widget.chatID)
          .collection(widget.chatID)
          .document(DateTime.now().millisecondsSinceEpoch.toString())
          .setData({
        'idFrom': widget.myID,
        'idTo': widget.selectedUserID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'content': text,
        'type': messageType,
        'isread': false,
      });

      _updateChatRequestField(widget.selectedUserID, text);
      _updateChatRequestField(widget.myID, text);
    } catch (e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
  }

  Future<void> _saveUserImageToFirebaseStorage(image) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();

      String filePath = 'chatrooms/${widget.chatID}/$imageTimeStamp';
      final StorageReference storageReference =
          FirebaseStorage().ref().child(filePath);
      final StorageUploadTask uploadTask = storageReference.putFile(image);

      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        _saveImageToChatRoom(downloadUrl);
      }, onError: (err) {
        print(err.message);
        _showDialog('حدث خطأ عند رفع الصورة');
      });
    } catch (e) {
      print(e.message);
      _showDialog('حدث خطأ ما');
    }
  }

  Future<void> _saveImageToChatRoom(downloadUrl) async {
    try {
      cloud
          .collection('ChatRoom')
          .document(widget.chatID)
          .collection(widget.chatID)
          .document(DateTime.now().millisecondsSinceEpoch.toString())
          .setData({
        'idFrom': widget.myID,
        'idTo': widget.selectedUserID,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'content': downloadUrl,
        'type': messageType,
        'isread': false,
      });

      _updateChatRequestField(widget.selectedUserID, '(صورة)');
      _updateChatRequestField(widget.myID, '(صورة)');
    } catch (e) {
      print(e.message);
      _showDialog('عذراً حدث خطأ');
    }
  }

  Future _updateChatRequestField(String documentID, String lastMessage) async {
    cloud
        .collection('Users')
        .document(documentID)
        .collection('Messages')
        .document(widget.chatID)
        .setData({
      'chatID': widget.chatID,
      'chatWith':
          documentID == widget.myID ? widget.selectedUserID : widget.myID,
      'lastChat': lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  _showDialog(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
          );
        });
  }
}
