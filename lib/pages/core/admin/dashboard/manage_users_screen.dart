import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUserEmail(String userId, String newEmail) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Update email in Firebase Authentication
        await currentUser.updateEmail(newEmail);

        // Update email in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
            {'email': newEmail, 'lastUpdated': FieldValue.serverTimestamp()});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna tidak ditemukan')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui email: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui email: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePhoneNumber(String userId, String newPhoneNumber) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Update phone number in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'phone': newPhoneNumber,
        'lastUpdated': FieldValue.serverTimestamp()
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui nomor telepon: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserPassword(Map<String, dynamic> userData) async {
    try {
      // Tampilkan konfirmasi dialog
      bool? confirmReset = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Password'),
          content: const Text(
              'Anda akan menerima email untuk mereset password. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Kirim'),
            ),
          ],
        ),
      );

      if (confirmReset == true) {
        setState(() {
          _isLoading = true;
        });

        // Kirim email reset password
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: userData['email']);

        // Update timestamp di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData['id'])
            .update({
          'lastPasswordResetAt': FieldValue.serverTimestamp(),
          'passwordResetRequested': true
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Email reset password telah dikirim ke ${userData['email']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim reset password: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteUserAccount(Map<String, dynamic> userData) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Akun'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        setState(() {
          _isLoading = true;
        });

        // Get the user ID
        String userId = userData['id'];

        // Delete user document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        // Get the current user from Firebase Auth
        User? currentUser = FirebaseAuth.instance.currentUser;

        // Delete the user from Firebase Authentication
        if (currentUser != null) {
          await currentUser.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus akun: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEmailEditDialog(Map<String, dynamic> userData) {
    final TextEditingController emailController =
        TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Baru',
            hintText: 'Masukkan email baru',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  emailController.text != userData['email']) {
                _updateUserEmail(userData['id'], emailController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPhoneEditDialog(Map<String, dynamic> userData) {
    final TextEditingController phoneController =
        TextEditingController(text: userData['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nomor Telepon'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon Baru',
            hintText: 'Masukkan nomor telepon baru',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                _updatePhoneNumber(userData['id'], phoneController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            userData['name'] ?? 'Detail Pengguna',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B57D2),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image
                if (userData['profileImage'] != null)
                  Center(
                    child: ClipOval(
                      child: Image.memory(
                        base64Decode(userData['profileImage'].split(',')[1]),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 120,
                            color: Color(0xFF6B57D2),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // User Details
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Nama',
                  value: userData['name'] ?? 'Tidak tersedia',
                ),
                _buildDetailRow(
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: '@${userData['username'] ?? 'Tidak tersedia'}',
                ),
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: userData['email'] ?? 'Tidak tersedia',
                ),
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Nomor Telepon',
                  value: userData['phone'] ?? 'Tidak tersedia',
                ),
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: userData['address'] ?? 'Tidak tersedia',
                ),

                // Pregnancy Info (if applicable)
                if (userData['isPregnant'] == true)
                  _buildDetailRow(
                    icon: Icons.pregnant_woman,
                    label: 'Tanggal Kehamilan',
                    value: userData['pregnancyDate'] != null
                        ? _formatDate(DateTime.parse(userData['pregnancyDate']))
                        : 'Tidak tersedia',
                  ),

                // Registration Date
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Terdaftar',
                  value: userData['createdAt'] != null
                      ? _formatDate(userData['createdAt'].toDate())
                      : 'Tidak tersedia',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF6B57D2)),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6B57D2),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          'Kelola Pengguna',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role',
                            isEqualTo:
                                'user') // Only fetch users with 'user' role
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: Text('Tidak ada pengguna'));
                      }

                      // Filter users based on search query
                      final filteredUsers = snapshot.data!.docs.where((doc) {
                        final userData = doc.data() as Map<String, dynamic>;
                        final name = (userData['name'] ?? '').toLowerCase();
                        final email = (userData['email'] ?? '').toLowerCase();
                        final username =
                            (userData['username'] ?? '').toLowerCase();

                        return name.contains(_searchQuery) ||
                            email.contains(_searchQuery) ||
                            username.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final userData = filteredUsers[index].data()
                              as Map<String, dynamic>;
                          userData['id'] = filteredUsers[index].id;

                          return _buildUserCard(userData);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData) {
    return GestureDetector(
      onTap: () => _showUserDetailsDialog(userData),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B57D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF6B57D2),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'Nama Tidak Tersedia',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData['email'] ?? 'Email Tidak Tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${userData['username'] ?? 'username'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit_email':
                          _showEmailEditDialog(userData);
                          break;
                        case 'edit_phone':
                          _showPhoneEditDialog(userData);
                          break;
                        case 'change_password':
                          _updateUserPassword(userData);
                          break;
                        case 'delete_account':
                          _deleteUserAccount(userData);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'edit_email',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Ubah Email'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit_phone',
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Ubah Nomor HP'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(Icons.lock, color: Colors.purple),
                            SizedBox(width: 8),
                            Text('Ubah Password'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete_account',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus Akun'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),

              // Additional User Info
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Registration Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Terdaftar: ${userData['createdAt'] != null ? _formatDate(userData['createdAt'].toDate()) : 'Tidak diketahui'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
