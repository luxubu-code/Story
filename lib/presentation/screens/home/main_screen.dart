import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story/presentation/screens/home/widget/story_carousel.dart';

import '../../../../models/story.dart';
import '../../../core/services/cache_manager.dart';
import '../../../core/services/story_service.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../main.dart';
import '../../widgets/show_more.dart';
import '../search/search.dart';
import 'widget/story_list.dart';

class NewStoryListPage extends StatefulWidget {
  const NewStoryListPage({super.key});

  @override
  _NewStoryListPageState createState() => _NewStoryListPageState();
}

class _NewStoryListPageState extends State<NewStoryListPage> {
  late Future<List<Story>> futureStories;
  late Future<List<Story>> futureStoryMostViews;
  late Future<List<Story>> futureStoryMostFavourites;
  final StoryService _storyService = StoryService(); // Khởi tạo chỉ một lần
  final CacheManager _cacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Hàm load data tập trung
  Future<void> _loadData() async {
    setState(() {
      futureStories = _storyService.fetchStories();
      futureStoryMostViews = _storyService.fetchStoryMostViews(6);
      futureStoryMostFavourites = _storyService.fetchStoryMostFavourite(6);
    });
  }

  // Hàm refresh data
  Future<void> _refreshStories() async {
    _cacheManager.clearCache();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Truyện Hot',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () =>
                NavigationUtils.navigateTo(context, SearchScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => _refreshStories(),
        child: SingleChildScrollView(
          child: FutureBuilder<List<List<Story>>>(
            future: Future.wait([
              futureStories,
              futureStoryMostViews,
              futureStoryMostFavourites
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              } else {
                final stories = snapshot.data![0];
                final mostReadStories = snapshot.data![1];
                final mostFavoriteStories = snapshot.data![2];
                return Column(
                  children: [
                    StoryCarousel(stories: stories),
                    SizedBox(height: 5),
                    ShowMore(
                      title: 'Lượt Đọc',
                      onShowMore: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(
                              initialIndex: 1, // Navigate to rank screen
                              rankTabIndex: 0, // Show "Lượt yêu thích" tab
                            ),
                          ),
                        );
                      },
                      border: true,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.32,
                      child: StoryList(
                        stories: mostReadStories,
                      ),
                    ),
                    ShowMore(
                      title: 'Lượt Yêu Thích',
                      onShowMore: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(
                              initialIndex: 1, // Navigate to rank screen
                              rankTabIndex: 1, // Show "Lượt yêu thích" tab
                            ),
                          ),
                        );
                      },
                      border: true,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.32,
                      child: StoryList(
                        stories: mostReadStories,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
