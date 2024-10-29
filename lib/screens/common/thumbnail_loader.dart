import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/thumbnail_provider.dart';

class ThumbnailLoader extends StatefulWidget {
  final int userId;

  const ThumbnailLoader({
    super.key,
    required this.userId,
  });

  @override
  _ThumbnailLoaderState createState() => _ThumbnailLoaderState();
}

class _ThumbnailLoaderState extends State<ThumbnailLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final thumbnailProvider =
          Provider.of<ThumbnailProvider>(context, listen: false);
      if (thumbnailProvider.getThumbnail(widget.userId) == null) {
        thumbnailProvider.loadThumbnail(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailProvider = Provider.of<ThumbnailProvider>(context);
    final thumbnail = thumbnailProvider.getThumbnail(widget.userId);
    final isLoading = thumbnailProvider.isLoading(widget.userId);

    return CircleAvatar(
      radius: 30,
      backgroundImage: thumbnail != null ? MemoryImage(thumbnail) : null,
      child: isLoading
          ? const CircularProgressIndicator()
          : thumbnail == null
              ? const Icon(Icons.person, size: 30)
              : null,
    );
  }
}
