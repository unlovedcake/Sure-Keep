import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sure_keep/Chat/chatConversation.dart';
import 'package:sure_keep/Models/user-model.dart';
import 'package:sure_keep/Router/navigate-route.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class Person1WhoChattedYou extends StatefulWidget {
  const Person1WhoChattedYou({Key? key}) : super(key: key);

  @override
  State<Person1WhoChattedYou> createState() => _Person1WhoChattedYouState();
}

class _Person1WhoChattedYouState extends State<Person1WhoChattedYou> {
  List<Contact>? contacts;

  String _message = "You are invited";
  final telephony = Telephony.instance;

  List<String> phoneNumber = [];
  List<UserModel> phoneNumbers = [];
  String? num = "";
  String? number = "";
  final _random = Random();

  getUsers() async {
    String number = "";
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('table-user').get();
    final List<DocumentSnapshot> document = result.docs;
    //
    //
    // for(int i=0; i < contacts!.length; i++) {
    //   DocumentSnapshot documentSnapshot = document[i];
    //   userModels = UserModel.fromMap(documentSnapshot);
    // }

    for (int i = 0; i < document.length; i++) {
      phoneNumber.add(document[i]['phoneNumber']);
    }

    print(num);
    print("OKEYEYE");
  }

  @override
  void initState() {
    super.initState();
    getContact();
    initPlatformState();
    //getUsers();
    contactList();
    users();

  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      setState(() {});
    }
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  List<DocumentSnapshot> document = [];
  UserModel? userModels;
  List listUsers = [];




  Future contactList()async {

    for (int i = 0; i < contacts!.length; i++) {
      num = (contacts![i].phones.isNotEmpty)
          ? (contacts![i].phones.first.number)
          : "--";


      if (num![0].contains('0')) {
        number = num!.replaceRange(0, 1, '+63');
      } else {
        number = num;
      }
      if(phoneNumber.contains(number)){

      }
    }

  }

  users()async{


    final  result =
    await FirebaseFirestore.instance
        .collection('table-user')

        .get();

    for (var doc in result.docs) {
      listUsers.add(doc.data());

      phoneNumber.add(doc.data()['phoneNumber']);
    }


  }



