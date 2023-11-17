
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

  late bool inFahrenheit;

  late double lowerDO;
  late double upperDO;

  late bool isLoggedIn;

  User(
      {required this.email,
      required this.firstName,
      required this.lastName,
      required this.dateCreated,
      required this.password,
      required this.lowerPH,
      required this.upperPH,
      required this.lowerTemp,
      required this.upperTemp,
      required this.inFahrenheit,
      required this.lowerDO,
      required this.upperDO,
      required this.isLoggedIn});

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
        inFahrenheit: json['inFahrenheit'],
        lowerDO: json['lowerDO'],
        upperDO: json['upperDO'],
        isLoggedIn: json['isLoggedIn']);
  }
}
