import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/auth_provider_check.dart';
import '../../../../core/services/story_service.dart';
import '../../login/login_screen.dart';

class AvatarDetailStory extends StatefulWidget {
  final String image_path;
  final String title;
  final String author;
  final int story_id;

  const AvatarDetailStory(
      {super.key,
      required this.image_path,
      required this.title,
      required this.author,
      required this.story_id});

  @override
  State<AvatarDetailStory> createState() => _AvatarDetailStoryState();
}

class _AvatarDetailStoryState extends State<AvatarDetailStory> {
  bool isExists = false;
  final StoryService storyService = StoryService();

  //late Future<String?> token;
  @override
  void initState() {
    super.initState();
    _checkIfStoryIsFavourite();
  }

  Future<void> _checkIfStoryIsFavourite() async {
    bool isFavourite =
        await storyService.checkStoriesFavourite(widget.story_id);
    setState(() {
      isExists = isFavourite;
    }); // Trigger a rebuild to reflect the new value of isExists
  }

  void _toggleFavourite() async {
    bool success;
    if (isExists) {
      success = await storyService.deleteStoriesFavourite(widget.story_id);
      if (!success) {
        setState(() {
          isExists = false;
        });
        _showSnackBar('Đã xóa khỏi yêu thích');
      } else {
        _showSnackBar('Xóa khỏi yêu thích thất bại');
      }
    } else {
      success = await storyService.postStoriesFavourite(widget.story_id);
      if (success) {
        setState(() {
          isExists = true;
        });
        _showSnackBar('Đã thêm vào yêu thích');
      } else {
        _showSnackBar('Thêm vào yêu thích thất bại');
      }
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
                ),
              ),
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
                                    builder: (context) => LogginScreen()));
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
                      Icon(Icons.download, color: Colors.white),
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
