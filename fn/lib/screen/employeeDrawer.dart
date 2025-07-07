import 'package:employeeflutterspring/screen/registerEmployee.dart';
import 'package:flutter/material.dart';

class Employeedrawer extends StatefulWidget {
  const Employeedrawer({super.key});

  @override
  State<Employeedrawer> createState() => _EmployeedrawerState();
}

class _EmployeedrawerState extends State<Employeedrawer> {
  final minimumPadding = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employee Management')),
      body: Center(child: Text('Welcome to PXP Chanel')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(top: minimumPadding, bottom: minimumPadding),
          children: <Widget>[
            DrawerHeader(
              child: Text('Employee Management'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Register Employee'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterEmployee()),
                );
              },
            ),
            ListTile(title: Text('Get Employee'), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
