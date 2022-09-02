import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/conversation.dart';
import '../Models/user-model.dart';
import '../Provider/auth-provider.dart';
import '../Utensils/read_timestamp.dart';

class ChatConversation extends StatefulWidget {
  final UserModel user;

  const ChatConversation({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatConversation> createState() => _ChatConversationState();
}

class _ChatConversationState extends State<ChatConversation> {

  TextEditingController messageController = TextEditingController();



  User? user = FirebaseAuth.instance.currentUser;

  String? currentUserId;
  String? groupChatId;


  void read() {
    currentUserId = user!.uid;

    if (currentUserId!.compareTo(widget.user.docID.toString()) > 0) {
      groupChatId = '$currentUserId-${widget.user.docID.toString()}';
    } else {
      groupChatId = '${widget.user.docID.toString()}-$currentUserId';
    }
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, Object> dataNeedUpdate) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  @override
  void initState() {
    super.initState();

    read();
  }

  void sendChatMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('table-chat-conversation')
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    Conversation conversation = Conversation()
      ..idTo = peerId
      ..idFrom = currentUserId
      ..messageText = content
      ..dateCreated = DateTime.now()
      ..type = type;


    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, conversation.toMap());
    }).whenComplete(() {
      if (currentUserId == widget.user.docID.toString()) {
        return;
      }
      updateDataFirestore(
        'table-user',
        currentUserId,
        {
          'chattingWith': {
            'chattingWith':widget.user.email,
            'lastMessage': messageController.text,
            "dateLastMessage": DateTime.now(),
          }
        },
      );
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(widget.user.imageUrl.toString()),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${widget.user.firstName}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          // ListView.builder(
          //   itemCount: messages.length,
          //   shrinkWrap: true,
          //   padding: EdgeInsets.only(top: 10, bottom: 10),
          //   physics: NeverScrollableScrollPhysics(),
          //   itemBuilder: (context, index) {
          //     return Container(
          //       padding:
          //           EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          //       child: Align(
          //         alignment: (messages[index].messageType == "receiver"
          //             ? Alignment.topLeft
          //             : Alignment.topRight),
          //         child: Wrap(
          //           children: [
          //         (messages[index].messageType == "receiver" ?  CircleAvatar(
          //                 child: Icon(
          //               Icons.person,
          //               size: 20,
          //             ),radius: 10,) : SizedBox() ),
          //             Column(
          //               children: [
          //                 Container(
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(20),
          //                     color: (messages[index].messageType == "receiver"
          //                         ? Colors.grey.shade200
          //                         : Colors.blue[200]),
          //                   ),
          //                   padding: EdgeInsets.all(16),
          //                   child: Text(
          //                     messages[index].messageContent,
          //                     style: TextStyle(fontSize: 15),
          //                   ),
          //                 ),
          //                 Text(" 3 minutes ago",style: TextStyle(fontSize: 10,color: Colors.grey),),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
          Expanded(child: buildListMessage()),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      autofocus: false,
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (value) => {setState(() => value)},
                      decoration: InputDecoration(
                        hintText: "   Write Comment",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: TextFormField(
                  //     autofocus: true,
                  //     autocorrect: false,
                  //     keyboardType: TextInputType.multiline,
                  //     minLines: 1,
                  //     maxLines: 4,
                  //     decoration: InputDecoration(
                  //         hintText: "Write message...",
                  //         hintStyle: TextStyle(color: Colors.black54),
                  //         border: InputBorder.none),
                  //   ),
                  // ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      sendChatMessage(messageController.text, 0, groupChatId!,
                          currentUserId!, widget.user.docID.toString());

                      // var documentReference = FirebaseFirestore.instance
                      //     .collection('table-conversation')
                      //     .doc(user!.uid)
                      //     .collection(user!.uid)
                      //     .doc(
                      //         DateTime.now().millisecondsSinceEpoch.toString());
                      //
                      //
                      // Conversation conversation = Conversation()
                      //   ..idTo =  user!.uid
                      //   ..idFrom = widget.user.docID.toString()
                      //   ..messageText =  messageController.text
                      //   ..dateCreated = DateTime.now()
                      //   ..type = 0
                      //   ..user = {
                      //     'reciverName': widget.user.firstName,
                      //     'recieverEmail': widget.user.email,
                      //     'recieverImage': widget.user.imageUrl,
                      //   };
                      //
                      //
                      // //
                      // // ChatMessages chatMessages = ChatMessages(
                      // //     idFrom: widget.user.docID.toString(),
                      // //     idTo: user!.uid,
                      // //     timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
                      // //     content: messageController.text,
                      // //     type: 0);
                      // FirebaseFirestore.instance.runTransaction((transaction) async {
                      //   transaction.set(documentReference, conversation.toMap());
                      // });

                      // FirebaseFirestore.instance
                      //     .runTransaction((transaction) async {
                      //   await transaction.set(
                      //     documentReference,
                      //     {
                      //       'idFrom': widget.user.docID,
                      //       'idTo': user!.uid,
                      //       'createdAt': DateTime.now(),
                      //       'message': messageController.text,
                      //       'type': 0
                      //     },
                      //   );
                      // }).whenComplete(() {
                      //   Fluttertoast.showToast(msg: 'Sent');
                      // });
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('table-chat-conversation')
          .doc(groupChatId)
          .collection(groupChatId!)
          .orderBy("dateCreated", descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data?.docs.length,
              reverse: true,
              itemBuilder: (context, index) {
                final messageData = snapshot.data!.docs[index];

                if (context.watch<AuthProvider>().getAppActive == false) {
                  return Text("Encyrpted");
                }

                return Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child: Align(
                    alignment: (messageData.get('idFrom') == user!.uid
                        ? Alignment.topRight
                        : Alignment.topLeft),
                    child: Wrap(
                      children: [
                        (messageData.get('idFrom') == user!.uid
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  user!.photoURL.toString(),
                                  width: 20,
                                  height: 20,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  widget.user.imageUrl.toString(),
                                  width: 20,
                                  height: 20,
                                ))),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (messageData.get('idFrom') == user!.uid
                                    ? Colors.grey.shade200
                                    : Colors.blue[200]),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Text(
                                messageData.get('message'),
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              readTimestamp(
                                messageData
                                    .get('dateCreated')
                                    .millisecondsSinceEpoch,
                              ),
                              style:
                                  TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
          //buildItem(index, snapshot.data?.docs[index]));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  // Widget buildItem(int index, DocumentSnapshot? documentSnapshot) {
  //   if (documentSnapshot != null) {
  //     ChatMessages chatMessages = ChatMessages.fromDocument(documentSnapshot);
  //     if (chatMessages.idFrom == user!.uid) {
  //       // right side (my message)
  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               chatMessages.type == 0
  //                   ? messageBubble(
  //                 chatContent: chatMessages.content,
  //                 color: Colors.blueGrey,
  //                 textColor: Colors.white,
  //                 margin: const EdgeInsets.only(right: 10),
  //               )
  //
  //                   : const SizedBox.shrink(),
  //                Container(
  //                 clipBehavior: Clip.hardEdge,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: Image.network(
  //                   "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg?w=2000",
  //                   width: 40,
  //                   height:40,
  //                   fit: BoxFit.cover,
  //                   loadingBuilder: (BuildContext ctx, Widget child,
  //                       ImageChunkEvent? loadingProgress) {
  //                     if (loadingProgress == null) return child;
  //                     return Center(
  //                       child: CircularProgressIndicator(
  //                         color: Colors.grey,
  //                         value: loadingProgress.expectedTotalBytes !=
  //                             null &&
  //                             loadingProgress.expectedTotalBytes !=
  //                                 null
  //                             ? loadingProgress.cumulativeBytesLoaded /
  //                             loadingProgress.expectedTotalBytes!
  //                             : null,
  //                       ),
  //                     );
  //                   },
  //                   errorBuilder: (context, object, stackTrace) {
  //                     return const Icon(
  //                       Icons.account_circle,
  //                       size: 35,
  //                       color: Colors.grey,
  //                     );
  //                   },
  //                 ),
  //               ),
  //
  //             ],
  //           ),
  //          Container(
  //             margin: const EdgeInsets.only(
  //                 right: 50,
  //                 top: 6,
  //                 bottom: 8),
  //             child: Text(
  //               DateFormat('dd MMM yyyy, hh:mm a').format(
  //                 DateTime.fromMillisecondsSinceEpoch(
  //                   int.parse(chatMessages.timestamp),
  //                 ),
  //               ),
  //               style: const TextStyle(
  //                   color: Colors.grey,
  //                   fontSize: 12,
  //                   fontStyle: FontStyle.italic),
  //             ),
  //           ),
  //
  //         ],
  //       );
  //     }else{
  //       return Text("No Data");
  //     }
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }



  Widget messageBubble(
      {required String chatContent,
      required EdgeInsetsGeometry? margin,
      Color? color,
      Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: margin,
      width: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        chatContent,
        style: TextStyle(fontSize: 16, color: textColor),
      ),
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname});
}

class MessageType {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
