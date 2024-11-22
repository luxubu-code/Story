import 'package:flutter/material.dart';
import 'package:story/storage/secure_tokenstorage.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/clear_cache.dart';
import '../../../../core/utils/SettingsSection.dart';
import 'SettingsOptionItem.dart';

Widget BuildSettingsSection(BuildContext context, bool isLoggedIn) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        SettingsSection([
          Center(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.deepPurpleAccent,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: Icons.delete,
            title: 'Clear cache',
            onTap: () {
              ClearCache().clearAllCache(context);
            },
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: Icons.language,
            title: 'Language',
            onTap: () {},
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: Icons.doorbell_rounded,
            title: 'Notification',
            onTap: () {},
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          if (true)
            Column(
              children: [
                SizedBox(height: 8),
                SettingsOptionItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  showArrow: false,
                  isLoggedIn: isLoggedIn,
                  onTap: () async {
                    print('=============================================');
                    print(SecureTokenStorage.getToken().toString());
                    await AuthService.logout(context);
                  },
                ),
              ],
            ),
        ]),
      ],
    ),
  );
}
