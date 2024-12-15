import 'package:flutter/material.dart';

import '../../../core/constants/AppColors.dart';
import '../../../core/services/story_service.dart';
import '../../../models/story.dart';
import '../../widgets/default_list.dart';

class RankScreen extends StatefulWidget {
  final String title;

  const RankScreen({super.key, required this.title});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoryService _storyService = StoryService();
  late Future<List<Story>> _futureStories;

  Future<List<Story>> _loadStories() async {
    try {
      if (_tabController.index == 0) {
        return await _storyService.fetchStoryMostViews(20);
      } else if (_tabController.index == 1) {
        return await _storyService.fetchStoryMostFavourite(20);
      }
      return [];
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _futureStories = _loadStories();
      });
    });
    _futureStories = _loadStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            dividerColor: AppColors.magentaPurple,
            dividerHeight: 2,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            labelColor: AppColors.magentaPurple,
            controller: _tabController,
            tabs: const [
              Tab(text: 'Lượt đọc'),
              Tab(text: 'Lượt yêu thích'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildStoryList(false), _buildStoryList(true)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryList(bool viewsOrRead) {
    return FutureBuilder<List<Story>>(
      future: _futureStories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return DefaultList(
            stories: snapshot.data!,
            viewsOrRead: viewsOrRead,
          );
        } else {
          return const Center(child: Text('No stories found.'));
        }
      },
    );
  }
}
