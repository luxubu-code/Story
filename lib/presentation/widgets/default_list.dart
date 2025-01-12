import 'package:flutter/material.dart';
import 'package:story/core/constants/AppColors.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../core/services/favourite_service.dart';
import '../../models/story.dart';
import '../screens/detail_story/detail_story_screen.dart';

class DefaultList extends StatefulWidget {
  final bool viewsOrRead;
  final List<Story> stories;

  const DefaultList(
      {super.key, required this.stories, required this.viewsOrRead});

  @override
  State<DefaultList> createState() => _DefaultListState();
}

class _DefaultListState extends State<DefaultList> {
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

  void toDetailStory(id) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailStoryScreen(
            story_id: id,
            onShowComments: () {},
          ),
        ));
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
        return Container(
          padding: EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => NavigationUtils.navigateTo(
                context,
                DetailStoryScreen(
                    story_id: story.story_id, onShowComments: () {})),
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
                              story.categories[0].title.toString(),
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
                          Text(story.author.toString()),
                          Row(
                            children: [
                              Text(
                                story.averageRating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                color: Colors.yellowAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                widget.viewsOrRead == false
                                    ? Icons.visibility
                                    : Icons.favorite_outlined,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.viewsOrRead == false
                                    ? '${story.views}'
                                    : '${story.favourite}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.book,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${story.totalChapter}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
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
