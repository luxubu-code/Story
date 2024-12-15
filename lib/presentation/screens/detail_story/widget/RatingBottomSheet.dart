import 'package:flutter/material.dart';
import 'package:story/core/services/rating_service.dart';

class RatingBottomSheet extends StatefulWidget {
  final int storyId;
  final Function() onRatingSubmitted;

  const RatingBottomSheet({
    Key? key,
    required this.storyId,
    required this.onRatingSubmitted,
  }) : super(key: key);

  // Static method to show the bottom sheet
  static Future<void> show(
      BuildContext context, int storyId, Function() onRatingSubmitted) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingBottomSheet(
        storyId: storyId,
        onRatingSubmitted: onRatingSubmitted,
      ),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  // Controllers and state variables
  final TextEditingController _titleController = TextEditingController();
  int _selectedRating = 5;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Method to handle rating submission
  Future<void> _submitRating() async {
    // Validate input
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Chưa nhập tiêu đề');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the rating service
      final success = await RatingService().postRatings(
        widget.storyId,
        _selectedRating,
        _titleController.text.trim(),
      );

      if (success) {
        Navigator.pop(context);
        widget.onRatingSubmitted();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('đánh giá thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _errorMessage = 'đánh giá thất bại');
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust bottom sheet
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                'Đánh giá truyện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () =>
                        setState(() => _selectedRating = index + 1),
                  );
                }),
              ),
              SizedBox(height: 20),

              // Review Title Input
              TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Viết đánh giá của bạn...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _errorMessage,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Đồng Ý',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
