import 'package:flutter/material.dart';

import '../All-Constants/color_constants.dart';
import 'neumorphic_text_field_container.dart';



class RectangularInputField extends StatelessWidget {

  final String hintText;
  final Icon icon;
  final bool obscureText;
  final TextInputType textInputType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const RectangularInputField({Key? key, required this.onChanged, required this.validator, required this.controller, required this.textInputType,required this.hintText,  required this.icon, required this.obscureText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicTextFieldContainer(
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        controller: controller,
        keyboardType: textInputType,
        cursorColor: Colors.black,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          helperStyle: TextStyle(
            color: AppColors.black.withOpacity(0.7),
            fontSize: 18,
          ),
          prefixIcon: icon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
