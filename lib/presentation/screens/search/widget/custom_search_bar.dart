import 'package:flutter/material.dart';
import 'package:story/core/constants/AppColors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;

  const CustomSearchBar({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Bar with proper layout constraints
        Expanded(
          child: SizedBox(
            height: 50, // Provide a fixed height
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                focusColor: AppColors.imperialPurple,
                hintText: 'Tìm kiếm tiêu đề/Tác giả',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.search,
                    color: AppColors.berryPurple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        // Cancel Button
        GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back when tapped
          },
          child: Text(
            'Hủy',
            style: TextStyle(
              color: AppColors.royalPurple,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
