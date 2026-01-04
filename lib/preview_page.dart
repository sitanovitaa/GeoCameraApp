import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final File imageFile;

  const PreviewPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        // WIDGET HERO: Tag harus SAMA dengan tag di halaman asal
        child: Hero(
          tag: 'foto_hasil',
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
