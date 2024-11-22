import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/AppTextStyles.dart';
import '../../../core/utils/Snackbar.dart';
import '../../../core/utils/textfield_widget.dart';
import '../../../main.dart';
import 'forgot_screen.dart';
import 'register_screen.dart'; // Ensure you have this file and update the path accordingly

class LogginScreen extends StatefulWidget {
  @override
  _LogginScreenState createState() => _LogginScreenState();
}

class _LogginScreenState extends State<LogginScreen> {
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    await AuthService().login(email, password, context);
    Snack_Bar('Login successful');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(initialIndex: 4),
      ),
      (Route<dynamic> route) => false, // Clear all previous routes
    );
  }

  void _registerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
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
                    'STORY',
                    style: Apptextstyles.headline1,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Map<String, dynamic>? user =
                          await AuthService().signInWithGoogle();
                      if (user != null) {
                        Snack_Bar('Google Sign-In successful');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(initialIndex: 4),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        Snack_Bar('Google Sign-In failed');
                      }
                    },
                    icon: Icon(Icons.login, color: Colors.white),
                    label: Text('Sign up with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Google's red color
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 20),
                  textfield_widget(
                      _emailController, Icon(Icons.email), 'Email'),
                  SizedBox(height: 20),
                  textfield_widget(
                      _passwordController, Icon(Icons.lock), 'Password'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _registerScreen,
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
