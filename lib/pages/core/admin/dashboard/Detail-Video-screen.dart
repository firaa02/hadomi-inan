import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> videoData;

  const VideoDetailScreen({Key? key, required this.videoData})
      : super(key: key);

  Future<void> _launchYouTubeVideo() async {
    try {
      final videoId = _extractVideoId(videoData['videoUrl']);

      // Try launching YouTube app first
      final appUrl = Uri.parse('youtube://watch?v=$videoId');
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
        return;
      }

      // Fallback to web browser
      final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
      await launchUrl(
        webUrl,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } catch (e) {
      debugPrint('Error launching video: $e');
      // Show error to user
      throw 'Could not launch video. Please check your internet connection and try again.';
    }
  }

  String _extractVideoId(String url) {
    final regExp = RegExp(
        r'(?:youtu\.be\/|youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains the same
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                videoData['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://img.youtube.com/vi/${_extractVideoId(videoData['videoUrl'])}/maxresdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.video_library, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                      onPressed: _launchYouTubeVideo,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF6B57D2),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildVideoMetadata(videoData),
                const SizedBox(height: 16),
                Text(
                  videoData['description'] ?? 'Tidak ada deskripsi',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoMetadata(Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6B57D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data['category'],
            style: const TextStyle(
              color: Color(0xFF6B57D2),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          data['date'],
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}
