import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ClearCache {
  Future<void> clearAllCache(BuildContext context) async {
    try {
      // Xóa SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      // Xóa cache hình ảnh
      // await DefaultCacheManager().emptyCache();
      // Xóa file từ bộ nhớ tạm
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
      // Xóa database (nếu cần)
      // await deleteDatabase('my_db.db');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa tất cả cache'),
        ),
      );
      print('đã xóa cache');
    } catch (e) {
      print('lỗi khi xóa cache ${e}');
    }
  }
}

class ClearCache1 {
  Future<void> clearAllCache(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        // Duyệt qua từng tệp và thư mục trong thư mục tạm thời và xóa chúng
        tempDir.listSync().forEach((file) {
          try {
            if (file is File) {
              file.deleteSync();
            } else if (file is Directory) {
              file.deleteSync(recursive: true);
            }
          } catch (e) {
            print("Không thể xóa tệp/thư mục: ${file.path}");
          }
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa tất cả cache'),
        ),
      );
    } catch (e) {
      print("Lỗi khi xóa cache: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa cache'),
        ),
      );
    }
  }
}
