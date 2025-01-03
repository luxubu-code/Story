import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/chapter.dart';
import '../../../models/story.dart';

class ChapterViewerScreen extends StatefulWidget {
  final Story story;
  final Chapter chapter;

  const ChapterViewerScreen({
    super.key,
    required this.story,
    required this.chapter,
  });

  @override
  State<ChapterViewerScreen> createState() => _ChapterViewerScreenState();
}

class _ChapterViewerScreenState extends State<ChapterViewerScreen> {
  List<String> _imagePaths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapterImages();
  }

  Future<void> _loadChapterImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chapterFile = File(
        '${appDir.path}/downloads/${widget.story.story_id}/${widget.chapter.chapter_id}.json',
      );

      if (await chapterFile.exists()) {
        final chapterData = jsonDecode(await chapterFile.readAsString());
        setState(() {
          _imagePaths = List<String>.from(chapterData['image_paths']);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chapter images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imagePaths.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy hình ảnh',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    if (!File(_imagePaths[index]).existsSync()) {
                      print('Image not found: ${_imagePaths[index]}');
                    }

                    return Image.file(
                      File(_imagePaths[index]),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
