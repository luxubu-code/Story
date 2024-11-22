import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/auth_provider_check.dart';
import '../../../models/user_model.dart';
import '../../../storage/secure_tokenstorage.dart';

class UserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderCheck>(builder: (context, authProvider, child) {
      return FutureBuilder<UserModel?>(
        future:
            SecureTokenStorage.getUser(), // Lấy thông tin người dùng từ storage
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Hiển thị vòng xoay chờ khi đang load dữ liệu
          } else if (snapshot.hasError) {
            return Text('Có lỗi xảy ra khi tải dữ liệu.');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Text('Không có thông tin người dùng.');
          } else {
            // Nếu có dữ liệu, hiển thị thông tin người dùng
            UserModel user = snapshot.data!;
            return Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  child: Text(
                      user.name[0]), // Hiển thị ký tự đầu của tên người dùng
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name, // Hiển thị tên người dùng
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.only(left: 6, right: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          border: Border.all(color: Colors.pink),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          'Lv 5',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      );
    });
  }
}
