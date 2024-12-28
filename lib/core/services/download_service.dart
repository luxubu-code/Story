import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/chapter.dart';
import '../../models/story.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();

  factory DownloadService() => _instance;

  DownloadService._internal();

  final Map<int, double> _downloadProgress = {};

  Future<Directory> get _downloadDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  // Save story data
  Future<void> _saveStoryData({
    required Story story,
    required Directory storyDir,
  }) async {
    final storyFile = File('${storyDir.path}/story_info.json');
    final storyData = {
      'story_id': story.story_id,
      'title': story.title,
      'author': story.author,
      'description': story.description,
      'image_path': story.image_path,
      'categories': story.categories,
      'downloaded_at': DateTime.now().toIso8601String(),
    };
    await storyFile.writeAsString(jsonEncode(storyData));
  }

  Future<void> downloadChapters({
    required Story story,
    required List<Chapter> chapters,
    required List<Map<String, dynamic>> chapterImages,
    required Function(int chapterId, double progress) onProgress,
    required Function(int chapterId, String? error) onComplete,
  }) async {
    final downloadDir = await _downloadDirectory;
    final storyDir = Directory('${downloadDir.path}/${story.story_id}');
    final imagesDir = Directory('${storyDir.path}/images');

    try {
      if (!await storyDir.exists()) await storyDir.create(recursive: true);
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

      await _saveStoryData(story: story, storyDir: storyDir);
      final chunks = chapters
          .map((chapter) => () async {
                try {
                  await _downloadChapter(
                    story: story,
                    chapter: chapter,
                    storyDir: storyDir,
                    chapterImages: chapterImages
                        .where((img) => img['chapter_id'] == chapter.chapter_id)
                        .toList(),
                    onProgress: (progress) =>
                        onProgress(chapter.chapter_id, progress),
                  );
                  onComplete(chapter.chapter_id, null);
                } catch (e) {
                  print('Lỗi khi tải chapter ${chapter.chapter_id}: $e');
                  onComplete(chapter.chapter_id, e.toString());
                }
              })
          .toList();

      for (var i = 0; i < chunks.length; i += 3) {
        final batch = chunks.skip(i).take(3);
        await Future.wait(batch.map((download) => download()));
      }
    } catch (e) {
      print('Lỗi trong downloadChapters(): $e');
    }
  }

  // // Download multiple chapters and story data
  // Future<void> downloadChapters({
  //   required Story story,
  //   required List<Chapter> chapters,
  //   required List<Map<String, dynamic>> chapterImages,
  //   required Function(int chapterId, double progress) onProgress,
  //   required Function(int chapterId, String? error) onComplete,
  // }) async {
  //   final downloadDir = await _downloadDirectory;
  //   final storyDir = Directory('${downloadDir.path}/${story.story_id}');
  //   final imagesDir = Directory('${storyDir.path}/images');
  //
  //   if (!await storyDir.exists()) {
  //     await storyDir.create(recursive: true);
  //   }
  //   if (!await imagesDir.exists()) {
  //     await imagesDir.create(recursive: true);
  //   }
  //
  //   // Save story data first
  //   await _saveStoryData(story: story, storyDir: storyDir);
  //
  //   // Download chapters in parallel with a maximum of 3 concurrent downloads
  //   final chunks = chapters
  //       .map((chapter) => () async {
  //             try {
  //               await _downloadChapter(
  //                 story: story,
  //                 chapter: chapter,
  //                 storyDir: storyDir,
  //                 chapterImages: chapterImages
  //                     .where(
  //                       (img) => img['chapter_id'] == chapter.chapter_id,
  //                     )
  //                     .toList(),
  //                 onProgress: (progress) {
  //                   _downloadProgress[chapter.chapter_id] = progress;
  //                   onProgress(chapter.chapter_id, progress);
  //                 },
  //               );
  //               onComplete(chapter.chapter_id, null);
  //             } catch (e) {
  //               onComplete(chapter.chapter_id, e.toString());
  //             }
  //           })
  //       .toList();
  //
  //   // Process downloads in chunks of 3
  //   for (var i = 0; i < chunks.length; i += 3) {
  //     final batch = chunks.skip(i).take(3);
  //     await Future.wait(batch.map((download) => download()));
  //   }
  // }

  Future<void> _downloadChapter({
    required Story story,
    required Chapter chapter,
    required Directory storyDir,
    required List<Map<String, dynamic>> chapterImages,
    required Function(double progress) onProgress,
  }) async {
    final chapterFile = File('${storyDir.path}/${chapter.chapter_id}.json');
    final imagesDir =
        Directory('${storyDir.path}/images/${chapter.chapter_id}');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Download and save chapter images
    final downloadedImages = await _downloadChapterImages(
      chapterImages,
      imagesDir,
      (progress) => onProgress(progress * 0.8), // 80% of progress for images
    );

    // Create chapter metadata for offline access
    final chapterData = {
      'story_id': story.story_id,
      'chapter_id': chapter.chapter_id,
      'title': chapter.title,
      'images': downloadedImages,
      'downloaded_at': DateTime.now().toIso8601String(),
    };

    // Save chapter data
    await chapterFile.writeAsString(jsonEncode(chapterData));
    onProgress(1.0); // Complete the progress
  }

  Future<List<String>> _downloadChapterImages(
    List<Map<String, dynamic>> images,
    Directory imagesDir,
    Function(double progress) onProgress,
  ) async {
    final downloadedPaths = <String>[];
    try {
      for (var i = 0; i < images.length; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final localPath = '${imagesDir.path}/${images[i]['file_name']}';
        downloadedPaths.add(localPath);
        onProgress((i + 1) / images.length);
      }
    } catch (e) {
      print('Lỗi khi tải ảnh chương: $e');
    }
    return downloadedPaths;
  }

  Future<bool> isChapterDownloaded(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File(
      '${downloadDir.path}/$storyId/$chapterId.json',
    );
    return chapterFile.exists();
  }

  Future<bool> isStoryDownloaded(int storyId) async {
    final downloadDir = await _downloadDirectory;
    final storyFile = File(
      '${downloadDir.path}/$storyId/story_info.json',
    );
    return storyFile.exists();
  }

  double getDownloadProgress(int chapterId) {
    return _downloadProgress[chapterId] ?? 0.0;
  }

  Future<void> deleteChapter(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File(
      '${downloadDir.path}/$storyId/$chapterId.json',
    );
    final chapterImagesDir = Directory(
      '${downloadDir.path}/$storyId/images/$chapterId',
    );

    if (await chapterFile.exists()) {
      await chapterFile.delete();
    }
    if (await chapterImagesDir.exists()) {
      await chapterImagesDir.delete(recursive: true);
    }
  }

  Future<List<Story>> fetchDownloadedStories() async {
    final downloadDir = await _downloadDirectory;
    final List<Story> downloadedStories = [];

    try {
      if (await downloadDir.exists()) {
        final List<FileSystemEntity> storyDirs = downloadDir.listSync();
        for (var dir in storyDirs) {
          if (dir is Directory) {
            final storyFile = File('${dir.path}/story_info.json');
            if (await storyFile.exists()) {
              final content = await storyFile.readAsString();
              final data = jsonDecode(content);
              downloadedStories.add(Story.fromJson(data));
            }
          }
        }
      }
    } catch (e) {
      print('lỗi download service : $e');
    }
    return downloadedStories;
  }

  Future<void> deleteStory(int storyId) async {
    final downloadDir = await _downloadDirectory;
    final storyDir = Directory('${downloadDir.path}/$storyId');

    if (await storyDir.exists()) {
      await storyDir.delete(recursive: true);
    }
  }
}
