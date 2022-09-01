import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:sure_keep/Models/user-model.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class ListAllContactPhone extends StatefulWidget {
  const ListAllContactPhone({Key? key}) : super(key: key);

  @override
  State<ListAllContactPhone> createState() => _ListAllContactPhoneState();
}

class _ListAllContactPhoneState extends State<ListAllContactPhone> {
  List<Contact>? contacts;

  String _message = "You are invited";
  final telephony = Telephony.instance;

  UserModel? userModel;

  List<String> phoneNumber = [];

  getUsers()async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('table-user')
        .get();
    final List<DocumentSnapshot> document = result.docs;
    DocumentSnapshot documentSnapshot = document[0];

    for(int i=0; i < document.length; i++){
      //DocumentSnapshot documentSnapshot = document[i];
      //userModel = UserModel.fromMap(documentSnapshot);

      //userModel!.phoneNumber = document[i]['phoneNumber'];

      phoneNumber.add(document[i]['phoneNumber']);


    }
    setState(() {});
    print(phoneNumber);
    print("OKEYEYE");


  }

  @override
  void initState() {
    super.initState();
    getContact();
    initPlatformState();
    getUsers();
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
     // print(contacts);
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {


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
                      itemCount: contacts!.length,
                      itemBuilder: (BuildContext context, int index) {
                        Uint8List? image = contacts![index].photo;
                        String num = (contacts![index].phones.isNotEmpty)
                            ? (contacts![index].phones.first.number)
                            : "--";
                        String number = "";


                        if(!num.contains('+63')){
                          number  = num.replaceRange(0,1, '+63');
                        }else{
                          number = num;
                        }


                        // return ListTile(
                        //     leading: (contacts![index].photo == null)
                        //         ? const CircleAvatar(child: Icon(Icons.person))
                        //         : CircleAvatar(
                        //             backgroundImage: MemoryImage(image!)),
                        //     title: Text(
                        //         "${contacts![index].name.first} ${contacts![index].name.last}"),
                        //     subtitle: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //       children: [
                        //         Text(num),
                        //         OutlinedButton(
                        //             onPressed: () async {
                        //               // final _sms = 'sms:$num';
                        //               //
                        //               // if(await canLaunch(_sms)){
                        //               //   await launch(_sms);
                        //               // }
                        //
                        //               telephony.sendSms(
                        //                   to: num, message: "You are invited.");
                        //               // await telephony.openDialer(num);
                        //             },
                        //             child: Text("Invite"))
                        //       ],
                        //     ),
                        //     onTap: () {
                        //       if (contacts![index].phones.isNotEmpty) {
                        //         launch('tel: ${num}');
                        //       }
                        //     });

                        return Container(
                          margin: EdgeInsets.all(8),
                          child: Wrap(
                            //spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceAround,
                            crossAxisAlignment: WrapCrossAlignment.center,


                            children: [
                              (contacts![index].photo == null)
                                  ? const CircleAvatar(
                                  radius: 30,
                                      child: Icon(Icons.person))
                                  : CircleAvatar(
                                radius: 30,
                                      backgroundImage: MemoryImage(image!)),
                          SizedBox(
                            width: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                           "  ${contacts![index].name.first} ${contacts![index].name.last}"),
                                Text('  $number'),
                              ],
                            ),
                          ),

                              OutlinedButton(onPressed: (){
                                if(!phoneNumber.contains(number)){
                                  telephony.sendSms(to: num, message: "${contacts![index].name.first} invited you to download Sure Keep App at.\n"
                                      " https://www.facebook.com/kissiney.sweet ");
                                }

                              }, child: phoneNumber.contains(number.replaceAll(" ", "")) ? Text("Connect",style: TextStyle(color: Colors.red)): Text("Invite",style: TextStyle(color: Colors.green),)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ));
  }
}
