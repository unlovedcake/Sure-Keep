import 'package:flutter/material.dart';

import '../../../All-Constants/size_constants.dart';



class HeadText extends StatelessWidget {
  const HeadText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.05),
          Text('SUREKEEP',style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),),
          AspectRatio(aspectRatio: 3 / 4,
          child: Image.asset('assets/images/logo.png')),
        ],
      ),
    );
  }
}
