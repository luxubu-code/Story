import 'package:flutter/material.dart';
import 'package:story/presentation/screens/detail_story/widget/Ratings_widget.dart';

import '../../../../core/services/rating_service.dart';
import '../../../../models/ratings.dart';
import 'RatingBottomSheet.dart';

class BodyRating extends StatefulWidget {
  final int story_id;

  const BodyRating({super.key, required this.story_id});

  @override
  State<BodyRating> createState() => _BodyRatingState();
}

class _BodyRatingState extends State<BodyRating> {
  late Future<List<Ratings>> _futureRatings;
  final RatingService _ratingService = RatingService();

  @override
  void initState() {
    super.initState();
    _futureRatings = _ratingService.fetchRatings(widget.story_id);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content wrapped in a Container for proper constraints
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: FutureBuilder<List<Ratings>>(
            future: _futureRatings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error loading ratings',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              final ratings = snapshot.data ?? [];

              if (ratings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có đánh giá',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Trở thành người đầu tiên đánh giá!',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: ratings.length,
                itemBuilder: (context, index) {
                  return RatingsWidget(
                    story_id: widget.story_id,
                    ratings: ratings[index], // Pass a single rating object
                  );
                },
              );
            },
          ),
        ),

        // FloatingActionButton is always visible
        Positioned(
          right: 10,
          bottom: 0,
          child: FloatingActionButton(
            onPressed: () {
              RatingBottomSheet.show(
                context,
                widget.story_id,
                () {
                  setState(() {
                    _futureRatings =
                        _ratingService.fetchRatings(widget.story_id);
                  });
                },
              );
            },
            backgroundColor: Colors.pinkAccent,
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
