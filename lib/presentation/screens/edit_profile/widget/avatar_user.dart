import 'dart:io';

import 'package:flutter/material.dart';

class AvatarUser extends StatelessWidget {
  final VoidCallback pickImage;
  final File? imageFile;
  final String? avataUrl;
  final bool isEditing;

  const AvatarUser({
    Key? key,
    required this.pickImage,
    required this.imageFile,
    required this.avataUrl,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: imageFile != null
              ? FileImage(imageFile!) as ImageProvider
              : NetworkImage(avataUrl ?? 'assets/avatar.png'),
        ),
        if (isEditing)
          GestureDetector(
            onTap: pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ),
      ],
    );
  }
}
