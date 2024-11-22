import 'package:flutter/material.dart';

import '../../core/services/story_service.dart';
import '../../models/story.dart';
import 'defaul_list.dart';

class ShowMoreList extends StatefulWidget {
  final String title;
  const ShowMoreList({super.key, required this.title});

  @override
  State<ShowMoreList> createState() => _ShowMoreListState();
}

class _ShowMoreListState extends State<ShowMoreList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoryService _storyService = StoryService();
  late Future<List<Story>> _futureStories;

  Future<List<Story>> _loadStories() async {
    try {
      if (_tabController.index == 0) {
        return await _storyService.fetchStoryMostViews(100);
      } else if (_tabController.index == 1) {
        return await _storyService.fetchStoryMostFavourite(100);
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
      appBar: AppBar(
        title: const Text('LeaderBoard'),
        bottom: TabBar(
          dividerColor: Colors.pinkAccent,
          dividerHeight: 2,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          labelColor: Colors.pinkAccent,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Top Views'),
            Tab(text: 'Top Favourites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Story>>(
            future: _futureStories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return DefaulList(stories: snapshot.data!);
              } else {
                return const Center(child: Text('No stories found.'));
              }
            },
          ),
          FutureBuilder<List<Story>>(
            future: _futureStories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return DefaulList(stories: snapshot.data!);
              } else {
                return const Center(child: Text('No stories found.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
