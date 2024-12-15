import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story/presentation/screens/search/widget/custom_search_bar.dart';

import '../../../core/services/story_service.dart';
import '../../../core/utils/loadding.dart';
import '../../../models/story.dart';
import '../../widgets/default_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController = TextEditingController();
  late Future<List<Story>> _futureSearch;
  final StoryService _storyService = StoryService();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _futureSearch = _storyService.fetchStoriesSearch(''); // Tìm kiếm mặc định
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Hủy bỏ timer debounce
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _futureSearch =
            _storyService.fetchStoriesSearch(_searchController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            CustomSearchBar(searchController: _searchController),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Story>>(
                future: _futureSearch,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildShimmerLoading();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return DefaultList(
                      stories: snapshot.data!,
                      viewsOrRead: true,
                    );
                  } else {
                    return const Center(child: Text('No stories found.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
