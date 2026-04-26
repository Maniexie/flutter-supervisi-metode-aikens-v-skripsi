import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/pages/dashboard.dart';
import 'package:supervisi/services/api_service.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset('assets/images/image.jpg', height: 100),
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(hintText: "Username"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);

                          try {
                            final result = await ApiLoginService.login(
                              usernameController.text,
                              passwordController.text,
                            );

                            final token = result['token'];
                            final role = result['user']['role'];
                            final isValidator = result['user']['isValidator'];

                            await ApiLoginService.saveLoginData(
                              token,
                              role,
                              isValidator,
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              DashboardPage.routeName,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                      child: Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
