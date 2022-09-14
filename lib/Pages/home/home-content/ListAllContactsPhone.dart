import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sure_keep/Chat/chatConversation.dart';
import 'package:sure_keep/Models/user-model.dart';
import 'package:sure_keep/Router/navigate-route.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class ListAllContactPhone extends StatefulWidget {
  final UserModel userData;

  const ListAllContactPhone({required this.userData, Key? key})
      : super(key: key);

  @override
  State<ListAllContactPhone> createState() => _ListAllContactPhoneState();
}

class _ListAllContactPhoneState extends State<ListAllContactPhone> {
  List<Contact>? contacts;
  User? user = FirebaseAuth.instance.currentUser;
  String _message = "You are invited";
  final telephony = Telephony.instance;

  bool? _isAccept;

  List<String> phoneNumber = [];
  List<dynamic> numberAccept = [];
  List<String> isEqualTOphoneNumber = [];

  List listUsers = [];

  final _random = Random();

  getUsers() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('table-user').get();
    final List<DocumentSnapshot> document = result.docs;

    DocumentSnapshot documentSnapshot = document[0];

    for (int i = 0; i < document.length; i++) {
      phoneNumber.add(document[i]['phoneNumber']);
    }
  }

  UserModel? userModels;

  getCurrentUser() async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('table-user')
          .where('email', isEqualTo: user!.email)
          .get();
      final List<DocumentSnapshot> document = result.docs;

      DocumentSnapshot documentSnapshot = document[0];

      userModels = UserModel.fromMap(documentSnapshot);

      print(userModels!.firstName.toString());
      print("KAKAKAKA");
    } catch (e) {
      return null;
    }
  }

  getUserAccept() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('table-accept-request')
        .get();
    final List<DocumentSnapshot> document = result.docs;

    DocumentSnapshot documentSnapshot = document[0];

    for (int i = 0; i < document.length; i++) {
      numberAccept.add(document[i]['Accept'][0]);
    }

    print(numberAccept);
  }

  @override
  void initState() {
    super.initState();
    getContact();
    initPlatformState();
    getUsers();
    getUserAccept();
    loadFCM();
    isAccepts();
    getCurrentUser();
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

  void sendPushMessage(String token, String title, String body) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA46pw8dw:APA91bH16DQMBlHChehqWl-REs6Y4pkEVqOTtME1yRgGvN-8yrQcy5uwzXDW_HbR_jK2o_sGwjTo-rWKVXkbz62nMKJN3lqrhWCrkxMN7XG4D32V3utQlgHLUvmwhAdIgnVDIkOLJRCJ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void loadFCM() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void loadSend(String phoneNumber, String id) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      bool isallowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isallowed) {
        //no permission of local notification
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        if (notification != null && android != null && !kIsWeb) {
          //show notification
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                  //simgple notification
                  id: 123,
                  channelKey: 'basic',
                  //set configuration wuth key "basic"
                  title: notification.title,
                  body: notification.body,
                  payload: {"phoneNumber": phoneNumber, "id": id},
                  autoDismissible: false,
                  //bigPicture: widget.user.imageUrl,
                  roundedBigPicture: true),
              actionButtons: [
                NotificationActionButton(
                  key: "Accept",
                  label: "Accept",
                ),
                NotificationActionButton(
                  key: "Decline",
                  label: "Decline",
                )
              ]);
        }
      }
    });
  }

  Future<bool?> isAccepts(


      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? _isAppBackGround = prefs.getBool('accept') ?? false;
    _isAccept = _isAppBackGround;

    return _isAccept;
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

                        if (num[0].contains('0')) {
                          number = num.replaceRange(0, 1, '+63');
                        } else {
                          number = num;
                        }

                        // if(!num.contains('+63')){
                        //   number  = num.replaceRange(0,1, '+63');
                        // }else{
                        //   number = num;
                        // }

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

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: (contacts![index].photo == null)
                                ? CircleAvatar(
                                    backgroundColor: Colors.primaries[_random
                                            .nextInt(Colors.primaries.length)]
                                        [_random.nextInt(9) * 100],
                                    radius: 30,
                                    child: Icon(
                                      Icons.person,
                                    ))
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: MemoryImage(image!)),
                            title: SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "  ${contacts![index].name.first} ${contacts![index].name.last}",
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          letterSpacing: .5),
                                    ),
                                  ),
                                  Text(
                                    '  $num',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            trailing: phoneNumber
                                    .contains(number.replaceAll(" ", ""))
                                ? OutlinedButton(
                                    onPressed: () async {


                                      UserModel? userModel;
                                      User? user =
                                          FirebaseAuth.instance.currentUser;

                                      final QuerySnapshot result =
                                          await FirebaseFirestore.instance
                                              .collection('table-user')
                                              .where('phoneNumber',
                                                  isEqualTo: number.replaceAll(
                                                      " ", ""))
                                              .get();
                                      final List<DocumentSnapshot> document =
                                          result.docs;

                                      DocumentSnapshot documentSnapshot =
                                          document[0];

                                      userModel =
                                          UserModel.fromMap(documentSnapshot);

                                      //NavigateRoute.gotoPage(context, ChatConversation(user: userModel));

                                      if( !numberAccept.contains(
                                          number.replaceAll(" ", ""))){

                                        await FirebaseFirestore.instance
                                            .collection('table-accept-request')
                                            .add({
                                          "from": user!.email,
                                          "to": userModel.email,
                                          // "Accept": FieldValue.arrayUnion(
                                          //   [""],
                                          // ),
                                        }).then((val) async {
                                          sendPushMessage(
                                              userModel!.token.toString(),
                                              user.displayName.toString(),
                                              "Send you a request");
                                          loadSend(
                                              userModel.phoneNumber.toString(),val.id);
                                          // Future.delayed(Duration(seconds: 2)).then((value) async{
                                          //   await CircularProgressIndicator();
                                          //    Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg: "Request sent...");
                                        });
                                      }

                                    },
                                    child: numberAccept.contains(
                                            number.replaceAll(" ", ""))
                                        ? Text('Connected',
                                            style: GoogleFonts.lato(
                                              textStyle: const TextStyle(
                                                  color: Colors.red,
                                                  letterSpacing: .5),
                                            ))
                                        : Text('Connect',
                                            style: GoogleFonts.lato(
                                              textStyle: const TextStyle(
                                                  color: Colors.red,
                                                  letterSpacing: .5),
                                            )),
                                  )
                                : OutlinedButton(
                                    onPressed: () {
                                      _showAlertDialogInvite(
                                          num, contacts![index].name.first);

                                      // telephony.sendSms(to: num, message: "${contacts![index].name.first} invited you to download Sure Keep App at.\n"
                                      //     " https://www.facebook.com/kissiney.sweet ");
                                    },
                                    child: Text(
                                      'Invite',
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            color: Colors.blue,
                                            letterSpacing: .5),
                                      ),
                                    )),
                          ),
                        );
                        // return Container(
                        //   margin: EdgeInsets.all(8),
                        //   child: Wrap(
                        //     //spacing: 4,
                        //     runSpacing: 4,
                        //     alignment: WrapAlignment.spaceAround,
                        //     crossAxisAlignment: WrapCrossAlignment.center,
                        //
                        //
                        //     children: [
                        //       (contacts![index].photo == null)
                        //           ? CircleAvatar(
                        //         backgroundColor:  Colors.primaries[_random.nextInt(Colors.primaries.length)]
                        //     [_random.nextInt(9) * 100],
                        //           radius: 30,
                        //               child: Icon(Icons.person,))
                        //           : CircleAvatar(
                        //         radius: 30,
                        //               backgroundImage: MemoryImage(image!)),
                        //   SizedBox(
                        //     width: 200,
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //                    "  ${contacts![index].name.first} ${contacts![index].name.last}",
                        //           style: GoogleFonts.lato(
                        //             textStyle: const TextStyle(color: Colors.blue, letterSpacing: .5),
                        //           ),),
                        //         Text('  $num'),
                        //       ],
                        //     ),
                        //   ),
                        //
                        //
                        //       phoneNumber.contains(number.replaceAll(" ", "")) ?
                        //       OutlinedButton(onPressed: () async{
                        //         UserModel? userModel;
                        //         User? user = FirebaseAuth.instance.currentUser;
                        //
                        //         final QuerySnapshot result = await FirebaseFirestore.instance
                        //             .collection('table-user')
                        //             .where('phoneNumber', isEqualTo: number.replaceAll(" ", "") )
                        //             .get();
                        //         final List<DocumentSnapshot> document = result.docs;
                        //
                        //         DocumentSnapshot documentSnapshot = document[0];
                        //
                        //         userModel = UserModel.fromMap( documentSnapshot);
                        //
                        //
                        //          //NavigateRoute.gotoPage(context, ChatConversation(user: userModel));
                        //         await FirebaseFirestore.instance
                        //             .collection('table-user')
                        //             .doc(userModel.docID)
                        //             .update({
                        //           "Accept":
                        //           FieldValue.arrayUnion([user!.email],),
                        //         }).whenComplete(() async {
                        //
                        //           sendPushMessage(userModel!.token.toString(), user.displayName.toString(),"Send you a request");
                        //           loadSend(user.email.toString());
                        //           // Future.delayed(Duration(seconds: 2)).then((value) async{
                        //           //   await CircularProgressIndicator();
                        //           //    Navigator.pop(context);
                        //              Fluttertoast.showToast(msg: "Request sent...");
                        //         });
                        //
                        //
                        //
                        //
                        //       }, child: isAccept == true ? Text('Connected'):Text('Connect',style: GoogleFonts.lato(
                        //         textStyle: const TextStyle(color: Colors.red, letterSpacing: .5),
                        //       )),)
                        //       : OutlinedButton(onPressed: (){
                        //         _showAlertDialogInvite(num,contacts![index].name.first);
                        //
                        //         // telephony.sendSms(to: num, message: "${contacts![index].name.first} invited you to download Sure Keep App at.\n"
                        //         //     " https://www.facebook.com/kissiney.sweet ");
                        //
                        //       }, child: Text('Invite',  style: GoogleFonts.lato(
                        //       textStyle: const TextStyle(color: Colors.blue, letterSpacing: .5),
                        //       ),)),
                        //
                        //
                        //       // OutlinedButton(onPressed: (){
                        //       //   if(!phoneNumber.contains(number)){
                        //       //     telephony.sendSms(to: num, message: "${contacts![index].name.first} invited you to download Sure Keep App at.\n"
                        //       //         " https://www.facebook.com/kissiney.sweet ");
                        //       //   }else{
                        //       //     NavigateRoute.gotoPage(context, ChatConversation(user: widget.userData));
                        //       //   }
                        //       //
                        //       // }, child: phoneNumber.contains(number.replaceAll(" ", "")) ? Text("Connect",style: TextStyle(color: Colors.red)): Text("Invite",style: TextStyle(color: Colors.green),)),
                        //       //
                        //     ],
                        //   ),
                        // );
                      },
                    ),
                  ),
                ],
              ));
  }

  _showAlertDialogInvite(String num, String name) {
    User? user = FirebaseAuth.instance.currentUser;

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
                child: const Text('Yes'),
                onPressed: () {
                  telephony.sendSms(
                      to: num,
                      message:
                          '${user!.displayName} invited you to download Sure Keep App at.\n" '
                          " https://www.facebook.com/kissiney.sweet ");

                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                    timeInSecForIosWeb: 3,
                    msg: 'Message sent ',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER_RIGHT,
                  );
                },
              ),
              TextButton(
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
