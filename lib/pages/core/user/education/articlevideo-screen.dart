import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'
    show launchUrl, canLaunchUrl, LaunchMode;
import 'dart:convert';
import 'detail-article.dart';

class ArticleVideoScreen extends StatefulWidget {
  const ArticleVideoScreen({super.key});

  @override
  State<ArticleVideoScreen> createState() => _ArticleVideoScreenState();
}

class _ArticleVideoScreenState extends State<ArticleVideoScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'Semua',
    'Kehamilan',
    'Persalinan',
    'Nutrisi',
    'Perawatan Bayi',
  ];

  List<Map<String, dynamic>> _articles = [];
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      QuerySnapshot articlesSnapshot = await FirebaseFirestore.instance
          .collection('articles')
          .orderBy('date', descending: true)
          .get();

      QuerySnapshot videosSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _articles = articlesSnapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList();

        _videos = videosSnapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching content: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load content: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Artikel & Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Artikel'),
            Tab(text: 'Video'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildArticlesTab(),
                _buildVideosTab(),
              ],
            ),
    );
  }

  Widget _buildArticlesTab() {
    List<Map<String, dynamic>> filteredArticles = _selectedCategoryIndex == 0
        ? _articles
        : _articles
            .where((article) =>
                article['category'] == categories[_selectedCategoryIndex])
            .toList();

    return RefreshIndicator(
      onRefresh: _fetchContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildCategoryFilters(),
            filteredArticles.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada artikel tersedia'),
                  )
                : _buildArticlesList(filteredArticles),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    List<Map<String, dynamic>> filteredVideos = _selectedCategoryIndex == 0
        ? _videos
        : _videos
            .where((video) =>
                video['category'] == categories[_selectedCategoryIndex])
            .toList();

    return RefreshIndicator(
      onRefresh: _fetchContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildCategoryFilters(),
            filteredVideos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada video tersedia'),
                  )
                : _buildVideosList(filteredVideos),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categories[index]),
              selected: index == _selectedCategoryIndex,
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategoryIndex = selected ? index : 0;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF6B57D2).withOpacity(0.2),
              labelStyle: TextStyle(
                color: index == _selectedCategoryIndex
                    ? const Color(0xFF6B57D2)
                    : Colors.grey[600],
                fontWeight: index == _selectedCategoryIndex
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesList(List<Map<String, dynamic>> articles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: articles.map((article) {
          return Column(
            children: [
              _buildArticleItem(article),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideosList(List<Map<String, dynamic>> videos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: videos.map((video) {
          return Column(
            children: [
              _buildVideoItem(video),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArticleItem(Map<String, dynamic> article) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailArticleScreen(articleId: article['id']),
          ),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: article['thumbnailBase64'] != null
                    ? Image.memory(
                        base64.decode(
                            article['thumbnailBase64']!.split(',').last),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error,
                                  size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child:
                              Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryChip(article['category'] ?? ''),
                      const SizedBox(width: 8),
                      Text(
                        '${article['readTime'] ?? ''} menit baca',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article['date'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () async {
          final Uri? videoUrl = Uri.tryParse(video['videoUrl'] ?? '');
          if (videoUrl != null) {
            try {
              if (await canLaunchUrl(videoUrl)) {
                await launchUrl(videoUrl, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak dapat membuka video')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('URL video tidak valid')),
            );
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: video['thumbnailBase64'] != null
                        ? Image.memory(
                            base64Decode(video['thumbnailBase64']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error,
                                      size: 48, color: Colors.grey),
                                ),
                              );
                            },
                          )
                        : video['youtubeThumbUrl'] != null
                            ? Image.network(
                                video['youtubeThumbUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error,
                                          size: 48, color: Colors.grey),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image,
                                      size: 48, color: Colors.grey),
                                ),
                              ),
                  ),
                ),
                const Positioned.fill(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video['duration'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryChip(video['category'] ?? ''),
                      const Spacer(),
                      Text(
                        video['date'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6B57D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B57D2),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
