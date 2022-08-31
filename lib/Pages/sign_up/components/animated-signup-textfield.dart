import 'package:auto_animated/auto_animated.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:sure_keep/All-Constants/all_constants.dart';
import 'package:sure_keep/Pages/sign_up/components/head_text.dart';
import 'package:sure_keep/Pages/sign_up/components/otp-verification-code.dart';
import 'package:sure_keep/Pages/sign_up/components/social.dart';
import 'package:sure_keep/Router/navigate-route.dart';

import '../../../All-Constants/size_constants.dart';
import '../../../Models/user-model.dart';
import '../../../Provider/auth-provider.dart';
import '../../../Theme/color-theme.dart';
import '../../../Widgets/animation-item-builder.dart';
import '../../../Widgets/neumorphic_text_field_container.dart';
import '../../../Widgets/rectangular_button.dart';
import '../../../Widgets/rectangular_input_field.dart';
import 'header-signup.dart';
import 'package:intl/intl.dart';

class AnimateSignUpFields extends StatefulWidget {
  const AnimateSignUpFields({Key? key}) : super(key: key);

  @override
  State<AnimateSignUpFields> createState() => _AnimateSignUpFieldsState();
}

class _AnimateSignUpFieldsState extends State<AnimateSignUpFields> {
  int itemsCount = 0;
  List<Widget> icon = [];
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateinput = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  bool otpVisibility = false;
  User? user;
  String verificationID = "";
  String _genderRadioBtnVal = "Male";

  final _formKey = GlobalKey<FormState>();



  void _handleGenderChange(String value) {
    setState(() {
      _genderRadioBtnVal = value;
    });
  }

  @override
  void initState() {

    icon = [
      const HeaderSignUp(),
      Form(
        key: _formKey,
        child: Column(
          children: [
            RectangularInputField(
              controller: firstNameController,
              textInputType: TextInputType.text,
              hintText: 'First Name',
              icon: const Icon(
                Icons.person,
                color: Colors.orange,
              ),
              obscureText: false,
              onChanged: (val) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return ("User name is required");
                }
              },
            ),
            RectangularInputField(
              controller: lastNameController,
              textInputType: TextInputType.text,
              hintText: 'Last Name',
              icon: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
              obscureText: false,
              onChanged: (val) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return ("Last name is required");
                }
              },
            ),
            RectangularInputField(
              controller: emailController,
              textInputType: TextInputType.emailAddress,
              hintText: 'Email',
              icon: const Icon(
                Icons.email_rounded,
                color: Colors.green,
              ),
              obscureText: false,
              onChanged: (val) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return ("Email  is required");
                }
              },
            ),
            RectangularInputField(
              controller: passwordController,
              textInputType: TextInputType.text,
              hintText: 'Password',
              icon: const Icon(
                Icons.lock,
                color: Colors.black,
              ),
              obscureText: true,
              onChanged: (val) {},
              validator: (value) {
                if (value!.isEmpty) {
                  return ("Password  is required");
                }
              },
            ),
            Ink(
              child: NeumorphicTextFieldContainer(
                child: TextFormField(
                  controller: dateinput,
                  //editing controller of this TextField
                  decoration: InputDecoration(
                    helperStyle: TextStyle(
                      color: AppColors.black.withOpacity(0.7),
                      fontSize: 18,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.red,
                      size: 20,
                    ),
                    hintText: 'Your Birthday',
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat.yMMMMd().format(pickedDate);
                      //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                        dateinput.text =
                            formattedDate; //set output date to TextField value.
                      });

                      print(dateinput.text);
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
              ),
            ),
            Row(
              children: [
                Radio<String>(
                    value: "Male",
                    groupValue: _genderRadioBtnVal,
                    onChanged: (value) {
                      setState(() {
                        _genderRadioBtnVal = value.toString();

                        print(_genderRadioBtnVal);
                      });
                    }),
                Text("Male"),
                Radio<String>(
                    value: "Female",
                    groupValue: _genderRadioBtnVal,
                    onChanged: (val) {
                      setState(() {
                        _genderRadioBtnVal = val.toString();
                      });
                    }),
                Text("Female"),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(
        height: Sizes.appPadding / 2,
      ),
      RectangularButton(
          text: 'Sign Up',
          press: () {
            UserModel userModel = UserModel()
              ..firstName = firstNameController.text
              ..lastName = lastNameController.text
              ..email = emailController.text
              ..userType = "User"
              ..chattingWith = {
                'chattingWith': "",
                'lastMessage': "",
                'dateLastMessage': DateTime.now(),
              }
              ..imageUrl =
                  "https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg?w=2000";
            if (_formKey.currentState!.validate()) {
              //context.read<AuthProvider>().loginWithPhone(phoneController.text, context);
              //NavigateRoute.gotoPage(context, OTPVerificationCode());
            }
          }),
      const SizedBox(
        height: Sizes.dimen_40 / 2,
      ),
      const Social(),
    ];

    itemsCount = icon.length;

    Future.delayed(Duration(milliseconds: 1000) * 5, () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (icon.length > itemsCount) {
          itemsCount += 6;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LiveList(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        showItemInterval: Duration(milliseconds: 200),
        showItemDuration: Duration(milliseconds: 750),
        // showItemInterval: Duration(milliseconds: 150),
        // showItemDuration: Duration(milliseconds: 250),
        visibleFraction: 0.001,
        itemCount: itemsCount,
        itemBuilder: animationItemBuilder((index) => icon[index]));
  }
}

enum Gender { man, woman }