import 'package:flutter/material.dart';
import 'package:story/core/constants/AppColors.dart';

class StoryCardList extends StatelessWidget {
  final String image_path;
  final String title;
  final bool is_vip;

  const StoryCardList({
    super.key,
    required this.image_path,
    required this.title,
    required this.is_vip,
  });

  @override // Thêm chú thích override để mã rõ ràng hơn
  Widget build(BuildContext context) {
    return Card(
      // Nâng cấp độ nổi (elevation) để tăng chiều sâu hiển thị
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Tăng nhẹ bán kính bo góc
      ),
      child: Stack(
        fit: StackFit.expand, // Đảm bảo Stack chiếm toàn bộ không gian
        children: [
          // Container hình ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image_path,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              // Thêm xử lý lỗi và hiển thị khi đang tải
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.error)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          // Container tiêu đề với nền gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.06, // Tăng nhẹ chiều cao
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (is_vip)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: AppColors.berryPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
