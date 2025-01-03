import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:story/core/services/story_service.dart';

import '../../models/chapter.dart';
import '../../models/image.dart';
import '../../models/story.dart';
import 'image_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  final ImageService _imageService = ImageService();
  final StoryService _storyService = StoryService();
  final Map<int, double> _downloadProgress = {};

  factory DownloadService() => _instance;

  DownloadService._internal();

  Future<Directory> get _downloadDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

// Download and save the cover image
  Future<String> _processStoryImage(String imageUrl, Directory storyDir) async {
    if (!imageUrl.startsWith('http')) {
      return imageUrl; // Return as-is if it's already a local path
    }

    try {
      final extension = path.extension(imageUrl).isNotEmpty
          ? path.extension(imageUrl)
          : '.jpg';
      final coverImagePath = '${storyDir.path}/cover$extension';
      final coverImageFile = File(coverImagePath);

      // Download and save the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await coverImageFile.writeAsBytes(response.bodyBytes);
        print('Successfully downloaded cover image to: $coverImagePath');
        return coverImagePath;
      } else {
        print('Failed to download cover image: ${response.statusCode}');
        return imageUrl; // Return original URL if download fails
      }
    } catch (e) {
      print('Error processing cover image: $e');
      return imageUrl; // Return original URL if there's an error
    }
  }

  Future<void> _saveStoryData({
    required Story story,
    required List<Chapter> chapters,
    required Directory storyDir,
  }) async {
    try {
      // Process the cover image first
      final localImagePath =
          await _processStoryImage(story.image_path, storyDir);

      final storyFile = File('${storyDir.path}/story_info.json');
      final storyData = {
        'id': story.story_id,
        'title': story.title,
        'author': story.author,
        'description': story.description,
        'image_path': localImagePath, // Use the processed image path
        'categories': story.categories,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'downloaded_at': DateTime.now().toIso8601String(),
      };

      print('Saving story data with processed image path: $localImagePath');
      await storyFile.writeAsString(jsonEncode(storyData));
    } catch (e) {
      print('Error saving story data: $e');
      throw Exception('Failed to save story data: $e');
    }
  }

  Future<void> downloadStory({
    required Story story,
    required List<Chapter> chapters,
    required Function(int chapterId, double progress) onProgress,
    required Function(int chapterId, String? error) onComplete,
  }) async {
    final downloadDir = await _downloadDirectory;
    final storyDir = Directory('${downloadDir.path}/${story.story_id}');
    final imagesDir = Directory('${storyDir.path}/images');

    try {
      // Create necessary directories
      await storyDir.create(recursive: true);
      await imagesDir.create(recursive: true);

      // Fetch complete story details
      final storyDetail =
          await _storyService.fetchStoriesDetail(story.story_id);

      // Save story metadata with downloaded cover image
      await _saveStoryData(
        story: storyDetail,
        chapters: chapters,
        storyDir: storyDir,
      );

      // Process chapters in batches of 3
      final chunks = chapters
          .map((chapter) => () async {
                try {
                  final chapterImages =
                      await _imageService.fetchImage(chapter.chapter_id);
                  await _downloadChapter(
                    story: story,
                    chapter: chapter,
                    storyDir: storyDir,
                    images: chapterImages,
                    onProgress: (progress) =>
                        onProgress(chapter.chapter_id, progress),
                  );
                  onComplete(chapter.chapter_id, null);
                } catch (e) {
                  print('Error downloading chapter ${chapter.chapter_id}: $e');
                  onComplete(chapter.chapter_id, e.toString());
                }
              })
          .toList();

      for (var i = 0; i < chunks.length; i += 3) {
        final batch = chunks.skip(i).take(3);
        await Future.wait(batch.map((download) => download()));
      }
    } catch (e) {
      print('Error in downloadStory(): $e');
      throw Exception('Failed to download story: $e');
    }
  }

  Future<void> _downloadChapter({
    required Story story,
    required Chapter chapter,
    required Directory storyDir,
    required List<ImagePath> images,
    required Function(double progress) onProgress,
  }) async {
    try {
      final chapterFile = File('${storyDir.path}/${chapter.chapter_id}.json');
      final chapterImagesDir =
          Directory('${storyDir.path}/images/${chapter.chapter_id}');

      // Check if already downloaded
      if (await chapterFile.exists()) {
        print('Chapter ${chapter.chapter_id} already downloaded');
        onProgress(1.0);
        return;
      }

      // Ensure images directory exists
      if (!await chapterImagesDir.exists()) {
        await chapterImagesDir.create(recursive: true);
      }

      // Download images - 80% of progress weight
      final downloadedImages = await _downloadImages(
        images,
        chapterImagesDir,
        (progress) => onProgress(progress * 0.8),
      );

      // Save chapter metadata with image references
      final chapterData = {
        'story_id': story.story_id,
        'chapter_id': chapter.chapter_id,
        'title': chapter.title,
        'image_paths': downloadedImages,
        'downloaded_at': DateTime.now().toIso8601String(),
      };
      print('chapterData ${chapterData}');

      await chapterFile.writeAsString(jsonEncode(chapterData));
      onProgress(1.0);
    } catch (e) {
      print('Error downloading chapter ${chapter.chapter_id}: $e');
      // Consider deleting partially downloaded content in case of failure
      rethrow;
    }
  }

  // Download and save images with proper error handling
  Future<List<String>> _downloadImages(
    List<ImagePath> images,
    Directory imagesDir,
    Function(double progress) onProgress,
  ) async {
    final downloadedPaths = <String>[];
    final client = http.Client();

    try {
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final localPath = '${imagesDir.path}/${image.file_name}';
        final imageFile = File(localPath);
        print(localPath);
        print(imageFile);
        // Download and save image
        final response = await client.get(Uri.parse(image.path));
        if (response.statusCode == 200) {
          await imageFile.writeAsBytes(response.bodyBytes);
          downloadedPaths.add(localPath);
        }

        onProgress((i + 1) / images.length);
      }
    } catch (e) {
      print('Error downloading images: $e');
    } finally {
      client.close();
    }
    return downloadedPaths;
  }

  // Utility methods for checking download status
  Future<bool> isChapterDownloaded(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File('${downloadDir.path}/$storyId/$chapterId.json');
    return chapterFile.exists();
  }

  Future<bool> isStoryDownloaded(int storyId) async {
    final downloadDir = await _downloadDirectory;
    final storyFile = File('${downloadDir.path}/$storyId/story_info.json');
    return storyFile.exists();
  }

  // Get current download progress
  double getDownloadProgress(int chapterId) {
    return _downloadProgress[chapterId] ?? 0.0;
  }

  // Delete downloaded content
  Future<void> deleteChapter(int storyId, int chapterId) async {
    final downloadDir = await _downloadDirectory;
    final chapterFile = File('${downloadDir.path}/$storyId/$chapterId.json');
    final chapterImagesDir =
        Directory('${downloadDir.path}/$storyId/images/$chapterId');

    if (await chapterFile.exists()) await chapterFile.delete();
    if (await chapterImagesDir.exists()) {
      await chapterImagesDir.delete(recursive: true);
    }
  }

  Future<void> deleteStory(int storyId) async {
    final downloadDir = await _downloadDirectory;
    final storyDir = Directory('${downloadDir.path}/$storyId');

    if (await storyDir.exists()) {
      await storyDir.delete(recursive: true);
    }
  }

  Future<void> clearAllDownloads() async {
    final downloadDir = await _downloadDirectory;
    if (await downloadDir.exists()) {
      await downloadDir.delete(recursive: true);
      print('All downloaded content has been cleared.');
    } else {
      print('No downloaded content found to clear.');
    }
  }
}
