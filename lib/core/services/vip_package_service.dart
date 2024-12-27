import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:story/routes/api_endpoints.dart';

import '../../models/vip_package.dart';

class VipPackageService {
  final String baseUrl = ApiEndpoints.vip;

  Future<List<VipPackage>> getPackages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((json) => VipPackage.fromJson(json))
            .toList();
      } else {
        throw Exception('Không thể tải danh sách gói VIP');
      }
    } catch (e) {
      print('Lỗi: $e');

      throw Exception('Lỗi: $e');
    }
  }

  Future<VipPackage> getPackageById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        return VipPackage.fromJson(data['data']);
      } else {
        throw Exception('Không thể tải thông tin gói VIP');
      }
    } catch (e) {
      print('Lỗi: $e');
      throw Exception('Lỗi: $e');
    }
  }
}
