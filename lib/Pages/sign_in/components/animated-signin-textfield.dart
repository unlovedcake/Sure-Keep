import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sure_keep/Pages/sign_in/components/social.dart';

import '../../../All-Constants/size_constants.dart';
import '../../../Provider/auth-provider.dart';
import '../../../Widgets/account_check.dart';
import '../../../Widgets/animation-item-builder.dart';
import '../../../Widgets/rectangular_button.dart';
import '../../../Widgets/rectangular_input_field.dart';
import 'head_text.dart';


class AnimateSignInFields extends StatefulWidget {
  const AnimateSignInFields({Key? key}) : super(key: key);

  @override
  _AnimateSignInFieldsState createState() => _AnimateSignInFieldsState();
}

class _AnimateSignInFieldsState extends State<AnimateSignInFields> {
  int itemsCount = 0;
  List<Widget> icon = [];


  @override
  void initState() {

    icon = [


      HeadText(),







    ];

    itemsCount = icon.length;

    Future.delayed(Duration(milliseconds: 1000) * 5, () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (icon.length > itemsCount) {
          itemsCount += 4;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return LiveList(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        showItemInterval: Duration(milliseconds: 200),
        showItemDuration: const Duration(milliseconds: 750),
        visibleFraction: 0.001,
        itemCount: itemsCount,

        itemBuilder: animationItemBuilder((index) => icon[index]));
  }
}
