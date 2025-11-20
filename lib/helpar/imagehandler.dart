import 'package:flutter/cupertino.dart';

class NetworkImageWithFallback extends StatefulWidget {
  final String networkUrl;
  final String assetImagePath;

  const NetworkImageWithFallback({super.key,
    required this.networkUrl,
    required this.assetImagePath,
  });

  @override
  _NetworkImageWithFallbackState createState() => _NetworkImageWithFallbackState();
}

class _NetworkImageWithFallbackState extends State<NetworkImageWithFallback> {
  bool _loadFailed = false;

  @override
  Widget build(BuildContext context) {
    return _loadFailed
        ? Image.asset(widget.assetImagePath)
        : Image.network(
      widget.networkUrl,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        setState(() {
          _loadFailed = true;
        });
        return Image.asset(widget.assetImagePath);
      },
    );
  }
}