import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:story/core/utils/navigation_utils.dart';
import 'package:story/presentation/screens/edit_profile/edit_profile_screen.dart';
import 'package:story/presentation/screens/vip/vip_subscription_screen.dart';
import 'package:story/presentation/screens/vip_history/subscription_history_screen.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/clear_cache.dart';
import '../../../../core/services/download_service.dart';
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
              'Cài đặt',
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
            icon: FontAwesomeIcons.crown,
            title: 'VIP',
            onTap: () {
              NavigationUtils.navigateTo(context, VipSubscriptionPage());
            },
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: FontAwesomeIcons.crown,
            title: 'Lịch sử đăng ký VIP',
            onTap: () {
              NavigationUtils.navigateTo(context, SubscriptionHistoryScreen());
            },
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: Icons.edit,
            title: 'Thông tin tài khoản',
            onTap: () {
              NavigationUtils.navigateTo(context, EditProfileScreen());
            },
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          SizedBox(height: 8),
          SettingsOptionItem(
            icon: Icons.delete,
            title: 'Xóa bộ nhớ tạm',
            onTap: () async {
              await DownloadService().clearAllDownloads();

              ClearCache().clearAllCache(context);
            },
            showArrow: true,
            isLoggedIn: isLoggedIn,
          ),
          // SizedBox(height: 8),
          // SettingsOptionItem(
          //   icon: Icons.language,
          //   title: 'Ngôn ngữ',
          //   onTap: () {},
          //   showArrow: true,
          //   isLoggedIn: isLoggedIn,
          // ),
          // SizedBox(height: 8),
          // SettingsOptionItem(
          //   icon: Icons.doorbell_rounded,
          //   title: 'Thông Báo',
          //   onTap: () {},
          //   showArrow: true,
          //   isLoggedIn: isLoggedIn,
          // ),
          SizedBox(height: 8),
          if (isLoggedIn)
            Column(
              children: [
                SizedBox(height: 8),
                SettingsOptionItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  showArrow: false,
                  isLoggedIn: isLoggedIn,
                  onTap: () async {
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