  @override
  Widget build(BuildContext context) {
    contactList();
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: (contacts) == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: InkWell(
                  //     onTap: () {},
                  //     child: Container(
                  //         height: 50,
                  //         decoration: BoxDecoration(
                  //           color: Colors.grey[300],
                  //           borderRadius:
                  //               BorderRadius.all(Radius.circular(10.0)),
                  //         ),
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.end,
                  //             children: [
                  //               ClipRRect(
                  //                   borderRadius: BorderRadius.circular(50),
                  //                   child: Image.network(
                  //                       'https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg?w=2000')),
                  //               Spacer(),
                  //               Text("Search.."),
                  //               Spacer(),
                  //               Icon(Icons.search),
                  //             ],
                  //           ),
                  //         )),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: phoneNumber.length,
                      itemBuilder: (BuildContext context, int index) {
                        Uint8List? image = contacts![index].photo;
                        String num = (contacts![index].phones.isNotEmpty)
                            ? (contacts![index].phones.first.number)
                            : "--";
                        String number = "";

                        if(num[0].contains('0')){
                          number  = num.replaceRange(0,1, '+63');
                        }else{
                          number = num;
                        }
                        //return Text(listUsers[index]['firstName']);

                        // return ListTile(
                        //   leading:  phoneNumber.contains(number.replaceAll(" ", ""))
                        //       ? (contacts![index].photo == null)
                        //       ? Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: CircleAvatar(
                        //         backgroundColor: Colors.primaries[
                        //         _random.nextInt(
                        //             Colors.primaries.length)]
                        //         [_random.nextInt(9) * 100],
                        //         radius: 30,
                        //         child: Icon(
                        //           Icons.person,
                        //         )),
                        //   )
                        //       : Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: CircleAvatar(
                        //         radius: 30,
                        //         backgroundImage: MemoryImage(image!)),
                        //   )
                        //       : SizedBox.shrink(),
                        //
                        //   title:  phoneNumber.contains(number.replaceAll(" ", ""))
                        //       ? SizedBox(
                        //     width: 150,
                        //     child: Column(
                        //       crossAxisAlignment:
                        //       CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           "  ${contacts![index].name.first} ${contacts![index].name.last}",
                        //           style: GoogleFonts.lato(
                        //             textStyle: const TextStyle(
                        //                 color: Colors.blue,
                        //                 letterSpacing: .5),
                        //           ),
                        //         ),
                        //
                        //       ],
                        //     ),
                        //   )
                        //       : SizedBox.shrink(),
                        //   trailing: phoneNumber.contains(number.replaceAll(" ", ""))
                        //       ? OutlinedButton(
                        //     onPressed: () async {
                        //       final QuerySnapshot result =
                        //       await FirebaseFirestore.instance
                        //           .collection('table-user')
                        //           .where('phoneNumber',
                        //           isEqualTo: number
                        //               .replaceAll(" ", ""))
                        //           .get();
                        //       final List<DocumentSnapshot> document =
                        //           result.docs;
                        //       UserModel? userModel;
                        //       DocumentSnapshot documentSnapshot =
                        //       document[0];
                        //
                        //       userModel =
                        //           UserModel.fromMap(documentSnapshot);
                        //
                        //       print(userModel);
                        //       NavigateRoute.gotoPage(context,
                        //           ChatConversation(user: userModel));
                        //     },
                        //     child: Text('Send Message',
                        //         style: GoogleFonts.lato(
                        //           textStyle: const TextStyle(
                        //               color: Colors.black,
                        //               letterSpacing: .5),
                        //         )),
                        //   )
                        //       : SizedBox.shrink()
                        // );

                        return Row(
                          //spacing: 4,

                          children: [
                            phoneNumber.contains(number.replaceAll(" ", ""))
                                ? (contacts![index].photo == null)
                                    ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                          backgroundColor: Colors.primaries[
                                                  _random.nextInt(
                                                      Colors.primaries.length)]
                                              [_random.nextInt(9) * 100],
                                          radius: 30,
                                          child: Icon(
                                            Icons.person,
                                          )),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: MemoryImage(image!)),
                                    )
                                : SizedBox.shrink(),
                            phoneNumber.contains(number.replaceAll(" ", ""))
                                ? SizedBox(

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "  ${contacts![index].name.first} ${contacts![index].name.last}",
                                          style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                                color: Colors.blue,
                                                letterSpacing: .5),
                                          ),
                                        ),

                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                            Spacer(),
                            phoneNumber.contains(number.replaceAll(" ", ""))
                                ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: OutlinedButton(
                                      onPressed: () async {
                                        final QuerySnapshot result =
                                            await FirebaseFirestore.instance
                                                .collection('table-user')
                                                .where('phoneNumber',
                                                    isEqualTo: number
                                                        .replaceAll(" ", ""))
                                                .get();
                                        final List<DocumentSnapshot> document =
                                            result.docs;
                                        UserModel? userModel;
                                        DocumentSnapshot documentSnapshot =
                                            document[0];

                                        userModel =
                                            UserModel.fromMap(documentSnapshot);

                                        print(userModel);
                                        NavigateRoute.gotoPage(context,
                                            ChatConversation(user: userModel));
                                      },
                                      child: Text('Send Message',
                                          style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                                color: Colors.black,
                                                letterSpacing: .5),
                                          )),
                                    ),
                                )
                                : SizedBox.shrink()

                            // OutlinedButton(onPressed: (){
                            //   if(!phoneNumber.contains(number)){
                            //     telephony.sendSms(to: num, message: "${contacts![index].name.first} invited you to download Sure Keep App at.\n"
                            //         " https://www.facebook.com/kissiney.sweet ");
                            //   }else{
                            //     NavigateRoute.gotoPage(context, ChatConversation(user: widget.userData));
                            //   }
                            //
                            // }, child: phoneNumber.contains(number.replaceAll(" ", "")) ? Text("Connect",style: TextStyle(color: Colors.red)): Text("Invite",style: TextStyle(color: Colors.green),)),
                            //
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ));
  }

  _showAlertDialogInvite(String name) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invite Other', style: TextStyle(fontSize: 18)),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    'Would you like to invite $name to download this app ?',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
