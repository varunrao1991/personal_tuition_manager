import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:padmayoga/services/token_service.dart';
import '../services/thumbnail_service.dart';

class ThumbnailProvider with ChangeNotifier {
  final ThumbnailService _thumbnailService;
  final TokenService _tokenService;

  ThumbnailProvider(this._thumbnailService, this._tokenService);

  final Map<int, Uint8List?> _thumbnailCache = {};
  final Map<int, bool> _loadingStatus = {};

  Uint8List? getThumbnail(int userId) => _thumbnailCache[userId];
  bool isLoading(int userId) => _loadingStatus[userId] ?? false;

  Future<void> loadThumbnail(int userId) async {
    if (_thumbnailCache.containsKey(userId) && _thumbnailCache[userId] != null) {
      return;
    }

    _loadingStatus[userId] = true;
    notifyListeners();

    try {
      final accessToken = await _tokenService.getToken();
      final thumbnail =
          await _thumbnailService.fetchProfileThumbnail(accessToken, userId);
      _thumbnailCache[userId] = thumbnail;
    } catch (error) {
      _thumbnailCache[userId] = null;
    } finally {
      _loadingStatus[userId] = false;
      notifyListeners();
    }
  }
}
