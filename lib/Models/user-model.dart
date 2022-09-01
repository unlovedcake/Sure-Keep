import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  String? docID;
  String? firstName;
  String? lastName;
  String? address;
  String? phoneNumber;
  String? email;
  String? fakePassword;
  String? gender;
  String? age;
  String? birthDate;
  String? userType;
  String? imageUrl;
  Map? chattingWith;
  Map? geoLocation;


  UserModel(
      {this.docID,this.firstName,
        this.lastName,
        this.address,
        this.phoneNumber,
        this.email,
        this.fakePassword,
        this.gender,
        this.age,
        this.birthDate,
        this.userType,
        this.imageUrl,
        this.chattingWith,
        this.geoLocation});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(

      docID: map['docID'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      fakePassword: map['fakePassword'],
      gender: map['gender'],
      age: map['age'],
      birthDate: map['birthDate'],
      userType: map['userType'],
      imageUrl: map['imageUrl'],
      chattingWith: map['chattingWith'],
      geoLocation: map['geoLocation'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {

      'docID': docID,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'fakePassword': fakePassword,
      'gender': gender,
      'age': age,
      'birthDate': birthDate,
      'userType': userType,
      'imageUrl': imageUrl,
      'chattingWith': chattingWith,
      'geoLocation': geoLocation,
    };
  }
}