import 'package:flutter/material.dart';

class AikenHomePage extends StatelessWidget {
  const AikenHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Daftar Kuesioner Uji Validitas Aiken"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text("Item Penilaian"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ItemPenilaian()),
                // );
              },
            ),
          ),
          Card(child: ListTile(title: Text("Item Penilaian"))),
          Card(child: ListTile(title: Text("Item Penilaian"))),
        ],
      ),
    );
  }
}
