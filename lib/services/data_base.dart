import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUserName(String userName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userEmail', isEqualTo: userEmail)
        .get();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap);
  }

  createChatRoom(String chatRoomID, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e);
    });
  }

  getConversationMessages(chatRoomID) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomID)
        .collection("chat")
        .orderBy("time")
        .snapshots();
  }

  addConversationMessages(chatRoomID, messageMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomID)
        .collection("chat")
        .add(messageMap)
        .catchError((e) {
      print(e);
    });
  }

  getChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection('chatRoom')
        .where('users', arrayContains: userName)
        .snapshots();
  }

// searchByName(String searchField) {
//   return FirebaseFirestore.instance
//       .collection("users")
//       .where('userName', isEqualTo: searchField)
//       .getDocuments();
// }
//
// Future<bool> addChatRoom(chatRoom, chatRoomId) {
//   FirebaseFirestore.instance
//       .collection("chatRoom")
//       .document(chatRoomId)
//       .setData(chatRoom)
//       .catchError((e) {
//     print(e);
//   });
// }
//
// getChats(String chatRoomId) async{
//   return FirebaseFirestore.instance
//       .collection("chatRoom")
//       .document(chatRoomId)
//       .collection("chats")
//       .orderBy('time')
//       .snapshots();
// }
//
//
// Future<void> addMessage(String chatRoomId, chatMessageData){
//
//   FirebaseFirestore.instance.collection("chatRoom")
//       .document(chatRoomId)
//       .collection("chats")
//       .add(chatMessageData).catchError((e){
//     print(e.toString());
//   });
// }
//
// getUserChats(String itIsMyName) async {
//   return await FirebaseFirestore.instance
//       .collection("chatRoom")
//       .where('users', arrayContains: itIsMyName)
//       .snapshots();
// }

}
