// Lấy số ngày từ Duration
String time(DateTime createdAt) {
  Duration difference = DateTime.now().difference(createdAt);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} phút trước';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  } else {
    return '${difference.inDays} ngày trước';
  }
}
