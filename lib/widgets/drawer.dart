import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // tutup drawer
            },
          ),
          ListTile(
            title: Text('Instrumen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Validator'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
