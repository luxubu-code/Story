import 'package:flutter/material.dart';

import '../../../../models/story.dart';
import '../../detail_story/detail_story_screen.dart';

class StoryCard extends StatelessWidget {
  final Story story;

  // Define constants for better maintainability
  static const double _borderRadius = 10.0;
  static const double _opacity = 0.8;
  static const double _padding = 10.0;
  static const double _thumbnailWidth = 80.0;
  static const double _thumbnailHeight = 120.0;
  static const double _spacing = 10.0;

  const StoryCard({
    Key? key,
    required this.story,
  }) : super(key: key);

  void _navigateToStoryDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailStoryScreen(
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
        child: SizedBox(
          // Add SizedBox to maintain consistent height
          height: 140, // Fixed height for the card
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildOverlay(),
              _buildContent(),
            ],
          ),
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
          return Container(
            color: Colors.grey[700],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white60),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        gradient: LinearGradient(
          // Use gradient for better readability
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black.withOpacity(_opacity),
            Colors.black.withOpacity(_opacity * 0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to top
        children: [
          Expanded(
            child: _buildTextContent(),
          ),
          const SizedBox(width: _spacing),
          _buildThumbnail(),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (story.title?.isNotEmpty ?? false) ...[
          Text(
            story.title!,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _spacing),
        ],
        if (story.description?.isNotEmpty ?? false) ...[
          const Text(
            'Description',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              story.description!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: Image.network(
        story.image_path,
        width: _thumbnailWidth,
        height: _thumbnailHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: _thumbnailWidth,
            height: _thumbnailHeight,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white60),
            ),
          );
        },
      ),
    );
  }
}
