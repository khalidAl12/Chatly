import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseController {
  static FirebaseController get instanace => FirebaseController();

  // ignore: missing_return
  Future<String> sendImageToUserInChatRoom(imgFile, chatID) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'chatrooms/$chatID/$imageTimeStamp';
      final StorageReference storageReference =
          FirebaseStorage().ref().child(filePath);
      final StorageUploadTask uploadTask = storageReference.putFile(imgFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String result = await storageTaskSnapshot.ref.getDownloadURL();
      return result;
    } catch (e) {
      print(e.message);
    }
  }

  // ignore: missing_return
  Future<int> getUnreadMSGCount([String peerUserID]) async {
    try {
      int unReadMSGCount = 0;
      String targetID = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();

      peerUserID == null
          ? targetID = (prefs.get('userId') ?? 'NoId')
          : targetID = peerUserID;
      final QuerySnapshot chatListResult = await Firestore.instance
          .collection('Users')
          .document(targetID)
          .collection('Messages')
          .getDocuments();
      final List<DocumentSnapshot> chatListDocuments = chatListResult.documents;
      for (var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await Firestore.instance
            .collection('ChatRoom')
            .document(data['chatID'])
            .collection(data['chatID'])
            .where('idTo', isEqualTo: targetID)
            .where('isread', isEqualTo: false)
            .getDocuments();

        final List<DocumentSnapshot> unReadMSGDocuments =
            unReadMSGDocument.documents;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }
      print('unread MSG count is $unReadMSGCount');
      if (peerUserID == null) {
        FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        return null;
      } else {
        return unReadMSGCount;
      }
    } catch (e) {
      print(e.message);
    }
  }

  Future updateChatRequestField(String documentID,String lastMessage,chatID,myID,selectedUserID) async {
    await Firestore.instance
        .collection('Users')
        .document(documentID)
        .collection('Messages')
        .document(chatID)
        .setData({
      'chatID': chatID,
      'chatWith': documentID == myID ? selectedUserID : myID,
      'lastChat': lastMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }
  Future sendMessageToChatRoom(chatID,myID,selectedUserID,content,messageType) async {
    await Firestore.instance
        .collection('ChatRoom')
        .document(chatID)
        .collection(chatID)
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData({
      'idFrom': myID,
      'idTo': selectedUserID,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': content,
      'type': messageType,
      'isread': false,
    });
  }
}
