import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sure_keep/Pages/home/home-screen.dart';
import 'package:sure_keep/Pages/sign_up/components/otp-verification-code.dart';
import 'package:sure_keep/Pages/sign_up/signup-screen.dart';

import '../Models/user-model.dart';
import '../Router/navigate-route.dart';
import '../Widgets/progress-dialog.dart';

class AuthProvider extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;

  String? errorMessage;
  String? userEmail;
  String verificationID = "";
  String _phoneNumber = "";

  bool isAppActive = true;

  bool get getAppActive => isAppActive;

  setAppActive(bool isActive) {
    isAppActive = isActive;
    notifyListeners();
  }


  String get getPhoneNumber => _phoneNumber;
  String get getVerificationID => verificationID;

  String get getUserEmail => userEmail!;

  String? _otpCode;

  Future<void> loginWithPhone(String phoneNumber, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating, Please wait...",
          );
        });

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {


          await _auth.signInWithCredential(credential).whenComplete(() async{

             _otpCode = credential.smsCode!;

            Fluttertoast.showToast(
              msg: 'OTP sent successfully.',
              timeInSecForIosWeb: 3,
              gravity: ToastGravity.CENTER_RIGHT,
            );

            print("Code Sent Successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {

          if (e.code == 'invalid-phone-number') {
            Fluttertoast.showToast(
              timeInSecForIosWeb: 3,
              msg: 'The phone number is invalid.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER_RIGHT,
            );
          }else {
            Fluttertoast.showToast(
              timeInSecForIosWeb: 3,
              msg: e.message.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER_RIGHT,
            );
          }
          Navigator.pop(context);
          print(e.message);
          print("EXPIRED");
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pop(context);
          NavigateRoute.gotoPage(context, const OTPVerificationCode());
          verificationID = verificationId;
          _phoneNumber = phoneNumber;
          notifyListeners();

          print("OTP Sent Successfully");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 5),
      );
    } catch (e) {
      Navigator.pop(context);
      print(e.toString());
    }
  }



   Future<void> verifyOTP(
      String otpCode, String verificationId, BuildContext context) async {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Verifiying OTP Code, Please wait...",
          );
        });

    try{

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpCode);

      if( _otpCode == otpCode){

        NavigateRoute.gotoPage(
            context, HomeScreen());

        Fluttertoast.showToast(
          msg: "You are logged in successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else{
        Fluttertoast.showToast(
          msg: "Invalid OTP Code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      await _auth.signInWithCredential(credential).then(
            (val) {
              Navigator.pop(context);
              NavigateRoute.gotoPage(context, const SignUpScreen());


              Fluttertoast.showToast(
                msg: 'Your account is successfully verified.',
                timeInSecForIosWeb: 3,
                gravity: ToastGravity.CENTER_RIGHT,
              );
        },
      );
    }catch(e){
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Invalid OTP Code',
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER_RIGHT,
      );
      print(e.toString());
    }



  }

  signUp(String password, UserModel? userModel, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: userModel!.email.toString(), password: password);
      user = userCredential.user;

      await user!.updateDisplayName(userModel.firstName);
      await user!.updatePhotoURL(userModel.imageUrl);
      await user!.reload();
      user = _auth.currentUser;

      userModel.docID = user!.uid;

      await FirebaseFirestore.instance
          .collection("table-user")
          .doc(user!.uid)
          .set(userModel.toMap())
          .then((uid) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', userModel.email.toString());

        userEmail = userModel.email.toString();

        //NavigateRoute.gotoPage(context, Home());

        QuickAlert.show(

            //customAsset: 'assets/images/form-header-img.png',
            context: context,
            autoCloseDuration: const Duration(seconds: 3),
            type: QuickAlertType.success,
            text: 'Welcome, You are now logged in !!!',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            });

        // Fluttertoast.showToast(
        //   msg: "Account created successfully :) ",
        //   timeInSecForIosWeb: 3,
        //   gravity: ToastGravity.CENTER_RIGHT,
        // );

        notifyListeners();
      });
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "email-already-in-use":
          errorMessage = "The account already exists for that email.";
          break;

        case "weak-password":
          errorMessage = "Weak Password.";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "Check Your Internet Access.";
      }

      Fluttertoast.showToast(
        timeInSecForIosWeb: 3,
        msg: errorMessage!,
        gravity: ToastGravity.CENTER,
      );
      print(error.code);
    }
  }

  signIn(String email, String password, BuildContext context) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgressDialog(
              message: "Authenticating, Please wait...",
            );
          });

      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) async {
        User? usr = FirebaseAuth.instance.currentUser;

        //Navigator.of(context).pop();
        //NavigateRoute.gotoPage(context, const Home());

        QuickAlert.show(

            //customAsset: 'assets/images/form-header-img.png',
            context: context,
            autoCloseDuration: const Duration(seconds: 3),
            type: QuickAlertType.success,
            text: 'Welcome, You are now logged in !!!',
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            });

        // Fluttertoast.showToast(
        //   msg: "You are now logged in... :) ",
        //   gravity: ToastGravity.CENTER_RIGHT,
        // );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);
      });

      notifyListeners();
    } on FirebaseAuthException catch (error) {
      Navigator.of(context).pop();
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be invalid.";

          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "Check Your Internet Access.";
      }

      // QuickAlert.show(
      //   context: context,
      //   autoCloseDuration: const Duration(seconds: 3),
      //   type: QuickAlertType.error,
      //   title: 'Oops...',
      //   text: errorMessage!,
      //);
      Fluttertoast.showToast(
        msg: errorMessage!,
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER_RIGHT,
      );
      print(error.code);
    }
  }
}
