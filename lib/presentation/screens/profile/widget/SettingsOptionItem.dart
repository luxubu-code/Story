import 'package:flutter/material.dart';
import 'package:story/core/constants/AppColors.dart';

Widget SettingsOptionItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  required bool showArrow,
  required bool isLoggedIn, // Tùy chọn màu biểu tượng
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.berryPurple,
              size: 24.0,
            ),
          ),
          SizedBox(width: 16.0),
          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLoggedIn ? Colors.black87 : Colors.red,
              ),
            ),
          ),
          // Conditional Arrow Icon
          if (showArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    ),
  );
}
