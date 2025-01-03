import 'package:flutter/material.dart';

import '../../../../core/constants/AppColors.dart';
import '../../../../core/services/favourite_service.dart';
import '../../../../core/utils/dateTimeFormatUtils.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../models/story.dart';
import '../../detail_story/detail_story_screen.dart';

class ListStoryBuilder extends StatefulWidget {
  final List<Story> stories;
  final BuildContext context;

  const ListStoryBuilder(
      {super.key, required this.stories, required this.context});

  @override
  State<ListStoryBuilder> createState() => _ListStoryBuilder();
}

class _ListStoryBuilder extends State<ListStoryBuilder> {
  bool isExists = false;
  final FavouriteService favouriteService = FavouriteService();
  late List<bool> favourites;

  //late Future<String?> token;
  @override
  void initState() {
    super.initState();
    favourites = List.generate(widget.stories.length, (_) => false);
    _checkFavourites();
  }

  Future<void> _checkFavourites() async {
    for (int i = 0; i < widget.stories.length; i++) {
      final isFavourite = await favouriteService
          .checkStoriesFavourite(widget.stories[i].story_id);
      if (mounted) {
        setState(() {
          favourites[i] = isFavourite;
        });
      }
    }
  }

  Future<void> _toggleFavourite(int index) async {
    try {
      final storyId = widget.stories[index].story_id;
      final success = favourites[index]
          ? await favouriteService.deleteStoriesFavourite(storyId)
          : await favouriteService.postStoriesFavourite(storyId);

      if (success) {
        setState(() {
          favourites[index] = !favourites[index];
        });
        _showSnackBar(favourites[index]
            ? 'Đã thêm vào yêu thích'
            : 'Đã xóa khỏi yêu thích');
      } else {
        _showSnackBar(favourites[index]
            ? 'Xóa khỏi yêu thích thất bại'
            : 'Thêm vào yêu thích thất bại');
      }
    } catch (e) {
      _showSnackBar('Có lỗi xảy ra');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.stories.length,
      itemBuilder: (context, index) {
        final story = widget.stories[index];
        return GestureDetector(
          onTap: () => NavigationUtils.navigateTo(
              context,
              DetailStoryScreen(
                  story_id: story.story_id, onShowComments: () {})),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFe0c3fc),
                    Color(0xFF8ec5fc),
                  ], // Gradient pastel nhẹ
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(15)), // Bo tròn góc cho nền gradient
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        story.image_path,
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 110,
                            color: Colors.grey[200],
                            child: Icon(Icons.image,
                                size: 40, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amethystPurple.withOpacity(0.1),
                              border:
                                  Border.all(color: AppColors.amethystPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              story.categories.isNotEmpty
                                  ? story.categories[0].title.toString()
                                  : 'Không có danh mục',
                              style: const TextStyle(
                                color: AppColors.amethystPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lần đọc cuối cùng: ${time((story.read_at))}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cập nhật: ${time(story.updated_at)}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _toggleFavourite(index),
                      child: Icon(
                        Icons.favorite,
                        size: 18,
                        color:
                            favourites[index] ? Colors.red : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
