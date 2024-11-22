import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/presentation/screens/profile/user_widget.dart';
import 'package:story/presentation/screens/profile/widget/BuildSettingsSection.dart';

import '../../../core/services/auth_provider_check.dart';
import '../../../storage/secure_tokenstorage.dart';
import 'widget/login_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoggin();
  }

  void _checkLoggin() async {
    String? token = await SecureTokenStorage.getToken();
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false, // Loại bỏ nút quay lại
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Consumer<AuthProviderCheck>(
                      builder: (context, authProvider, child) {
                    if (!authProvider.isLoggedIn) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: GestureDetector(
                          onTap: () {
                            _checkLoggin();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purpleAccent),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: login_widget(context),
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: UserWidget(),
                        ),
                      );
                    }
                  }),
                  SizedBox(height: 20),
                  BuildSettingsSection(context, _isLoggedIn),
                  // Hiển thị phần cài đặt
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
