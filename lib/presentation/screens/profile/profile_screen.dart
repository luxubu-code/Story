import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/presentation/screens/profile/widget/BuildSettingsSection.dart';
import 'package:story/presentation/screens/profile/widget/user_widget.dart';

import '../../../core/services/auth_provider_check.dart';
import 'widget/login_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Consumer<AuthProviderCheck>(
                builder: (context, authProvider, child) {
                  return Column(
                    children: [
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.purpleAccent),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: authProvider.isLoggedIn
                              ? UserWidget()
                              : login_widget(context),
                        ),
                      ),
                      SizedBox(height: 20),
                      BuildSettingsSection(context, authProvider.isLoggedIn),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
