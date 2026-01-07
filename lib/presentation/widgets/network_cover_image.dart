import 'package:flutter/material.dart';

/// NetworkCoverImage
///
/// A small helper that wraps `Image.network` to add error reporting
/// and a visible retry UI when an image fails to load (useful for
/// diagnosing emulator TLS/SSL issues). Tapping the retry icon
/// forces the image to reload.
class NetworkCoverImage extends StatefulWidget {
  const NetworkCoverImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  State<NetworkCoverImage> createState() => _NetworkCoverImageState();
}

class _NetworkCoverImageState extends State<NetworkCoverImage> {
  // Incrementing this value forces Image.network to rebuild and retry.
  int _reloadCounter = 0;

  void _retry() {
    setState(() => _reloadCounter++);
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      key: ValueKey('${widget.url}#$_reloadCounter'),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      // When image load fails (e.g. SSL handshake), show a clear
      // placeholder with a retry button so the user can attempt reload
      // and we print the error for investigation.
      errorBuilder: (context, error, stackTrace) {
        // Log the error to console to help debugging network/TLS issues.
        // This is intentional diagnostic output.
        // ignore: avoid_print
        print('NetworkCoverImage failed to load ${widget.url}: $error');

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 28, color: Colors.white),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      color: Colors.white,
                      onPressed: _retry,
                      tooltip: 'Retry',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
