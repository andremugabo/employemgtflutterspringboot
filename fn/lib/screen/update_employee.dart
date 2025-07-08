import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:employeeflutterspring/model/employee_model.dart';
import 'package:http/http.dart' as http;

class UpdateEmployee extends StatefulWidget {
  final Employeemodel employee;

  const UpdateEmployee({super.key, required this.employee});

  @override
  State<UpdateEmployee> createState() => _UpdateEmployeeState();
}

Future<Employeemodel?> updateEmployee(
  Employeemodel employee,
  BuildContext context,
) async {
  final url = Uri.parse('http://localhost:8080/employee/updateEmployee');

  try {
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedEmployee = employeemodelFromJson(response.body);

      // Show success dialog with backend response
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => MyAlertDialog(
              title: 'Employee Updated',
              content:
                  'ID: ${updatedEmployee.id}\n'
                  'Name: ${updatedEmployee.firstName} ${updatedEmployee.lastName}',
            ),
      );

      return updatedEmployee;
    } else {
      throw Exception(
        'Failed to update employee. Status code: ${response.statusCode}',
      );
    }
  } catch (error) {
    // Show error dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => MyAlertDialog(title: 'Error', content: error.toString()),
    );
    return null;
  }
}

class _UpdateEmployeeState extends State<UpdateEmployee> {
  final _formKey = GlobalKey<FormState>();
  final double _padding = 10.0;

  late final TextEditingController _idController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employee.id.toString());
    _firstNameController = TextEditingController(
      text: widget.employee.firstName,
    );
    _lastNameController = TextEditingController(text: widget.employee.lastName);
  }

  @override
  void dispose() {
    _idController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text("Update Employee")),
      body: Padding(
        padding: EdgeInsets.all(_padding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Employee ID (read-only)
              Padding(
                padding: EdgeInsets.symmetric(vertical: _padding / 2),
                child: TextFormField(
                  controller: _idController,
                  enabled: false,
                  style: textStyle,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

              // First Name input
              Padding(
                padding: EdgeInsets.symmetric(vertical: _padding / 2),
                child: TextFormField(
                  controller: _firstNameController,
                  style: textStyle,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter first name'
                              : null,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter first name',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

              // Last Name input
              Padding(
                padding: EdgeInsets.symmetric(vertical: _padding / 2),
                child: TextFormField(
                  controller: _lastNameController,
                  style: textStyle,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter last name'
                              : null,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter last name',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

              // Update Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: _padding),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updatedEmployee = Employeemodel(
                        id: widget.employee.id,
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                      );

                      final result = await updateEmployee(
                        updatedEmployee,
                        context,
                      );

                      if (result != null) {
                        setState(() {
                          widget.employee.firstName = result.firstName;
                          widget.employee.lastName = result.lastName;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Employee updated successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Update Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const MyAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
      actions: actions,
    );
  }
}
