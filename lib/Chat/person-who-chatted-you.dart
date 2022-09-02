import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/user-model.dart';
import '../Utensils/read_timestamp.dart';
import 'chatConversation.dart';

class PersonWhoChattedYou extends StatefulWidget {
  const PersonWhoChattedYou({Key? key}) : super(key: key);

  @override
  State<PersonWhoChattedYou> createState() => _PersonWhoChattedYouState();
}

class _PersonWhoChattedYouState extends State<PersonWhoChattedYou>
    with WidgetsBindingObserver {
  Stream<QuerySnapshot> getFirestoreData() {
    return FirebaseFirestore.instance.collection('table-user').snapshots();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("RESUME");
    } else if (state == AppLifecycleState.inactive) {
      print("INACTIVEsss");
      // context.read<AuthProvider>().setAppActive(false);
      // Future.delayed(Duration(seconds: 5)).then((value) => print("INACTIVE"));
    } else if (state == AppLifecycleState.paused) {
      // context.read<AuthProvider>().setAppActive(false);
      //
      // Future.delayed(Duration(seconds: 5)).then((value) => print(" PAUSE"));
    } else if (state == AppLifecycleState.detached) {
      // context.read<AuthProvider>().setAppActive(false);
      print("DETACHED");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print('dispose called.............');
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    // borderRadius:  BorderRadius.only(
                    //   topLeft: Radius.circular(40.0),
                    //   topRight: Radius.circular(40.0),
                    // )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(user!.photoURL.toString())),
                        Spacer(),
                        Text("Search.."),
                        Spacer(),
                        Icon(Icons.search),
                      ],
                    ),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getFirestoreData(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if ((snapshot.data?.docs.length ?? 0) > 0) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) =>
                            buildItem(context, snapshot.data?.docs[index]),
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      );
                    } else {
                      return const Center(
                        child: Text('No user found...'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    User? user = FirebaseAuth.instance.currentUser;

    if (documentSnapshot != null) {
      UserModel userChat = UserModel.fromMap(documentSnapshot);

      if (userChat.docID == user!.uid) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatConversation(
                          user: UserModel.fromMap(documentSnapshot),
                        )));
          },
          child:  Container(

            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,


              children: [
                documentSnapshot.get('imageUrl').isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    documentSnapshot.get('imageUrl'),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                              color: Colors.grey,
                              value: loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null),
                        );
                      }
                    },
                    errorBuilder: (context, object, stackTrace) {
                      return const Icon(Icons.account_circle, size: 50);
                    },
                  ),
                )
                    : const Icon(
                  Icons.account_circle,
                  size: 50,
                ),
                Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,


                  children: [
                    Text(
                      documentSnapshot.get('firstName'),
                      style: const TextStyle(color: Colors.black),
                    ),
                    documentSnapshot.get('chattingWith')['chattingWith'] !=
                        user.email
                        ?  SizedBox(width: 160,)
                        : Container(
                      width: 120,
                          child: Text(
                      documentSnapshot.get('chattingWith')['lastMessage'],
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black,fontSize: 12),
                    ),
                        )
                  ],
                ),
             SizedBox(width: 100,),

                Text(
                  documentSnapshot.get('chattingWith')['chattingWith'] != user.email
                      ? ""
                      : readTimestamp(documentSnapshot
                      .get('chattingWith')['dateLastMessage']
                      .millisecondsSinceEpoch),
                  style: const TextStyle(color: Colors.black),
                ),


              ],
            ),
          ),



              // ListTile(
              //   leading: documentSnapshot.get('imageUrl').isNotEmpty
              //       ? ClipRRect(
              //           borderRadius: BorderRadius.circular(30),
              //           child: Image.network(
              //             documentSnapshot.get('imageUrl'),
              //             fit: BoxFit.cover,
              //             width: 50,
              //             height: 50,
              //             loadingBuilder: (BuildContext ctx, Widget child,
              //                 ImageChunkEvent? loadingProgress) {
              //               if (loadingProgress == null) {
              //                 return child;
              //               } else {
              //                 return SizedBox(
              //                   width: 50,
              //                   height: 50,
              //                   child: CircularProgressIndicator(
              //                       color: Colors.grey,
              //                       value: loadingProgress.expectedTotalBytes !=
              //                               null
              //                           ? loadingProgress.cumulativeBytesLoaded /
              //                               loadingProgress.expectedTotalBytes!
              //                           : null),
              //                 );
              //               }
              //             },
              //             errorBuilder: (context, object, stackTrace) {
              //               return const Icon(Icons.account_circle, size: 50);
              //             },
              //           ),
              //         )
              //       : const Icon(
              //           Icons.account_circle,
              //           size: 50,
              //         ),
              //   title: Column(
              //     children: [
              //       Text(
              //         documentSnapshot.get('firstName'),
              //         style: const TextStyle(color: Colors.black),
              //       ),
              //       documentSnapshot.get('chattingWith')['chattingWith'] !=
              //               user.email
              //           ? SizedBox.shrink()
              //           : Text(
              //               documentSnapshot.get('chattingWith')['lastMessage'],
              //               style: const TextStyle(color: Colors.black),
              //             )
              //     ],
              //   ),
              //   trailing: Text(
              //     documentSnapshot.get('chattingWith')['chattingWith'] != user.email
              //         ? ""
              //         : readTimestamp(documentSnapshot
              //             .get('chattingWith')['dateLastMessage']
              //             .millisecondsSinceEpoch),
              //     style: const TextStyle(color: Colors.black),
              //   ),
              // ),

        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
