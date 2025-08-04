import 'dart:io';
import 'package:flutter/material.dart';

class SessionGalleryPage extends StatelessWidget {
  final List<File> images;

  const SessionGalleryPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Gallery'),
        backgroundColor: const Color(0xFF609966),
      ),
      body: images.isEmpty
          ? const Center(child: Text('No photos this session.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Image.file(images[index], fit: BoxFit.cover);
              },
            ),
    );
  }
}
