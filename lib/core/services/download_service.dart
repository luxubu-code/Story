import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/chapter.dart';
import '../../models/story.dart';

class DownloadService {
  // Singleton pattern for download service
  static final DownloadService _instance = DownloadService._internal();

  factory DownloadService() => _instance;

  DownloadService._internal();

  // Track download progress
  final Map<int, double> _downloadProgress = {};

  // Get the base storage directory for downloaded chapters
  Future<Directory> get _downloadDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  // Download multiple chapters
  Future<void> downloadChapters({
    required Story story,
    required List<Chapter> chapters,
    required Function(int chapterId, double progress) onProgress,
    required Function(int chapterId, String? error) onComplete,
  }) async {
    final downloadDir = await _downloadDirectory;
    final storyDir = Directory('${downloadDir.path}/${story.story_id}');

    if (!await storyDir.exists()) {
      await storyDir.create(recursive: true);
    }

    // Download chapters in parallel with a maximum of 3 concurrent downloads
    final chunks = chapters
        .map((chapter) => () async {
              try {
                await _downloadChapter(
                  story: story,
                  chapter: chapter,
                  storyDir: storyDir,
                  onProgress: (progress) {
                    _downloadProgress[chapter.chapter_id] = progress;
                    onProgress(chapter.chapter_id, progress);
                  },
                );
                onComplete(chapter.chapter_id, null);
              } catch (e) {
                onComplete(chapter.chapter_id, e.toString());
              }
            })
        .toList();

    // Process downloads in chunks of 3
    for (var i = 0; i < chunks.length; i += 3) {
      final batch = chunks.skip(i).take(3);
      await Future.wait(batch.map((download) => download()));
    }
  }

  // Download a single chapter
  Future<void> _downloadChapter({
    required Story story,
    required Chapter chapter,
    required Directory storyDir,
    required Function(double progress) onProgress,
  }) async {
    final chapterFile = File('${storyDir.path}/${chapter.chapter_id}.json');

    // Create chapter metadata for offline access
    final chapterData = {
      'story_id': story.story_id,
      'chapter_id': chapter.chapter_id,
      'title': chapter.title,
      'content': await _fetchChapterContent(chapter.chapter_id),
      'downloaded_at': DateTime.now().toIso8601String(),
    };

    // Simulate download progress (replace with actual API calls)
    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress(i / 100);
    }

    // Save chapter data
    await chapterFile.writeAsString(jsonEncode(chapterData));
  }

  // Fetch chapter content from API (implement your actual API call here)
  Future<String> _fetchChapterContent(int chapterId) async {
    // TODO: Replace with your actual API call
    await Future.delayed(const Duration(seconds: 1));
    return 'Chapter content for $chapterId';
  }

  // Check if a chapter is already downloaded
  Future<bool> isChapterDownloaded(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File(
      '${downloadDir.path}/$storyId/$chapterId.json',
    );
    return chapterFile.exists();
  }

  // Get download progress for a chapter
  double getDownloadProgress(int chapterId) {
    return _downloadProgress[chapterId] ?? 0.0;
  }

  // Delete downloaded chapter
  Future<void> deleteChapter(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File(
      '${downloadDir.path}/$storyId/$chapterId.json',
    );
    if (await chapterFile.exists()) {
      await chapterFile.delete();
    }
  }
}
