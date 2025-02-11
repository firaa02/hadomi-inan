import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert'; // Add this import
import '../../../../widget/burger-navbar.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // Method to upload image to Firestore
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      return base64Image;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  void _showCreatePostDialog() {
    final TextEditingController postController = TextEditingController();
    File? selectedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'Buat Post Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: postController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Bagikan pengalaman atau pertanyaan Anda...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF6B57D2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF6B57D2), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1200,
                            maxHeight: 1200,
                            imageQuality: 85,
                          );

                          if (image != null) {
                            setState(() => selectedImage = File(image.path));
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: selectedImage != null
                                    ? const Color(0xFF6B57D2)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tambah Foto',
                                style: TextStyle(
                                  color: selectedImage != null
                                      ? const Color(0xFF6B57D2)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (postController.text.isNotEmpty ||
                            selectedImage != null) {
                          try {
                            final user = _auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Silakan login terlebih dahulu'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Get user data
                            final userDoc = await _firestore
                                .collection('users')
                                .doc(user.uid)
                                .get();
                            final userData = userDoc.data();

                            // Upload image if exists
                            String? imageUrl;
                            if (selectedImage != null) {
                              imageUrl = await _uploadImage(selectedImage!);
                            }

                            // In the _showCreatePostDialog method, when creating a post
                            await _firestore.collection('forumPosts').add({
                              'userId': user.uid,
                              'username': userData?['name'] ?? 'Pengguna',
                              'profileImage': userData?['profileImage'],
                              'content': postController.text,
                              'image': imageUrl,
                              'likes': 0,
                              'comments': [],
                              'timestamp': FieldValue
                                  .serverTimestamp(), // This ensures proper timestamp handling
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post berhasil dibuat'),
                                backgroundColor: Color(0xFF6B57D2),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal membuat post: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B57D2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Kirim Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Komunitas Ibu Hamil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
      ),
      drawer: BurgerNavBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/community',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('forumPosts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Belum ada postingan'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final postData = snapshot.data!.docs[index];
              return _buildPost(postData);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF6B57D2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPost(QueryDocumentSnapshot postData) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF6B57D2),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimestamp(
                            postData['timestamp']), // Hapus type cast langsung
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showPostOptions(postData),
                ),
              ],
            ),
            if (postData['content'] != null &&
                postData['content'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                postData['content'],
                style: const TextStyle(fontSize: 15),
              ),
            ],
            if (postData['image'] != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Show full-screen image
                  _showFullScreenImage(context, postData['image']);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio:
                        16 / 9, // 16:9 aspect ratio for rectangular shape
                    child: Image.memory(
                      base64Decode(postData['image'].split(',')[1]),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInteractionButton(
                  icon: Icons.favorite_border,
                  label: '${postData['likes']}',
                  color: const Color(0xFF6B57D2),
                  onPressed: () => _handleLike(postData),
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  icon: Icons.comment_outlined,
                  label: '${postData['comments'].length}',
                  color: const Color(0xFF6B57D2),
                  onPressed: () {
                    _showComments(context, postData);
                  },
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  icon: Icons.share_outlined,
                  label: 'Bagikan',
                  color: const Color(0xFF6B57D2),
                  onPressed: () {
                    // Implement share functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String base64Image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: InteractiveViewer(
                  maxScale: 5.0,
                  child: Image.memory(
                    base64Decode(base64Image.split(',')[1]),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 100,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLike(QueryDocumentSnapshot postData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _firestore.collection('forumPosts').doc(postData.id).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyukai post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPostOptions(QueryDocumentSnapshot postData) {
    final currentUser = _auth.currentUser;
    final isPostOwner =
        currentUser != null && postData['userId'] == currentUser.uid;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPostOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Postingan',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  // Tutup bottom sheet
                  Navigator.pop(context);

                  // Tampilkan dialog konfirmasi
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Hapus Postingan?'),
                        content: const Text(
                            'Anda yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.'),
                        actions: [
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              try {
                                // Hapus postingan dari Firestore
                                await _firestore
                                    .collection('forumPosts')
                                    .doc(postData.id)
                                    .delete();

                                Navigator.pop(context); // Tutup dialog

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Postingan berhasil dihapus'),
                                    backgroundColor: Color(0xFF6B57D2),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context); // Tutup dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Gagal menghapus postingan: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Laporkan Post'),
              onTap: () async {
                Navigator.pop(context);

                // Tampilkan dialog pelaporan
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String? selectedReason;
                    return AlertDialog(
                      title: const Text('Laporkan Postingan'),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Pilih alasan pelaporan:'),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: selectedReason,
                                hint: const Text('Pilih alasan'),
                                items: [
                                  'Konten tidak pantas',
                                  'Spam',
                                  'Pelecehan',
                                  'Informasi palsu',
                                  'Lainnya'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedReason = newValue;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text('Laporkan'),
                          onPressed: () async {
                            if (selectedReason != null) {
                              try {
                                final user = _auth.currentUser;
                                if (user == null) {
                                  throw Exception(
                                      'Silakan login terlebih dahulu');
                                }

                                // Simpan laporan ke Firestore
                                await _firestore.collection('reports').add({
                                  'postId': postData.id,
                                  'reporterId': user.uid,
                                  'reason': selectedReason,
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'status': 'pending',
                                  'postContent': postData['content'],
                                  'postOwner': postData['userId'],
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Terima kasih atas laporan Anda'),
                                    backgroundColor: Color(0xFF6B57D2),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Gagal melaporkan postingan: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Simpan Post'),
              onTap: () async {
                try {
                  final user = _auth.currentUser;
                  if (user == null) {
                    throw Exception('Silakan login terlebih dahulu');
                  }

                  // Cek apakah postingan sudah disimpan
                  final savedDoc = await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('savedPosts')
                      .doc(postData.id)
                      .get();

                  if (savedDoc.exists) {
                    // Jika sudah disimpan, hapus dari saved posts
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('savedPosts')
                        .doc(postData.id)
                        .delete();

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Postingan dihapus dari simpanan'),
                        backgroundColor: Color(0xFF6B57D2),
                      ),
                    );
                  } else {
                    // Jika belum disimpan, tambahkan ke saved posts
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('savedPosts')
                        .doc(postData.id)
                        .set({
                      'postId': postData.id,
                      'savedAt': FieldValue.serverTimestamp(),
                      'postData': postData.data(),
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Postingan berhasil disimpan'),
                        backgroundColor: Color(0xFF6B57D2),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menyimpan postingan: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context, QueryDocumentSnapshot postData) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: (postData['comments'] as List?)?.length ?? 0,
                  itemBuilder: (context, index) {
                    final comment = (postData['comments'] as List)[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6B57D2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        comment['username'] ?? 'Pengguna',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['content'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            comment['timestamp'] != null
                                ? _formatTimestamp(comment['timestamp'])
                                : 'Baru saja',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: const Color(0xFF6B57D2),
                      onPressed: () async {
                        final commentText = commentController.text.trim();
                        if (commentText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Komentar tidak boleh kosong'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final user = _auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan login terlebih dahulu'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Get user data
                          final userDoc = await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          final userData = userDoc.data();
                          final username = userData?['name'] ?? 'Pengguna';

                          // Prepare comment data
                          final newComment = {
                            'username': username,
                            'content': commentText,
                            'timestamp':
                                DateTime.now(), // Use local timestamp instead
                          };

// Perform a safe update
                          final DocumentReference postRef = _firestore
                              .collection('forumPosts')
                              .doc(postData.id);

                          await postRef.update({
                            'comments': FieldValue.arrayUnion([newComment])
                          });

                          // Clear and close
                          commentController.clear();
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Komentar berhasil ditambahkan'),
                              backgroundColor: Color(0xFF6B57D2),
                            ),
                          );
                        } catch (e) {
                          print('Detailed error: $e');

                          String errorMessage = 'Gagal menambahkan komentar';
                          if (e is FirebaseException) {
                            switch (e.code) {
                              case 'permission-denied':
                                errorMessage = 'Anda tidak memiliki izin';
                                break;
                              case 'unavailable':
                                errorMessage = 'Koneksi internet bermasalah';
                                break;
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestampData) {
    if (timestampData == null) {
      return 'Baru saja';
    }

    DateTime timestamp;
    if (timestampData is Timestamp) {
      timestamp = timestampData.toDate();
    } else if (timestampData is DateTime) {
      timestamp = timestampData;
    } else {
      return 'Baru saja';
    }

    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
