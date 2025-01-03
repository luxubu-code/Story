import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/core/services/favourite_service.dart';
import 'package:story/core/utils/navigation_utils.dart';
import 'package:story/presentation/screens/download/download_screen.dart';

import '../../../../core/services/provider/auth_provider_check.dart';
import '../../../../models/chapter.dart';
import '../../../../models/story.dart';
import '../../login/login_screen.dart';

class AvatarDetailStory extends StatefulWidget {
  final List<Chapter> chapters;
  final Story story;
  final String image_path;
  final String title;
  final String author;
  final int story_id;

  const AvatarDetailStory(
      {super.key,
      required this.image_path,
      required this.title,
      required this.author,
      required this.story_id,
      required this.chapters,
      required this.story});

  @override
  State<AvatarDetailStory> createState() => _AvatarDetailStoryState();
}

class _AvatarDetailStoryState extends State<AvatarDetailStory> {
  bool isExists = false;
  final FavouriteService favouriteService = FavouriteService();

  @override
  void initState() {
    super.initState();
    _checkIfStoryIsFavourite();
  }

  Future<void> _checkIfStoryIsFavourite() async {
    bool isFavourite =
        await favouriteService.checkStoriesFavourite(widget.story_id);
    setState(() {
      isExists = isFavourite;
    }); // Trigger a rebuild to reflect the new value of isExists
  }

  void _toggleFavourite() async {
    try {
      bool success = isExists
          ? await favouriteService.deleteStoriesFavourite(widget.story_id)
          : await favouriteService.postStoriesFavourite(widget.story_id);

      if (success) {
        setState(() {
          isExists = !isExists;
        });
        _showSnackBar(
            isExists ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích');
      } else {
        _showSnackBar(isExists
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
    final authProvider = Provider.of<AuthProviderCheck>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.image_path,
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      color: Colors.grey,
                      child: Icon(Icons.error),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 30,
                        color: Colors.white,
                      ))),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.author,
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (authProvider.isLoggedIn) {
                            _toggleFavourite();
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Icon(
                              Icons.favorite,
                              key: ValueKey<bool>(isExists),
                              color: isExists
                                  ? Colors.pinkAccent
                                  : Colors.grey[300],
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => NavigationUtils.navigateTo(
                            context,
                            DownloadScreen(
                              chapters: widget.chapters,
                              story: widget.story,
                            )),
                        child: Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
