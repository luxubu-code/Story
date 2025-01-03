import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/chapter.dart';
import '../../../models/story.dart';
import 'chapter_viewer_screen.dart';

class DownloadedChaptersScreen extends StatefulWidget {
  final Story story;

  const DownloadedChaptersScreen({
    super.key,
    required this.story,
  });

  @override
  State<DownloadedChaptersScreen> createState() =>
      _DownloadedChaptersScreenState();
}

void logDebug(String message) {
  print('🔍 DEBUG: $message');
}

class _DownloadedChaptersScreenState extends State<DownloadedChaptersScreen> {
  List<Chapter> _downloadedChapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedChapters();
  }

  Future<void> _loadDownloadedChapters() async {
    logDebug('Starting to load downloaded chapters...');
    logDebug('Story ID: ${widget.story.story_id}');

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final storyDir =
          Directory('${appDir.path}/downloads/${widget.story.story_id}');

      if (!await storyDir.exists()) {
        logDebug('❌ Story directory does not exist!');
        setState(() => _isLoading = false);
        return;
      }

      // Load story info first
      final storyInfoFile = File('${storyDir.path}/story_info.json');
      if (!await storyInfoFile.exists()) {
        logDebug('❌ story_info.json not found!');
        setState(() => _isLoading = false);
        return;
      }

      // Parse story info
      final storyData = jsonDecode(await storyInfoFile.readAsString());
      final chapters = (storyData['chapters'] as List)
          .map((chapterData) => Chapter.fromJson(chapterData))
          .toList();

      logDebug('Found ${chapters.length} chapters in story_info.json');

      final List<Chapter> downloadedChapters = [];

      // Check each chapter
      for (var chapter in chapters) {
        final chapterFile = File('${storyDir.path}/${chapter.chapter_id}.json');
        final chapterImagesDir =
            Directory('${storyDir.path}/images/${chapter.chapter_id}');

        if (await chapterFile.exists() && await chapterImagesDir.exists()) {
          try {
            final chapterData = jsonDecode(await chapterFile.readAsString());
            final imagePaths = List<String>.from(chapterData['image_paths']);

            // Verify all images exist
            bool allImagesExist = true;
            for (String path in imagePaths) {
              if (!await File(path).exists()) {
                allImagesExist = false;
                break;
              }
            }

            if (allImagesExist) {
              downloadedChapters.add(chapter);
              logDebug('✅ Chapter ${chapter.chapter_id} verified and added');
            }
          } catch (e) {
            logDebug('❌ Error processing chapter ${chapter.chapter_id}: $e');
          }
        }
      }

      setState(() {
        _downloadedChapters = downloadedChapters;
        _isLoading = false;
      });

      logDebug('Total downloaded chapters found: ${downloadedChapters.length}');
    } catch (e, stackTrace) {
      logDebug('❌ Fatal error in _loadDownloadedChapters: $e');
      logDebug('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  // Add detailed logging to chapter viewer screen navigation
  Widget _buildChapterCard(Chapter chapter) {
    return Card(
      child: ListTile(
        onTap: () {
          logDebug('Opening chapter ${chapter.chapter_id}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterViewerScreen(
                story: widget.story,
                chapter: chapter,
              ),
            ),
          );
        },
        title: Text(chapter.title),
        subtitle: Text(
          'Ngày tải: ${chapter.created_at.toString().split(' ')[0]}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        centerTitle: true,
        actions: [
          // Add debug info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              final appDir = await getApplicationDocumentsDirectory();
              final storyDir = Directory(
                '${appDir.path}/downloads/${widget.story.story_id}',
              );
              logDebug('\n📁 Storage Debug Info:');
              logDebug('App directory: ${appDir.path}');
              logDebug('Story directory: ${storyDir.path}');
              if (await storyDir.exists()) {
                final files = await storyDir.list(recursive: true).toList();
                logDebug('All files in story directory:');
                for (var file in files) {
                  logDebug('  - ${file.path}');
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedChapters.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có chương nào được tải xuống',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _downloadedChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = _downloadedChapters[index];
                    return _buildChapterCard(chapter);
                  },
                ),
    );
  }
}
