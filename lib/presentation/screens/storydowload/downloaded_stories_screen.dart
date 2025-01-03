import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/story.dart';
import 'download_chapter_screen.dart';

class DownloadedStoriesScreen extends StatefulWidget {
  const DownloadedStoriesScreen({super.key});

  @override
  State<DownloadedStoriesScreen> createState() =>
      _DownloadedStoriesScreenState();
}

class _DownloadedStoriesScreenState extends State<DownloadedStoriesScreen> {
  List<Story> _downloadedStories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedStories();
  }

  Future<void> _loadDownloadedStories() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${appDir.path}/downloads');

      if (!await downloadDir.exists()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // List all story directories
      final storyDirs = await downloadDir
          .list()
          .where((entity) => entity is Directory)
          .toList();

      final List<Story> stories = [];

      // Load each story's metadata
      for (var dir in storyDirs) {
        final storyInfoFile = File('${dir.path}/story_info.json');
        if (await storyInfoFile.exists()) {
          final storyData = jsonDecode(await storyInfoFile.readAsString());
          print('storyDatastoryDatastoryDatastoryData $storyData');
          final story = Story.fromJson(storyData);
          print('storyDatastoryDatastoryDatastoryData $story');
          stories.add(story);
        }
      }

      setState(() {
        _downloadedStories = stories;
        print('storyDatastoryDatastoryDatastoryData $_downloadedStories');
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading downloaded stories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedStories.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có truyện nào được tải xuống',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _downloadedStories.length,
                  itemBuilder: (context, index) {
                    final story = _downloadedStories[index];
                    print(
                        'storystorystorystorystorystorystorystorystory ${story.story_id} && ${story.title} && ${_downloadedStories.length}');
                    return _buildStoryCard(story);
                  },
                ),
    );
  }

  Widget _buildStoryCard(Story story) {
    print('DEBUG: Navigating with story: ${story.story_id}, ${story.title}');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DownloadedChaptersScreen(story: story),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(story.image_path),
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tác giả: ${story.author}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${story.chapters.length} chương',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: story.categories
                          .map((category) => Chip(
                                label: Text(
                                  category.title ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
