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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: size.height * 0.15),

          AspectRatio(aspectRatio: 6 / 3,
              child: Image.asset('assets/images/logo.png')),
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
