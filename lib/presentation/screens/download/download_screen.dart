import 'package:flutter/material.dart';

import '../../../core/services/download_service.dart';
import '../../../models/chapter.dart';
import '../../../models/story.dart';

class DownloadScreen extends StatefulWidget {
  final Story story;
  final List<Chapter> chapters;

  const DownloadScreen({
    super.key,
    required this.story,
    required this.chapters,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late int totalChapters;
  late List<int> selectedChapters;
  final Map<int, double> downloadProgress = {};
  final DownloadService _downloadService = DownloadService();
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    totalChapters = widget.chapters.length;
    selectedChapters = widget.chapters.map((c) => c.chapter_id).toList();
    _initializeDownloadStatus();
  }

  Future<void> _initializeDownloadStatus() async {
    for (var chapter in widget.chapters) {
      final isDownloaded = await _downloadService.isChapterDownloaded(
        widget.story.story_id,
        chapter.chapter_id,
      );
      if (isDownloaded) {
        setState(() {
          downloadProgress[chapter.chapter_id] = 1.0;
        });
      }
    }
  }

  void toggleChapter(int chapterId) {
    setState(() {
      if (selectedChapters.contains(chapterId)) {
        selectedChapters.remove(chapterId);
      } else {
        selectedChapters.add(chapterId);
      }
    });
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedChapters = widget.chapters.map((c) => c.chapter_id).toList();
      } else {
        selectedChapters.clear();
      }
    });
  }

  Future<void> startDownload() async {
    if (selectedChapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một chương')),
      );
      return;
    }

    setState(() {
      isDownloading = true;
    });

    try {
      final chaptersToDownload = widget.chapters
          .where((c) => selectedChapters.contains(c.chapter_id))
          .toList();

      await _downloadService.downloadChapters(
        story: widget.story,
        chapters: chaptersToDownload,
        onProgress: (chapterId, progress) {
          setState(() {
            downloadProgress[chapterId] = progress;
          });
        },
        onComplete: (chapterId, error) {
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tải chương $chapterId: $error')),
            );
          }
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tải xuống hoàn tất')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn chương tải về"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tổng $totalChapters chương",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Đã chọn: ${selectedChapters.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: totalChapters,
              itemBuilder: (context, index) {
                final chapter = widget.chapters[index];
                final progress = downloadProgress[chapter.chapter_id] ?? 0.0;
                final isDownloaded = progress == 1.0;

                return GestureDetector(
                  onTap: isDownloading
                      ? null
                      : () => toggleChapter(chapter.chapter_id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedChapters.contains(chapter.chapter_id)
                          ? Colors.blue
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "${chapter.chapter_id}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (isDownloaded)
                          const Positioned(
                            right: 4,
                            top: 4,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                        if (progress > 0 && !isDownloaded)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: selectedChapters.length == totalChapters,
                      onChanged: isDownloading ? null : toggleSelectAll,
                    ),
                    const Text(
                      "Chọn tất cả",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isDownloading ? null : startDownload,
                  icon: isDownloading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download),
                  label: Text(isDownloading ? "Đang tải..." : "Tải xuống"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
