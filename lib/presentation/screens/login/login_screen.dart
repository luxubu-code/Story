import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/AppTextStyles.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/utils/textfield_widget.dart';
import '../../../main.dart';
import 'forgot_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Improved email validation with more comprehensive regex
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;

    // RFC 5322 standard email validation
    const pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    return RegExp(pattern).hasMatch(email);
  }

  // Improved password validation
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  // Show error message using a reusable function
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle login process
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (!_isValidEmail(email)) {
      _showErrorMessage('Nhập Email');
      return;
    }

    if (!_isValidPassword(password)) {
      _showErrorMessage('Mật khẩu phải trên 8 ký tự');
      return;
    }

    // Show loading state
    setState(() => _isLoading = true);

    try {
      await AuthService().login(email, password, context);
      if (!mounted) return;

      Snack_Bar('Đăng Nhập Thành Công');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(initialIndex: 4),
        ),
        (route) => false,
      );
    } catch (e) {
      _showErrorMessage('Sai Email hoặc mật khẩu');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signInWithGoogle(context);
      if (!mounted) return;

      if (user != null) {
        Snack_Bar('Đăng nhập google thành công');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(initialIndex: 4),
          ),
          (route) => false,
        );
      } else {
        _showErrorMessage('Đăng nhập google thất bại');
      }
    } catch (e) {
      _showErrorMessage('Đăng nhập google thất bại.Hãy đăng nhập lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'STORY',
                  style: Apptextstyles.headline1,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: Text(_isLoading
                      ? 'Đang đăng nhập ...'
                      : 'đăng nhập bằng google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
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
                const SizedBox(height: 20),
                textfield_widget(
                  _emailController,
                  const Icon(Icons.email),
                  'Email',
                ),
                const SizedBox(height: 20),
                textfield_widget(
                  _passwordController,
                  const Icon(Icons.lock),
                  'Password',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      Text(_isLoading ? 'Đang đăng nhập ...' : 'Đăng Nhập'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                      child: const Text(
                        'Đăng Ký',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              ),
                      child: const Text(
                        'Quên Mật Khẩu?',
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
    );
  }
}
