import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure to add intl package to pubspec.yaml

class BodyEditProfile extends StatelessWidget {
  final VoidCallback pickDate;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final bool isEditing;
  final String vip;

  // Add new parameters for email and creation date
  final String email;
  final DateTime creationDate;

  const BodyEditProfile({
    Key? key,
    required this.pickDate,
    required this.nameController,
    required this.dobController,
    required this.isEditing,
    required this.email,
    required this.creationDate,
    required this.vip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Thông Tin Tài Khoản"),
        _buildLabel("Tài Khoản : ${vip}"),

        // Email Section with Verification Status
        _buildLabel("Email"),
        _buildEmailInfoField(email),

        // Creation Date Section with Time Passed
        _buildLabel("Ngày Tạo Tài Khoản"),
        _buildAccountCreationInfoField(creationDate),

        _buildLabel("Họ và Tên"),
        _buildTextField(nameController, "Nhập tên của bạn",
            isEnabled: isEditing),

        _buildLabel("Ngày Sinh"),
        GestureDetector(
          onTap: isEditing ? pickDate : null,
          child: AbsorbPointer(
            child: _buildTextField(dobController, "Chọn ngày sinh",
                isEnabled: isEditing),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInfoField(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            email,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          // Icon(
          //   Icons.verified, // Add a verification icon
          //   color: Colors.green,
          //   size: 20,
          // ),
        ],
      ),
    );
  }

  Widget _buildAccountCreationInfoField(DateTime creationDate) {
    final now = DateTime.now();
    final difference = now.difference(creationDate);
    String timePassed;

    if (difference.inDays < 1) {
      timePassed = 'Hôm nay';
    } else if (difference.inDays < 30) {
      timePassed = '${difference.inDays} ngày';
    } else if (difference.inDays < 365) {
      timePassed = '${(difference.inDays / 30).floor()} tháng';
    } else {
      timePassed = '${(difference.inDays / 365).floor()} năm';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('dd/MM/yyyy').format(creationDate),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          Text(
            '($timePassed)',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isEnabled = false}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: isEnabled ? Colors.white : Colors.grey[100],
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}
