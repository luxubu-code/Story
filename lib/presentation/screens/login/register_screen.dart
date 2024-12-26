import 'package:flutter/material.dart';
import 'package:story/core/utils/AppTextStyles.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/Snackbar.dart';
import '../../../core/utils/textfield_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String password_confirmation = _confirmPasswordController.text;
    if (email.isEmpty || password.isEmpty || password_confirmation.isEmpty) {
      Snack_Bar('Email và mật khẩu không được để trống');
      print('Email và mật khẩu không được để trống');
      return;
    }
    try {
      await AuthService().register(email, password, password_confirmation);
      Snack_Bar('register success');
      print('register success');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogginScreen(),
          ));
    } catch (e) {
      Snack_Bar('Login failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //       image: AssetImage('assets/img.jpg'), fit: BoxFit.cover),
      // ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'SEGGAY',
                    style: Apptextstyles.headline1,
                  ),
                  SizedBox(height: 40),
                  textfield_widget(
                      _emailController, Icon(Icons.email), 'Email'),
                  SizedBox(height: 20),
                  textfield_widget(
                      _passwordController, Icon(Icons.lock), 'Password'),
                  SizedBox(height: 20),
                  textfield_widget(_confirmPasswordController, Icon(Icons.lock),
                      'Confirm Password'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Already have an account? Log in',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
