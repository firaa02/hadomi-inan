import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

// Define the enum here since it's not imported
enum OnlineClassManageMode { view, add }

class ManageOnlineClassScreen extends StatefulWidget {
  final OnlineClassManageMode? initialMode;

  const ManageOnlineClassScreen({super.key, this.initialMode});

  @override
  State<ManageOnlineClassScreen> createState() =>
      _ManageOnlineClassScreenState();
}

class _ManageOnlineClassScreenState extends State<ManageOnlineClassScreen> {
  List<Map<String, dynamic>> _onlineClasses = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Kehamilan',
    'Persalinan',
    'Nutrisi',
    'Pengasuhan Bayi',
  ];

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedCategory;
  File? _thumbnailImage;
  String? _base64Thumbnail;

  @override
  void initState() {
    super.initState();
    _fetchOnlineClasses();

    // If in add mode, show add dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMode == OnlineClassManageMode.add) {
        _showAddOnlineClassDialog();
      }
    });
  }

  Future<void> _fetchOnlineClasses() async {
    try {
      QuerySnapshot classesSnapshot = await FirebaseFirestore.instance
          .collection('online_classes')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _onlineClasses = classesSnapshot.docs
            .map((doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                })
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching online classes: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kelas online: $e')),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _thumbnailImage = imageFile;
        _base64Thumbnail = base64Image;
      });
    }
  }

  void _showAddOnlineClassDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kelas Online Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thumbnail Selection
                GestureDetector(
                  onTap: _pickThumbnail,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _thumbnailImage != null
                        ? Image.file(_thumbnailImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey),
                              Text('Pilih Thumbnail'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kategori';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Kelas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Video URL Field
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Video',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL video tidak boleh kosong';
                    }
                    // Optional: Add URL validation
                    if (!Uri.parse(value).isAbsolute) {
                      return 'Format URL tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reset form
              _resetForm();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Prepare data for Firestore
                  Map<String, dynamic> classData = {
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'videoUrl': _videoUrlController.text.trim(),
                    'duration': _durationController.text.trim(),
                    'date': _dateController.text.trim(),
                    'category': _selectedCategory,
                    'createdAt': FieldValue.serverTimestamp(),
                  };

                  // Add thumbnail if available
                  if (_base64Thumbnail != null &&
                      _base64Thumbnail!.isNotEmpty) {
                    // Pastikan base64 string valid
                    try {
                      base64Decode(_base64Thumbnail!); // Test decode
                      classData['thumbnailBase64'] = _base64Thumbnail;
                    } catch (e) {
                      print('Invalid base64 string: $e');
                      // Handle invalid base64 string
                    }
                  }

                  // Add to Firestore
                  await FirebaseFirestore.instance
                      .collection('online_classes')
                      .add(classData);

                  // Close dialog
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kelas online berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh classes list
                  await _fetchOnlineClasses();

                  // Reset form
                  _resetForm();
                } catch (e) {
                  print(
                      'Error adding online class: $e'); // Add this debug print
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menambahkan kelas online: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  // Method to edit existing online class
  // Modify the _showEditOnlineClassDialog method to handle the BuildContext properly

  void _showEditOnlineClassDialog(Map<String, dynamic> onlineClass) {
    // Pre-fill controllers with existing data
    _titleController.text = onlineClass['title'] ?? '';
    _descriptionController.text = onlineClass['description'] ?? '';
    _videoUrlController.text = onlineClass['videoUrl'] ?? '';
    _durationController.text = onlineClass['duration'] ?? '';
    _dateController.text = onlineClass['date'] ?? '';
    _selectedCategory = onlineClass['category'];

    if (onlineClass['thumbnailBase64'] != null) {
      _base64Thumbnail = onlineClass['thumbnailBase64'];
      _thumbnailImage = null;
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Edit Kelas Online'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thumbnail Selection
                GestureDetector(
                  onTap: _pickThumbnail,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _thumbnailImage != null
                        ? Image.file(_thumbnailImage!, fit: BoxFit.cover)
                        : _base64Thumbnail != null
                            ? Image.memory(
                                base64Decode(_base64Thumbnail!),
                                fit: BoxFit.cover,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                  Text('Pilih Thumbnail'),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kategori';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Kelas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Video URL Field
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Video',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL video tidak boleh kosong';
                    }
                    if (!Uri.parse(value).isAbsolute) {
                      return 'Format URL tidak valid';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _resetForm();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Prepare updated data
                  Map<String, dynamic> updatedData = {
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'videoUrl': _videoUrlController.text.trim(),
                    'duration': _durationController.text.trim(),
                    'date': _dateController.text.trim(),
                    'category': _selectedCategory,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  };

                  if (_base64Thumbnail != null) {
                    updatedData['thumbnailBase64'] = _base64Thumbnail;
                  }

                  // Update in Firestore
                  await FirebaseFirestore.instance
                      .collection('online_classes')
                      .doc(onlineClass['id'])
                      .update(updatedData);

                  // Close dialog first
                  Navigator.of(dialogContext).pop();

                  // Show success message using the original context
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kelas online berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  // Refresh classes list
                  await _fetchOnlineClasses();

                  // Reset form
                  _resetForm();
                } catch (e) {
                  // Show error message using dialog context
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui kelas online: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );
  }

  // Reset form method
  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _videoUrlController.clear();
    _durationController.clear();
    _dateController.clear();
    setState(() {
      _selectedCategory = null;
      _thumbnailImage = null;
      _base64Thumbnail = null;
    });
  }

  // Method to delete online class
  Future<void> _deleteOnlineClass(String classId) async {
    try {
      await FirebaseFirestore.instance
          .collection('online_classes')
          .doc(classId)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelas online berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh classes list
      await _fetchOnlineClasses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kelas online: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        title: const Text(
          'Kelola Kelas Online',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddOnlineClassDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _onlineClasses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada kelas online',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddOnlineClassDialog,
                        child: const Text('Tambah Kelas Online'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _onlineClasses.length,
                  itemBuilder: (context, index) {
                    final onlineClass = _onlineClasses[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: onlineClass['thumbnailBase64'] != null &&
                                  onlineClass['thumbnailBase64']
                                      .toString()
                                      .isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(
                                        onlineClass['thumbnailBase64']),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Icon(Icons.video_library);
                                    },
                                  ),
                                )
                              : const Icon(Icons.video_library),
                        ),
                        title: Text(onlineClass['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(onlineClass['category'] ?? ''),
                            Text(onlineClass['date'] ?? ''),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditOnlineClassDialog(onlineClass);
                            } else if (value == 'delete') {
                              // Show confirmation dialog before deletion
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus kelas online ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteOnlineClass(onlineClass['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
