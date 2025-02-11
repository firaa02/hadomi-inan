import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_consultation_chat_screen.dart';
import 'appointmentscreen.dart';
import '../../../opening/welcome_page.dart';
import 'ConsultationListScreen.dart';
import 'DoctorCalendarScreen.dart';

enum ChatFilter { active, ended, all }

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  StreamSubscription? _chatRoomsSubscription;
  bool _isDisposed = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _doctorName = '';
  int _pendingAppointments = 0;
  bool _isAvailable = true;
  late Stream<QuerySnapshot> _chatRoomsStream;
  int _activeConsultations = 0;
  ChatFilter _currentFilter = ChatFilter.active;

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chatRoomsStream = Stream.empty();
    _loadDoctorData();
    _initializeChatRoomsStream();
  }

  void _initializeChatRoomsStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _updateChatRoomsQuery();
    }
  }

  void _updateChatRoomsQuery() {
    final User? user = _auth.currentUser;
    if (user == null || _isDisposed) {
      // Set an empty stream if no user
      setState(() {
        _chatRoomsStream = Stream.empty();
      });
      return;
    }

    // Batalkan subscription sebelumnya
    _chatRoomsSubscription?.cancel();

    var query = _firestore
        .collection('chatRooms')
        .where('doctorId', isEqualTo: user.uid);

    switch (_currentFilter) {
      case ChatFilter.active:
        query = query.where('isChatEnded', isEqualTo: false);
        break;
      case ChatFilter.ended:
        query = query.where('isChatEnded', isEqualTo: true);
        break;
      case ChatFilter.all:
        // No additional filters
        break;
    }

    _chatRoomsSubscription = query.snapshots().listen((snapshot) {
      // Tambahkan pengecekan mounted dan _isDisposed
      if (_isDisposed || !mounted) return;

      try {
        setState(() {
          // Update the stream and active consultations
          _chatRoomsStream = query.snapshots();

          if (_currentFilter == ChatFilter.active) {
            _activeConsultations = snapshot.docs.length;
          }
        });
      } catch (e) {
        debugPrint('Error updating chat rooms: $e');

        // Fallback to empty stream if error occurs
        setState(() {
          _chatRoomsStream = Stream.empty();
        });
      }
    }, onError: (error) {
      debugPrint('Error in chat rooms stream: $error');

      // Set empty stream on error
      setState(() {
        _chatRoomsStream = Stream.empty();
      });
    });
  }

  Future<void> _loadDoctorData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        // First check if doctor document exists
        final doctorDoc =
            await _firestore.collection('doctors').doc(user.uid).get();

        if (!doctorDoc.exists) {
          // Create doctor document if it doesn't exist
          await _firestore.collection('doctors').doc(user.uid).set({
            'name': _doctorName,
            'isAvailable': true,
            'createdAt': FieldValue.serverTimestamp(),
            'userId': user.uid,
          });
        }

        // Now get the doctor data
        final updatedDoc =
            await _firestore.collection('doctors').doc(user.uid).get();
        setState(() {
          _doctorName = updatedDoc.data()?['name'] ?? 'Dokter';
          _isAvailable = updatedDoc.data()?['isAvailable'] ?? true;
        });

        // Get pending appointments count
        final appointmentsQuery = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .get();

        setState(() {
          _pendingAppointments = appointmentsQuery.docs.length;
        });
      } catch (e) {
        debugPrint('Error loading doctor data: $e');
        if (!_isDisposed && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading doctor data: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleAvailability() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('doctors').doc(user.uid).update({
          'isAvailable': !_isAvailable,
        });

        setState(() {
          _isAvailable = !_isAvailable;
        });
      } catch (e) {
        debugPrint('Error toggling availability: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating availability: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToConsultations() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silahkan login terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Periksa status ketersediaan dokter
    if (!_isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Anda sedang tidak tersedia. Silahkan ubah status ketersediaan Anda.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final doctorDoc =
          await _firestore.collection('doctors').doc(user.uid).get();
      if (!doctorDoc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data dokter tidak ditemukan'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (!mounted) return;

      // Navigate ke halaman konsultasi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConsultationListPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selamat Datang Dokter',
          style: const TextStyle(
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
        onRefresh: _loadDoctorData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Availability Status Card
              _buildStatCard(
                title: 'Status Ketersediaan',
                value: _isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                icon: Icons.person_pin,
                color: _isAvailable ? Colors.green : Colors.red,
                onTap: _toggleAvailability,
                showSwitch: true,
                switchValue: _isAvailable,
                onSwitchChanged: (value) => _toggleAvailability(),
              ),
              const SizedBox(height: 16),

              // Active Consultations Card
              _buildStatCard(
                title: 'Konsultasi Aktif',
                value: _activeConsultations.toString(),
                icon: Icons.chat,
                color: Colors.blue,
                onTap: _navigateToConsultations,
              ),
              const SizedBox(height: 16),

              // Pending Appointments Card
              _buildStatCard(
                title: 'Janji Temu Pending',
                value: _pendingAppointments.toString(),
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(
                        doctorId: _auth.currentUser!.uid,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Konsultasi Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),

              // Recent Consultations Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Konsultasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToConsultations,
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Color(0xFF6B57D2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _chatRoomsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading consultations: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('Tidak ada konsultasi terbaru'),
                              ),
                            );
                          }

                          final recentConsultations =
                              snapshot.data!.docs.take(3);

                          return Column(
                            children: recentConsultations.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final lastMessage =
                                  data['lastMessage'] as String? ??
                                      'No messages';
                              final lastMessageTime =
                                  data['lastMessageTime'] as Timestamp?;
                              final formattedTime = lastMessageTime != null
                                  ? '${lastMessageTime.toDate().hour}:${lastMessageTime.toDate().minute.toString().padLeft(2, '0')}'
                                  : 'No time';

                              return FutureBuilder<DocumentSnapshot>(
                                future: _firestore
                                    .collection('users')
                                    .doc(data['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }

                                  final userData = userSnapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  final userName =
                                      userData?['name'] ?? 'Unknown User';

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF6B57D2),
                                        child: Text(
                                          userName[0],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle:
                                          Text('$lastMessage\n$formattedTime'),
                                      isThreeLine: true,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DoctorConsultationChatScreen(
                                              user: userData!,
                                              chatRoomId: doc.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Menu Cepat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickActionCard(
                    title: 'Jadwal Dokter',
                    icon: Icons.calendar_today,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorCalendarScreen(
                            doctorId: _auth.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    title: 'Konsultasi',
                    icon: Icons.chat_bubble,
                    color: Colors.teal,
                    onTap: _navigateToConsultations,
                  ),
                  _buildQuickActionCard(
                    title: 'Janji Temu',
                    icon: Icons.event,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentScreen(
                            doctorId: _auth.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    title: 'Pengaturan',
                    icon: Icons.settings,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Fitur pengaturan akan segera tersedia'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showSwitch = false,
    bool? switchValue,
    void Function(bool)? onSwitchChanged,
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
              if (showSwitch && switchValue != null && onSwitchChanged != null)
                Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: color,
                )
              else
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

  Widget _buildQuickActionCard({
    required String title,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
