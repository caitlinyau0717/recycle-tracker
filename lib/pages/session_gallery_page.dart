import 'dart:io';
import 'package:flutter/material.dart';

class SessionGalleryPage extends StatefulWidget {
  final List<File> images;
  final Function(File) onDelete;

  const SessionGalleryPage({
    super.key,
    required this.images,
    required this.onDelete,
  });

  @override
  State<SessionGalleryPage> createState() => _SessionGalleryPageState();
}

class _SessionGalleryPageState extends State<SessionGalleryPage> {
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images); // Local copy
  }

  void _confirmDelete(File image) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Photo?"),
        content: const Text("Are you sure you want to delete this photo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() => _images.remove(image));
              widget.onDelete(image);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Gallery'),
        backgroundColor: const Color(0xFF609966),
      ),
      body: _images.isEmpty
          ? const Center(child: Text('No photos this session.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final image = _images[index];
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(image, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                          onPressed: () => _confirmDelete(image),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
