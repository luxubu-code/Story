import 'package:flutter/material.dart';

import '../../../core/services/download_service.dart';
import '../../../models/chapter.dart';
import '../../../models/story.dart';

enum DownloadStatus { notStarted, inProgress, completed, error }

class ChapterDownloadInfo {
  final Chapter chapter;
  final DownloadStatus status;
  final double progress;
  final String? error;

  ChapterDownloadInfo({
    required this.chapter,
    this.status = DownloadStatus.notStarted,
    this.progress = 0.0,
    this.error,
  });

  ChapterDownloadInfo copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
  }) {
    return ChapterDownloadInfo(
      chapter: chapter,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

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

class _DownloadScreenState extends State<DownloadScreen>
    with SingleTickerProviderStateMixin {
  final Map<int, ChapterDownloadInfo> _chaptersInfo = {};
  final Set<int> _selectedChapters = {};
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeChaptersInfo();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeChaptersInfo() async {
    for (var chapter in widget.chapters) {
      final isDownloaded = await _downloadService.isChapterDownloaded(
        widget.story.story_id,
        chapter.chapter_id,
      );

      setState(() {
        _chaptersInfo[chapter.chapter_id] = ChapterDownloadInfo(
          chapter: chapter,
          status: isDownloaded
              ? DownloadStatus.completed
              : DownloadStatus.notStarted,
          progress: isDownloaded ? 1.0 : 0.0,
        );
        if (isDownloaded) {
          _selectedChapters.add(chapter.chapter_id);
        }
      });
    }
  }

  void _toggleChapter(int chapterId) {
    if (_isDownloading) return;

    setState(() {
      if (_selectedChapters.contains(chapterId)) {
        _selectedChapters.remove(chapterId);
        _animationController.reverse();
      } else {
        _selectedChapters.add(chapterId);
        _animationController.forward();
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    if (_isDownloading) return;

    setState(() {
      if (value == true) {
        _selectedChapters.addAll(widget.chapters.map((c) => c.chapter_id));
        _animationController.forward();
      } else {
        _selectedChapters.clear();
        _animationController.reverse();
      }
    });
  }

  Future<void> _startDownload() async {
    if (_selectedChapters.isEmpty) {
      _showMessage('Vui lòng chọn ít nhất một chương', isError: true);
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final chaptersToDownload = widget.chapters
          .where((c) => _selectedChapters.contains(c.chapter_id))
          .toList();

      await _downloadService.downloadChapters(
        story: widget.story,
        chapters: chaptersToDownload,
        onProgress: _updateDownloadProgress,
        onComplete: _handleDownloadComplete,
      );

      _showMessage('Tải xuống hoàn tất', isSuccess: true);
    } catch (e) {
      _showMessage('Lỗi: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _updateDownloadProgress(int chapterId, double progress) {
    setState(() {
      final info = _chaptersInfo[chapterId];
      if (info != null) {
        _chaptersInfo[chapterId] = info.copyWith(
          status: DownloadStatus.inProgress,
          progress: progress,
        );
      }
    });
  }

  void _handleDownloadComplete(int chapterId, String? error) {
    setState(() {
      final info = _chaptersInfo[chapterId];
      if (info != null) {
        _chaptersInfo[chapterId] = info.copyWith(
          status:
              error == null ? DownloadStatus.completed : DownloadStatus.error,
          error: error,
        );
      }
    });

    if (error != null) {
      _showMessage('Lỗi tải chương $chapterId: $error', isError: true);
    }
  }

  void _showMessage(String message,
      {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error
                  : (isSuccess ? Icons.check_circle : Icons.info),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? Colors.red : (isSuccess ? Colors.green : null),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.book, size: 20),
              const SizedBox(width: 8),
              Text(
                "Tổng ${widget.chapters.length} chương",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  "Đã chọn: ${_selectedChapters.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: widget.chapters.length,
      itemBuilder: _buildChapterTile,
    );
  }

  Widget _buildChapterTile(BuildContext context, int index) {
    final chapter = widget.chapters[index];
    final info = _chaptersInfo[chapter.chapter_id];
    final isSelected = _selectedChapters.contains(chapter.chapter_id);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _toggleChapter(chapter.chapter_id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _getChapterTileColor(isSelected, info?.status),
              borderRadius: BorderRadius.circular(12),
              border: info?.status == DownloadStatus.error
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chương",
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${chapter.chapter_id}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (info?.status == DownloadStatus.completed)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                if (info?.status == DownloadStatus.inProgress)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LinearProgressIndicator(
                        value: info?.progress ?? 0.0,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade300,
                        ),
                      ),
                    ),
                  ),
                if (info?.status == DownloadStatus.error)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getChapterTileColor(bool isSelected, DownloadStatus? status) {
    if (status == DownloadStatus.error) {
      return Colors.red[900]!.withOpacity(0.8);
    }
    if (isSelected) {
      return Colors.blue.withOpacity(0.9);
    }
    return Colors.grey[800]!.withOpacity(0.8);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _selectedChapters.length == widget.chapters.length,
                    onChanged: _isDownloading ? null : _toggleSelectAll,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Chọn tất cả",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isDownloading ? 160 : 140,
              height: 44,
              child: ElevatedButton(
                onPressed: _isDownloading ? null : _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                  shadowColor: Colors.black26,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isDownloading)
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(
                        Icons.download_rounded,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isDownloading ? "Đang tải..." : "Tải xuống",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadStats() {
    final completedDownloads = _chaptersInfo.values
        .where((info) => info.status == DownloadStatus.completed)
        .length;
    final inProgressDownloads = _chaptersInfo.values
        .where((info) => info.status == DownloadStatus.inProgress)
        .length;
    final failedDownloads = _chaptersInfo.values
        .where((info) => info.status == DownloadStatus.error)
        .length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isDownloading ? 60 : 0,
      color: Colors.black87,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                color: Colors.green,
                count: completedDownloads,
                label: "Hoàn thành",
              ),
              _buildStatItem(
                icon: Icons.downloading,
                color: Colors.blue,
                count: inProgressDownloads,
                label: "Đang tải",
              ),
              _buildStatItem(
                icon: Icons.error,
                color: Colors.red,
                count: failedDownloads,
                label: "Lỗi",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          "$count",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildChapterGrid()),
          _buildDownloadStats(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // Add new methods for better user interaction
  Future<void> _handleRetryFailedDownloads() async {
    final failedChapters = _chaptersInfo.values
        .where((info) => info.status == DownloadStatus.error)
        .map((info) => info.chapter)
        .toList();

    if (failedChapters.isEmpty) {
      _showMessage('Không có chương nào cần tải lại', isError: true);
      return;
    }

    setState(() {
      for (var chapter in failedChapters) {
        _selectedChapters.add(chapter.chapter_id);
        _chaptersInfo[chapter.chapter_id] = ChapterDownloadInfo(
          chapter: chapter,
          status: DownloadStatus.notStarted,
        );
      }
    });

    await _startDownload();
  }

  Future<void> _showOptionsDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tùy chọn tải xuống'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionButton(
              icon: Icons.refresh,
              label: 'Tải lại các chương lỗi',
              onTap: () {
                Navigator.of(context).pop();
                _handleRetryFailedDownloads();
              },
            ),
            const SizedBox(height: 8),
            _buildOptionButton(
              icon: Icons.delete_outline,
              label: 'Xóa tất cả đã tải',
              onTap: () {
                // Implement delete functionality
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        children: [
          const Text(
            "Chọn chương tải về",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.story.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showOptionsDialog,
        ),
      ],
    );
  }
}
