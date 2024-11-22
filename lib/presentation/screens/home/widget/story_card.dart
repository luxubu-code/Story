import 'package:flutter/material.dart';

import '../../../../models/story.dart';
import '../../detail_story/story_detail.dart';

class StoryCard extends StatelessWidget {
  final Story story;

  static const double _borderRadius = 10.0;
  static const double _opacity = 0.8;

  const StoryCard({
    Key? key,
    required this.story,
  }) : super(key: key);

  void _navigateToStoryDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailPage(
          story_id: story.story_id,
          onShowComments: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToStoryDetail(context),
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Stack(
          children: [
            _buildBackgroundImage(),
            _buildOverlay(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Image.network(
        story.image_path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        color: Colors.black.withOpacity(_opacity),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Flexible(
            child: _buildTextContent(),
          ),
          const SizedBox(width: 10),
          _buildThumbnail(),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    const TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    const TextStyle descriptionStyle = TextStyle(
      color: Colors.white,
      fontSize: 8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            story.title,
            maxLines: 2,
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Text(
          'Description',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Text(
            story.description,
            style: descriptionStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Image.network(
        story.image_path,
        width: 80,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 80,
            height: 120,
            child: Center(child: Icon(Icons.error)),
          );
        },
      ),
    );
  }
}
