import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nama = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await ApiGetUserService.getUser();

    if (data != null) {
      setState(() {
        nama = data['nama'] ?? 'No Name';
        email = data['email'] ?? 'No Email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ================= HEADER PROFILE =================
          Container(
            padding: EdgeInsets.all(20),

            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80.0),
                    topRight: Radius.circular(80.0),
                    bottomLeft: Radius.circular(80.0),
                    bottomRight: Radius.circular(80.0),
                  ),
                  child: Image.asset('assets/images/image1.jpg', height: 100),
                ),
                // CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                SizedBox(height: 10),
                Text(
                  nama,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(email, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),

          Divider(),

          // ================= MENU LIST =================
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text("Edit Profile"),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text("Ubah Password"),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("Riwayat Penilaian"),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text("Tentang Aplikasi"),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ApiLogoutService().logout();
                Navigator.pushReplacementNamed(context, '/login');
                print("logout");
              },
            ),
          ),
        ],
      ),
    );
  }
}
