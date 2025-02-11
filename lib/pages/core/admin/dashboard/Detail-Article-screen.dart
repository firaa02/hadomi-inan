import 'package:flutter/material.dart';
import 'dart:convert';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> articleData;

  const ArticleDetailScreen({Key? key, required this.articleData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                articleData['title'],
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
              background: _buildThumbnail(),
            ),
            backgroundColor: const Color(0xFF6B57D2),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildArticleMetadata(),
                const SizedBox(height: 16),
                _buildArticleContent(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (articleData['thumbnailBase64'] != null) {
      try {
        final imageBytes = base64Decode(articleData['thumbnailBase64']);
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        );
      } catch (e) {
        return _buildPlaceholderImage();
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
    );
  }

  Widget _buildArticleMetadata() {
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
            articleData['category'],
            style: const TextStyle(
              color: Color(0xFF6B57D2),
              fontSize: 14,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.timer, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${articleData['readTime']} menit baca',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleContent() {
    // Untuk artikel dengan struktur sections yang kompleks
    if (articleData['sections'] != null && articleData['sections'] is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (articleData['sections'] as List).map<Widget>((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section['title'] != null)
                  Text(
                    section['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  section['content'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Fallback jika tidak ada struktur sections
    return Text(
      articleData['description'] ?? 'Tidak ada konten',
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
}
