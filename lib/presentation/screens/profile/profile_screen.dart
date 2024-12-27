import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/presentation/screens/profile/widget/BuildSettingsSection.dart';
import 'package:story/presentation/screens/profile/widget/user_widget.dart';

import '../../../core/services/auth_provider_check.dart';
import '../../../core/services/user_provider.dart';
import 'widget/login_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    try {
      setState(() => _isLoading = true);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Consumer2<AuthProviderCheck, UserProvider>(
              builder: (context, authProvider, userProvider, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = userProvider.user;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: authProvider.isLoggedIn
                            ? UserWidget(
                                avataUrl: user?.avatar_url,
                                name: user?.name,
                              )
                            : login_widget(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    BuildSettingsSection(context, authProvider.isLoggedIn),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
