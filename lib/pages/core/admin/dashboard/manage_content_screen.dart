import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'Detail-Article-screen.dart';
import 'Detail-Video-screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dashboard-admin.dart' show ContentManageMode;

enum ContentType { article, video }

class ManageContentScreen extends StatefulWidget {
  final ContentType? initialContentType;
  final ContentManageMode? initialMode;

  const ManageContentScreen(
      {Key? key, this.initialContentType, this.initialMode})
      : super(key: key);

  @override
  _ManageContentScreenState createState() => _ManageContentScreenState();
}

class _ManageContentScreenState extends State<ManageContentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _readTimeController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();
  final TextEditingController _videoDescriptionController =
      TextEditingController();

  ContentType _currentContentType = ContentType.article;
  ContentManageMode _currentMode = ContentManageMode.view;
  bool _isLoading = false;
  String? _thumbnailBase64;
  File? _selectedImage;

  final List<String> _categories = [
    'Kehamilan',
    'Persalinan',
    'Nutrisi',
    'Perawatan Bayi',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialContentType != null) {
      _currentContentType = widget.initialContentType!;
    }
    if (widget.initialMode != null) {
      _currentMode = widget.initialMode!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _readTimeController.dispose();
    _youtubeUrlController.dispose();
    _videoDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Limit image size
        maxHeight: 1024,
        imageQuality: 85, // Compress image
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _selectedImage = imageFile;
          _thumbnailBase64 = base64Image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  bool _isValidYouTubeUrl(String url) {
    final youtubeRegex = RegExp(
      r'^(https?\:\/\/)?(www\.youtube\.com\/watch\?v=|youtu\.be\/)[a-zA-Z0-9_-]+',
    );
    return youtubeRegex.hasMatch(url);
  }

  String _extractYouTubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  String _getYouTubeThumbnail(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  Future<void> _addContent() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contentData = _currentContentType == ContentType.article
          ? _prepareArticleData()
          : _prepareVideoData();

      await FirebaseFirestore.instance
          .collection(_currentContentType == ContentType.article
              ? 'articles'
              : 'videos')
          .add(contentData);

      _resetForm();
      setState(() {
        _currentMode = ContentManageMode.view;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konten berhasil ditambahkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan konten: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul harus diisi')),
      );
      return false;
    }

    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori harus dipilih')),
      );
      return false;
    }

    if (_thumbnailBase64 == null &&
        _currentContentType == ContentType.article) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thumbnail harus dipilih')),
      );
      return false;
    }

    if (_currentContentType == ContentType.article) {
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deskripsi artikel harus diisi')),
        );
        return false;
      }
      if (_readTimeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waktu baca harus diisi')),
        );
        return false;
      }
    } else {
      if (_youtubeUrlController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL YouTube harus diisi')),
        );
        return false;
      }
      if (!_isValidYouTubeUrl(_youtubeUrlController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL YouTube tidak valid')),
        );
        return false;
      }
    }

    return true;
  }

  Map<String, dynamic> _prepareArticleData() {
    return {
      'title': _titleController.text.trim(),
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'readTime': _readTimeController.text.trim(),
      'date': DateTime.now().toString().split(' ')[0],
      'thumbnailBase64': _thumbnailBase64,
      'sections': [
        {
          'title': 'Bagian Utama',
          'content': _descriptionController.text.trim(),
        }
      ]
    };
  }

  Map<String, dynamic> _prepareVideoData() {
    final videoId = _extractYouTubeVideoId(_youtubeUrlController.text.trim());
    return {
      'title': _titleController.text.trim(),
      'category': _categoryController.text.trim(),
      'videoUrl': _youtubeUrlController.text.trim(),
      'description': _videoDescriptionController.text.trim(),
      'thumbnailBase64': _thumbnailBase64,
      'youtubeThumbUrl': _getYouTubeThumbnail(videoId),
      'date': DateTime.now().toString().split(' ')[0],
    };
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _readTimeController.clear();
    _youtubeUrlController.clear();
    _videoDescriptionController.clear();
    setState(() {
      _thumbnailBase64 = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Tambahkan ini
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentMode == ContentManageMode.view
              ? 'Kelola Konten'
              : 'Tambah Konten Baru',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        actions: [
          if (_currentMode == ContentManageMode.view)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentMode = ContentManageMode.add;
                });
              },
            ),
        ],
      ),
      body: _currentMode == ContentManageMode.view
          ? _buildContentList()
          : _buildAddContentForm(),
    );
  }

  Widget _buildContentList() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF6B57D2),
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: 'Artikel'), Tab(text: 'Video')],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: const Color(0xFF6B57D2), width: 2),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_buildArticlesList(), _buildVideosList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada artikel'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final articleData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            articleData['id'] = snapshot.data!.docs[index].id;
            return _buildContentCard(articleData, ContentType.article);
          },
        );
      },
    );
  }

  Widget _buildVideosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada video'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final videoData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            videoData['id'] = snapshot.data!.docs[index].id;
            return _buildContentCard(videoData, ContentType.video);
          },
        );
      },
    );
  }

  Widget _buildContentCard(Map<String, dynamic> contentData, ContentType type) {
    Widget thumbnailWidget;
    if (contentData['thumbnailBase64'] != null) {
      try {
        final imageBytes = base64Decode(contentData['thumbnailBase64']);
        thumbnailWidget = Image.memory(
          imageBytes,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      } catch (e) {
        thumbnailWidget = _buildPlaceholderImage();
      }
    } else if (type == ContentType.video &&
        contentData['youtubeThumbUrl'] != null) {
      thumbnailWidget = Image.network(
        contentData['youtubeThumbUrl'],
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else {
      thumbnailWidget = _buildPlaceholderImage();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: thumbnailWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contentData['title'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B57D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        contentData['category'],
                        style: const TextStyle(
                            color: Color(0xFF6B57D2), fontSize: 12),
                      ),
                    ),
                    Text(
                      contentData['date'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (type == ContentType.article)
                  Text(
                    '${contentData['readTime']} menit baca',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (type == ContentType.video) {
                          // Navigate to VideoDetailScreen and pass the full video data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoDetailScreen(
                                videoData: {
                                  ...contentData,
                                  'videoId': _extractYouTubeVideoId(
                                      contentData['videoUrl'])
                                },
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailScreen(
                                articleData: contentData,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B57D2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: Text(
                        type == ContentType.video
                            ? 'Tonton Video'
                            : 'Baca Artikel',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContent(contentData['id'], type),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
    );
  }

  Future<void> _deleteContent(String contentId, ContentType type) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Konten'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${type == ContentType.article ? 'artikel' : 'video'} ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection(type == ContentType.article ? 'articles' : 'videos')
            .doc(contentId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${type == ContentType.article ? 'Artikel' : 'Video'} berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus konten: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAddContentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SegmentedButton<ContentType>(
              segments: const [
                ButtonSegment(
                  value: ContentType.article,
                  label: Text('Artikel'),
                  icon: Icon(Icons.article),
                ),
                ButtonSegment(
                  value: ContentType.video,
                  label: Text('Video'),
                  icon: Icon(Icons.video_library),
                ),
              ],
              selected: <ContentType>{_currentContentType},
              onSelectionChanged: (Set<ContentType> newSelection) {
                setState(() {
                  _currentContentType = newSelection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 50, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'Pilih Thumbnail',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText:
                  'Judul ${_currentContentType == ContentType.article ? 'Artikel' : 'Video'}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            hint: const Text('Pilih Kategori'),
            items: _categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              _categoryController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),
          if (_currentContentType == ContentType.article) ...[
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi Artikel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _readTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Waktu Baca (menit)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.timer),
              ),
            ),
          ] else ...[
            TextFormField(
              controller: _youtubeUrlController,
              decoration: InputDecoration(
                labelText: 'URL YouTube',
                hintText: 'https://youtu.be/...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.video_library),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _videoDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi Video',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B57D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : Text(
                    'Tambah ${_currentContentType == ContentType.article ? 'Artikel' : 'Video'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
