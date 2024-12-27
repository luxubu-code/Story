import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/provider/auth_provider_check.dart';

class UserWidget extends StatelessWidget {
  final String? avataUrl;
  final String? name;

  const UserWidget({super.key, this.avataUrl, this.name});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderCheck>(
      builder: (context, authProvider, child) {
        return Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: avataUrl != null && avataUrl!.isNotEmpty
                      ? NetworkImage(avataUrl!)
                      : AssetImage('assets/avatar.png') as ImageProvider,
                ),
              ],
            ),
            SizedBox(width: 12), // Khoảng cách giữa avatar và văn bản
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name != null && name!.isNotEmpty ? name! : "Người dùng",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'VIP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
