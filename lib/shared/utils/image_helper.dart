import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider? getProfileImageProvider(String? path) {
  if (path == null || path.isEmpty) {
    return null; // Let the widget handle the fallback (e.g., show emoji)
  }
  if (path.startsWith('http') || path.startsWith('https')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
