import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/user-model.dart';
import '../../Router/navigate-route.dart';
import 'settings-screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;

  ProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

   return SingleChildScrollView(
     child: Center(
       child: SizedBox(
         height: size.height,
         child: Column(
           children: [
             Column(
               children: [
                 Container(
                   padding: EdgeInsets.only(top: 20),
                   child: ClipOval(
                     child: CachedNetworkImage(
                       imageUrl: "${user.imageUrl}",
                       width: 100.0,
                       height: 100.0,
                     ),
                   ),
                 ),
                 Text(
                   "${user.firstName}",
                   //acessing the name property of the  MyPlatforms class
                   style: TextStyle(fontSize: 14),
                 ),
               ],
             ),
             SizedBox(
               height: 40,
             ),
             Wrap(
               spacing: 20,
               children: [
                 Wrap(
                   direction: Axis.vertical,
                   crossAxisAlignment: WrapCrossAlignment.center,
                   spacing: 6,
                   children: const [
                     Text("143"),
                     Text(
                       "Following",
                       //acessing the name property of the  MyPlatforms class
                       style: TextStyle(fontSize: 14, color: Colors.grey),
                     ),
                   ],
                 ),
                 Wrap(
                   direction: Axis.vertical,
                   crossAxisAlignment: WrapCrossAlignment.center,
                   spacing: 6,
                   children: const [
                     Text("143"),
                     Text(
                       "Followers",
                       //acessing the name property of the  MyPlatforms class
                       style: TextStyle(fontSize: 14, color: Colors.grey),
                     ),
                   ],
                 ),
                 Wrap(
                   direction: Axis.vertical,
                   crossAxisAlignment: WrapCrossAlignment.center,
                   spacing: 6,
                   children: const [
                     Text("143"),
                     Text(
                       "Like",
                       //acessing the name property of the  MyPlatforms class
                       style: TextStyle(fontSize: 14, color: Colors.grey),
                     ),
                   ],
                 ),
               ],
             ),
             const SizedBox(
               height: 20,
             ),
             Wrap(
               spacing: 40,
               children: [
                 OutlinedButton(
                     onPressed: () {},
                     child: const Text(
                       "Edit",
                       style: TextStyle(fontSize: 15),
                     )),
                 OutlinedButton(
                   style: OutlinedButton.styleFrom(
                     backgroundColor: Colors.black, //<-- SEE HERE
                   ),
                   onPressed: () {
                     NavigateRoute.gotoPage(context,const AndroidSettingsScreen());
                   },
                   child: const Text(
                     'Settings',
                     style: TextStyle(fontSize: 15, color: Colors.white),
                   ),
                 ),
               ],
             ),
             const SizedBox(
               height: 30,
             ),
             Wrap(
               spacing: 20,
               children: [
                 TextButton(
                   onPressed: () {},
                   child: const Text(
                     'Photos',
                     style: TextStyle(fontSize: 15, color: Colors.black),
                   ),
                 ),
                 TextButton(
                   onPressed: () {},
                   child: const Text(
                     'Videos',
                     style: TextStyle(fontSize: 15, color: Colors.black),
                   ),
                 ),
                 TextButton(
                   onPressed: () {},
                   child: const Text(
                     'Tagged',
                     style: TextStyle(fontSize: 15, color: Colors.black),
                   ),
                 )
               ],
             ),
             Expanded(
                 child: Center(
                     child: Container(
                       child: Text("You don't have any videos yet."),
                     )))
           ],
         ),
       ),
     ),
   );
  }
}