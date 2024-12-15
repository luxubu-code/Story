import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<int> selectedChapters = [];
  final int totalChapters = 422;

  void toggleChapter(int chapter) {
    setState(() {
      if (selectedChapters.contains(chapter)) {
        selectedChapters.remove(chapter);
      } else {
        selectedChapters.add(chapter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn chương tải về xuống"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hiển thị tổng chương
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Tổng $totalChapters chap",
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          Expanded(
            // Hiển thị Grid các chương
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 cột
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: 33,
              itemBuilder: (context, index) {
                final chapterNumber = index + 1;
                return GestureDetector(
                  onTap: () {
                    toggleChapter(chapterNumber);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedChapters.contains(chapterNumber)
                          ? Colors.blue
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "$chapterNumber",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Hiển thị phần chọn tất cả và tải xuống
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
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedChapters = List.generate(
                                totalChapters, (index) => index + 1);
                          } else {
                            selectedChapters.clear();
                          }
                        });
                      },
                    ),
                    const Text(
                      "Chọn tất cả",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Hành động tải xuống
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Tải Xuống"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
