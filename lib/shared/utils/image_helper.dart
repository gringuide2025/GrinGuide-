import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getProfileImageProvider(String? path) {
  if (path == null || path.isEmpty) {
    return const AssetImage('assets/images/logo.png'); // Default or use Icon logic in widget
  }
  if (path.startsWith('http') || path.startsWith('https')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
