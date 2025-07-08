import 'dart:convert';

// Decode JSON string to Employeemodel
Employeemodel employeemodelFromJson(String str) =>
    Employeemodel.fromJson(json.decode(str));

// Encode Employeemodel to JSON string
String employeemodelToJson(Employeemodel data) => json.encode(data.toJson());

class Employeemodel {
  String? id;
  String? firstName;
  String? lastName;

  Employeemodel({this.id, this.firstName, this.lastName});

  factory Employeemodel.fromJson(Map<String, dynamic> json) => Employeemodel(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
  );

  get fullName => null;

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
  };
}
