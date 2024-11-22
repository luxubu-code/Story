import 'package:flutter/material.dart';

import '../../../core/services/story_service.dart';
import '../../../models/story.dart';
import '../../../storage/secure_tokenstorage.dart';
import '../../widgets/list_story_builder.dart';
import '../../widgets/login_content_builder.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoryService _storyService = StoryService();
  late Future<List<Story>> _futureStories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _futureStories = _loadStories(); // Khởi tạo dữ liệu ban đầu
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _futureStories = _loadStories();
    });
  }

  Future<List<Story>> _loadStories() async {
    String? token = await SecureTokenStorage.getToken();
    if (token == null || token.isEmpty) {
      print('No token available, skipping data load');
      return [];
    }
    if (_tabController.index == 0) {
      return await _storyService.fetchHistory();
    } else {
      return await _storyService.fetchStoriesFavourite();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Yêu Thích'),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          labelColor: Colors.pinkAccent,
          tabs: const [
            Tab(text: 'Lịch Sử Đọc'),
            Tab(text: 'Yêu Thích'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoginContentBuilder(
              futureStories: _futureStories,
              storyBuilder: (stories) => ListStoryBuilder(stories: stories)),
          LoginContentBuilder(
              futureStories: _futureStories,
              storyBuilder: (stories) => ListStoryBuilder(stories: stories)),
        ],
      ),
    );
  }
}
