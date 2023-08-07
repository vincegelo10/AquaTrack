import 'dart:convert';

class User {
  late String email;
  late String firstName;
  late String lastName;
  late String dateCreated;
  late String password;

  late double lowerPH;
  late double upperPH;

  late double lowerTemp;
  late double upperTemp;

  User(
      {required this.email,
      required this.firstName,
      required this.lastName,
      required this.dateCreated,
      required this.password,
      required this.lowerPH,
      required this.upperPH,
      required this.lowerTemp,
      required this.upperTemp});

  // Factory constructor to instantiate object from json format
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateCreated: json['dateCreated'],
      password: 'hidden_password',
      lowerPH: json['lowerPH'],
      upperPH: json['upperPH'],
      lowerTemp: json['lowerTemp'],
      upperTemp: json['upperTemp'],
    );
  }
  // User.setupPHThreshold(
  //     {required String email,
  //     required String firstName,
  //     required String lastName,
  //     required String dateCreated,
  //     required double? lowerPH,
  //     required double? upperPH,
  //     required String password}) {
  //   this.email = email;
  //   this.firstName = firstName;
  //   this.lastName = lastName;
  //   this.dateCreated = dateCreated;
  //   this.lowerPH = lowerPH;
  //   this.upperPH = upperPH;
  //   this.password = password;
  // }

  // User.setupTempThreshold(
  //     {required String email,
  //     required String firstName,
  //     required String lastName,
  //     required String dateCreated,
  //     required double? lowerPH,
  //     required double? upperPH,
  //     required double? lowerTemp,
  //     required double? upperTemp,
  //     required String password}) {
  //   this.email = email;
  //   this.firstName = firstName;
  //   this.lastName = lastName;
  //   this.dateCreated = dateCreated;
  //   this.lowerPH = lowerPH;
  //   this.upperPH = upperPH;
  //   this.lowerTemp = lowerTemp;
  //   this.upperTemp = upperTemp;
  //   this.password = password;
  // }
}
