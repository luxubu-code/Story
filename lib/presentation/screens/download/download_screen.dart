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
    final isStoryDownloaded = await _downloadService.isStoryDownloaded(
      widget.story.story_id,
    );

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
        chapterImages: [],
        // TODO: Pass actual chapter images
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

  Widget _buildStoryHeader() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.story.image_path,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 120,
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
                    widget.story.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tác giả: ${widget.story.author}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: downloadProgress.isEmpty
                        ? 0
                        : downloadProgress.values
                        .where((value) => value == 1.0)
                        .length /
                        totalChapters,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${downloadProgress.values
                        .where((value) => value == 1.0)
                        .length}/$totalChapters chương đã tải',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: totalChapters,
      itemBuilder: (context, index) {
        final chapter = widget.chapters[index];
        final progress = downloadProgress[chapter.chapter_id] ?? 0.0;
        final isDownloaded = progress == 1.0;

        return InkWell(
          onTap: isDownloading ? null : () => toggleChapter(chapter.chapter_id),
          child: Container(
            decoration: BoxDecoration(
              color: selectedChapters.contains(chapter.chapter_id)
                  ? Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.8)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDownloaded ? Colors.green : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Chương ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      chapter.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                      minHeight: 3,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tải truyện về máy"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStoryHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đã chọn: ${selectedChapters.length}/$totalChapters chương",
                  style: const TextStyle(fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: isDownloading
                      ? null
                      : () =>
                      toggleSelectAll(
                        selectedChapters.length != totalChapters,
                      ),
                  icon: Icon(
                    selectedChapters.length == totalChapters
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  label: Text(
                    selectedChapters.length == totalChapters
                        ? "Bỏ chọn tất cả"
                        : "Chọn tất cả",
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildChapterGrid(),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: Theme
                      .of(context)
                      .dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDownloading ? null : startDownload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: isDownloading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.download),
                    label: Text(
                      isDownloading
                          ? "Đang tải ${downloadProgress.values
                          .where((v) => v == 1.0)
                          .length}/${selectedChapters.length} chương..."
                          : "Tải ${selectedChapters.length} chương đã chọn",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
