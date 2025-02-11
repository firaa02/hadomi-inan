import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/user/dashboard/dashboard-screen.dart';
import '../core/admin/dashboard/dashboard-admin.dart';
import '../core/doctor/dashboard/dashboard-doctor.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _obscureText = true;

  String? _normalizePhoneNumber(String phone) {
    try {
      phone = phone.replaceAll(RegExp(r'\D'), '');
      if (phone.startsWith('62')) {
        return '+$phone';
      } else if (phone.startsWith('0')) {
        return '+62${phone.substring(1)}';
      } else if (phone.startsWith('8')) {
        return '+62$phone';
      }
      return null;
    } catch (e) {
      debugPrint('Phone normalization error: $e');
      return null;
    }
  }

  Future<UserCredential?> _handlePasswordAuth(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Authentication error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _findUserByIdentifier(String identifier) async {
    try {
      QuerySnapshot? querySnapshot;
      final normalizedPhone = _normalizePhoneNumber(identifier);

      if (normalizedPhone != null) {
        querySnapshot = await _firestore
            .collection('users')
            .where('phone', isEqualTo: normalizedPhone)
            .limit(1)
            .get();
      }

      if (querySnapshot == null || querySnapshot.docs.isEmpty) {
        querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: identifier)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty && identifier.contains('@')) {
        querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: identifier)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'email': userData['email'] ?? '',
          'phone': userData['phone'] ?? '',
          'username': userData['username'] ?? '',
          'name': userData['name'] ?? '',
          'role': userData['role'] ?? 'user', // Pastikan ini ada
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error finding user: $e');
      return null;
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      if (identifier.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'Username/Email/No.Telp dan password harus diisi',
        );
      }

      final userData = await _findUserByIdentifier(identifier);

      if (userData == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Akun tidak ditemukan',
        );
      }

      final email = userData['email'];
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-auth-type',
          message: 'Metode login tidak valid',
        );
      }

      await _handlePasswordAuth(email, password);

      if (_auth.currentUser != null && mounted) {
        String role = userData['role'] ?? 'user';
        print('Current user role: $role'); // Tambahkan ini untuk debug
        switch (role) {
          case 'admin':
            print('Routing to admin dashboard'); // Tambahkan ini untuk debug
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
            break;

          case 'doctor':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorDashboardScreen(),
              ),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Akun tidak ditemukan';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          errorMessage = 'Akun telah dinonaktifkan';
          break;
        case 'invalid-input':
          errorMessage = e.message ?? 'Mohon isi semua informasi login';
          break;
        default:
          errorMessage = 'Terjadi kesalahan. Silakan coba lagi';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B57D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.pregnant_woman,
                      size: 94,
                      color: Color(0xFF6B57D2),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Selamat Datang Kembali',
                    style: TextStyle(
                      color: Color(0xFF2D3142),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Silakan masuk untuk melanjutkan',
                    style: TextStyle(
                      color: const Color(0xFF2D3142).withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF6B57D2).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B57D2).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _identifierController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Username/Email/No.Telp',
                      hintStyle: TextStyle(
                        color: const Color(0xFF2D3142).withOpacity(0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF6B57D2),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF6B57D2).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B57D2).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: const TextStyle(
                      color: Color(0xFF2D3142),
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: const Color(0xFF2D3142).withOpacity(0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6B57D2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF6B57D2),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6B57D2),
                        Color(0xFF8A75FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B57D2).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'MASUK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: const Color(0xFF2D3142).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: Color(0xFF6B57D2),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
