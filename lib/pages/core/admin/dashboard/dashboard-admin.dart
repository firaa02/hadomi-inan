import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../opening/welcome_page.dart';
import 'manage_doctors_screen.dart';
import 'manage_users_screen.dart';
import 'manage_content_screen.dart';
import 'manage_admin_screen.dart'; // New screen for managing admins
import 'manage_online_class_screen.dart'; // Add this import at the top

// Define enums within the same file
enum DoctorManageMode { view, add }

enum ContentManageMode { view, add }

enum AdminManageMode { view, add }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalDoctors = 0;
  int _totalAdmins = 0;
  int _totalContent = 0;
  int _totalOnlineClasses = 0; // Add this line

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  // Add this method for handling refresh
  Future<void> _handleRefresh() async {
    await _fetchDashboardStats();
    // You can show a success message if needed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _fetchDashboardStats() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final articlesSnapshot =
          await FirebaseFirestore.instance.collection('articles').get();
      final videosSnapshot =
          await FirebaseFirestore.instance.collection('videos').get();
      final onlineClassesSnapshot = await FirebaseFirestore.instance
          .collection('online_classes')
          .get(); // Add this

      int userCount = 0;
      int doctorCount = 0;
      int adminCount = 0;

      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        if (userData['role'] == 'user') {
          userCount++;
        }
        if (userData['role'] == 'doctor') {
          doctorCount++;
        }
        if (userData['role'] == 'admin') {
          adminCount++;
        }
      }

      setState(() {
        _totalUsers = userCount;
        _totalDoctors = doctorCount;
        _totalAdmins = adminCount;
        _totalContent =
            articlesSnapshot.docs.length + videosSnapshot.docs.length;
        _totalOnlineClasses = onlineClassesSnapshot.docs.length; // Add this
      });

      print('Total users: $_totalUsers');
      print('Total doctors: $_totalDoctors');
      print('Total admins: $_totalAdmins');
      print('Total content: $_totalContent');
      print('Total online classes: $_totalOnlineClasses'); // Add this
    } catch (e) {
      print('Error fetching stats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching stats: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  // Method to show add admin dialog
  void _showAddAdminDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Admin Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email admin',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Masukkan password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Create user in Firebase Authentication
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );

                  // Store additional user data in Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user?.uid)
                      .set({
                    'name': nameController.text,
                    'email': emailController.text.trim(),
                    'username': emailController.text.split('@')[0],
                    'role': 'admin',
                    'createdAt': FieldValue.serverTimestamp(),
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh stats
                  _fetchDashboardStats();
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menambahkan admin: ${e.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menambahkan admin: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF6B57D2),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Add this line
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  title: 'Total Pengguna',
                  value: _totalUsers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageUsersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Total Dokter',
                  value: _totalDoctors.toString(),
                  icon: Icons.medical_services,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageDoctorsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Total Admin',
                  value: _totalAdmins.toString(),
                  icon: Icons.admin_panel_settings,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageAdminsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Total Konten',
                  value: _totalContent.toString(),
                  icon: Icons.description,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageContentScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: 'Total Kelas Online',
                  value: _totalOnlineClasses.toString(),
                  icon: Icons.video_library,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageOnlineClassScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildQuickActionButton(
                      title: 'Tambah Dokter',
                      icon: Icons.add_circle,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageDoctorsScreen(
                              initialMode: DoctorManageMode.add,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      title: 'Tambah Konten',
                      icon: Icons.upload_file,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageContentScreen(
                              initialMode: ContentManageMode.add,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      title: 'Tambah Kelas Online',
                      icon: Icons.video_call,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageOnlineClassScreen(
                              initialMode: OnlineClassManageMode.add,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionButton(
                      title: 'Tambah Admin',
                      icon: Icons.admin_panel_settings,
                      color: Colors.red,
                      onTap: _showAddAdminDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  // Existing _buildStatCard and _buildQuickActionButton methods remain the same
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
