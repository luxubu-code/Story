import 'package:flutter/material.dart';
import 'package:story/core/services/favourite_service.dart';
import 'package:story/core/services/history_service.dart';

import '../../../core/constants/AppColors.dart';
import '../../../models/story.dart';
import '../../../storage/secure_tokenstorage.dart';
import '../../widgets/list_story_builder.dart';
import '../../widgets/login_content_stories_builder.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FavouriteService _favouriteService = FavouriteService();
  final HistoryService _historyService = HistoryService();
  late Future<List<Story>> _futureStories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _futureStories = _loadStories();
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
      return await _historyService.fetchHistory();
    } else if (_tabController.index == 1) {
      return await _favouriteService.fetchStoriesFavourite();
    } else {
      return await _favouriteService.fetchStoriesFavourite();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            dividerColor: AppColors.magentaPurple,
            dividerHeight: 2,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            labelColor: AppColors.magentaPurple,
            tabs: const [
              Tab(text: 'Lịch Sử Đọc'),
              Tab(text: 'Yêu Thích'),
              Tab(text: 'Tải Xuống'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                LoginContentStoriesBuilder(
                    futureStories: _futureStories,
                    storyBuilder: (stories) => ListStoryBuilder(
                          stories: stories,
                          context: context,
                        )),
                LoginContentStoriesBuilder(
                    futureStories: _futureStories,
                    storyBuilder: (stories) =>
                        ListStoryBuilder(stories: stories, context: context)),
                LoginContentStoriesBuilder(
                    futureStories: _futureStories,
                    storyBuilder: (stories) =>
                        ListStoryBuilder(stories: stories, context: context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginContentBuilder {}
