import 'package:flutter/material.dart';

import '../../../All-Constants/size_constants.dart';



class HeaderSignUp extends StatelessWidget {
  const HeaderSignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding:  EdgeInsets.symmetric(
        horizontal: Sizes.appPadding,
        vertical: Sizes.appPadding / 2,
      ),
      child: Column(

        children: [
          //SizedBox(height: size.height * 0.15),

          SizedBox(
              width: size.width *.5,
              height: size.height *.2,
              child: Image.asset('assets/images/logo.png')),

          Text('To help us with personal experience, \n'
              'pleas tell us a little about yourself.',style: TextStyle(fontSize: 14,color: Colors.grey[600]),),

          // Text('Welcome',style: TextStyle(
          //   fontSize: 24,
          //   fontWeight: FontWeight.w600,
          // ),),
          // Text('SIGN UP',style: TextStyle(
          //   fontSize: 36,
          //   fontWeight: FontWeight.bold,
          // ),),
        ],
      ),
    );
  }
}
