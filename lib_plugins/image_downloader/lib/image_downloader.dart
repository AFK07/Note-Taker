import 'package:flutter/services.dart';

class ImageDownloader {
  static const MethodChannel _channel = MethodChannel('image_downloader');

  static Future<String?> downloadImage(String url) async {
    final String? path = await _channel.invokeMethod('downloadImage', {
      'url': url,
    });
    return path;
  }
}
