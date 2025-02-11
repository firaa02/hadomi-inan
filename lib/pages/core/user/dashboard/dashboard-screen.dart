import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../../../widget/burger-navbar.dart';
import 'FetalDevelopmentDetail-screen.dart';
import '../profile/profile-screen.dart';
import 'chat-screen.dart';
import 'notification-screen.dart';
import 'doctor-consultation-screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _notificationCount = 3;
  Map<String, dynamic> _pregnancyData = {};
  Map<String, dynamic> _fetalData = {};
  String? _profileImageUrl;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Load user document to get pregnancy date
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data() as Map<String, dynamic>;

        // Ensure the user is pregnant and has a pregnancy date
        if (userData['isPregnant'] == true &&
            userData.containsKey('pregnancyDate')) {
          // Parse pregnancy date from the timestamp format
          final pregnancyDate = DateTime.parse(userData['pregnancyDate']);

          // Calculate current pregnancy information
          final today = DateTime.now();
          final dueDate =
              pregnancyDate.add(const Duration(days: 280)); // 40 weeks
          final differenceInDays = today.difference(pregnancyDate).inDays;
          final currentWeek = (differenceInDays / 7).floor() + 1;

          // Prepare pregnancy data
          final pregnancyData = {
            'currentWeek': currentWeek,
            'dueDate': '${dueDate.day}/${dueDate.month}/${dueDate.year}',
            'pregnancyDate': userData['pregnancyDate'],
            'lastUpdate': today,
          };

          // Update or create pregnancy data
          await _firestore.collection('pregnancyData').doc(user.uid).set(
                pregnancyData,
                SetOptions(merge: true),
              );

          // Get fetal development data for current week
          final fetalData = _getFetalDataForWeek(currentWeek);

          // Update or create fetal development data
          await _firestore.collection('fetalDevelopment').doc(user.uid).set(
            {
              ...fetalData,
              'lastUpdate': today,
            },
            SetOptions(merge: true),
          );

          // Setup weekly data update
          _setupWeeklyDataUpdate(user.uid);
        }
      }
    } catch (e) {
      debugPrint('Error initializing user data: $e');
    }
  }

  Future<void> _setupWeeklyDataUpdate(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData['isPregnant'] == true &&
          userData.containsKey('pregnancyDate')) {
        final pregnancyDate = DateTime.parse(userData['pregnancyDate']);
        final today = DateTime.now();
        final differenceInDays = today.difference(pregnancyDate).inDays;
        final currentWeek = (differenceInDays / 7).floor() + 1;

        final pregnancyDoc =
            await _firestore.collection('pregnancyData').doc(userId).get();

        if (pregnancyDoc.exists) {
          final data = pregnancyDoc.data() as Map<String, dynamic>;
          final lastUpdate = (data['lastUpdate'] as Timestamp).toDate();
          // Use currentWeek comparison instead of stored week
          final daysSinceUpdate = today.difference(lastUpdate).inDays;

          if (daysSinceUpdate >= 7 && currentWeek < 40) {
            // Prepare updated data
            final dueDate = pregnancyDate.add(const Duration(days: 280));
            final updatedPregnancyData = {
              'currentWeek': currentWeek,
              'dueDate': '${dueDate.day}/${dueDate.month}/${dueDate.year}',
              'lastUpdate': today,
            };

            // Update pregnancy data
            await _firestore
                .collection('pregnancyData')
                .doc(userId)
                .update(updatedPregnancyData);

            // Get and update fetal development data
            final fetalData = _getFetalDataForWeek(currentWeek);
            await _firestore.collection('fetalDevelopment').doc(userId).update({
              ...fetalData,
              'lastUpdate': today,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error in weekly update: $e');
    }
  }

  Map<String, String> _getFetalDataForWeek(int week) {
    final Map<String, Map<String, String>> weeklyData = {
      '4': {
        'size': 'biji poppy',
        'length': '0.4 cm',
        'weight': '1 gram',
        'weightStatus': 'Berkembang normal',
      },
      '8': {
        'size': 'kacang polong',
        'length': ' 1.6 cm',
        'weight': '3 gram',
        'weightStatus': 'Berkembang normal',
      },
      '12': {
        'size': ' jeruk nipis',
        'length': ' 5.4 cm',
        'weight': '14 gram',
        'weightStatus': 'Berkembang normal',
      },
      '16': {
        'size': ' alpukat',
        'length': ' 11.6 cm',
        'weight': '100 gram',
        'weightStatus': 'Berkembang normal',
      },
      '20': {
        'size': ' pisang',
        'length': ' 16.4 cm',
        'weight': '300 gram',
        'weightStatus': 'Berkembang normal',
      },
      '24': {
        'size': ' papaya',
        'length': ' 30 cm',
        'weight': '600 gram',
        'weightStatus': 'Berkembang normal',
      },
      '28': {
        'size': ' kelapa',
        'length': ' 37 cm',
        'weight': '1000 gram',
        'weightStatus': 'Berkembang normal',
      },
      '32': {
        'size': ' nanas',
        'length': ' 42 cm',
        'weight': '1800 gram',
        'weightStatus': 'Berkembang normal',
      },
      '36': {
        'size': ' melon',
        'length': ' 47 cm',
        'weight': '2600 gram',
        'weightStatus': 'Berkembang normal',
      },
      '40': {
        'size': ' semangka kecil',
        'length': ' 51 cm',
        'weight': '3400 gram',
        'weightStatus': 'Berkembang normal',
      },
    };

    String closestWeek = '4';
    for (final dataWeek in weeklyData.keys) {
      if (week >= int.parse(dataWeek)) {
        closestWeek = dataWeek;
      } else {
        break;
      }
    }

    return weeklyData[closestWeek]!;
  }

  Widget _buildProfileImage() {
    if (_isLoadingImage) {
      return const SizedBox(
        width: 35,
        height: 35,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
    }

    return Container(
      width: 35,
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
            ? _buildProfileImageContent()
            : Icon(
                Icons.person,
                size: 25,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildProfileImageContent() {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      return const Icon(
        Icons.person,
        size: 25,
        color: Colors.white,
      );
    }

    try {
      // Check if it's a base64 image
      if (_profileImageUrl!.startsWith('data:image')) {
        // Extract base64 data
        final base64Data = _profileImageUrl!.split(',').length > 1
            ? _profileImageUrl!.split(',')[1]
            : _profileImageUrl!;

        return Image.memory(
          base64Decode(base64Data),
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading base64 image: $error');
            return const Icon(
              Icons.person,
              size: 25,
              color: Colors.white,
            );
          },
        );
      }
      // Check if it's a network image
      else if (_profileImageUrl!.startsWith('http')) {
        return Image.network(
          _profileImageUrl!,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading network image: $error');
            return const Icon(
              Icons.person,
              size: 25,
              color: Colors.white,
            );
          },
        );
      }
      // Fallback to default icon
      return const Icon(
        Icons.person,
        size: 25,
        color: Colors.white,
      );
    } catch (e) {
      debugPrint('Unexpected error loading profile image: $e');
      return const Icon(
        Icons.person,
        size: 25,
        color: Colors.white,
      );
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingImage = true);
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _profileImageUrl = userData['profileImage'] as String?;
          });
        }

        // Load pregnancy data
        final pregnancyDoc =
            await _firestore.collection('pregnancyData').doc(user.uid).get();
        if (pregnancyDoc.exists) {
          setState(() {
            _pregnancyData = pregnancyDoc.data() as Map<String, dynamic>;
          });
        }

        // Load fetal development data
        final fetalDoc =
            await _firestore.collection('fetalDevelopment').doc(user.uid).get();
        if (fetalDoc.exists) {
          setState(() {
            _fetalData = fetalDoc.data() as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() => _isLoadingImage = false);
    }
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
          'Hadomi Inan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadUserData());
              },
              child: _buildProfileImage(),
            ),
          ),
        ],
      ),
      drawer: BurgerNavBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/dashboard',
      ),
      floatingActionButton: const FloatingMessageButton(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ruang aman untuk penyembuhan & pertumbuhan pribadi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPregnancySummary(),
          const SizedBox(height: 16),
          _buildFetalDevelopment(),
        ],
      ),
    );
  }

  Widget _buildPregnancySummary() {
    final currentWeek = (_pregnancyData['currentWeek'] as num?)?.toInt() ?? 0;
    final dueDate = _pregnancyData['dueDate'] as String? ?? '-';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Color(0xFF6B57D2),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Ringkasan Kehamilan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoBox(
                  title: 'Usia Kehamilan',
                  value: '$currentWeek Minggu',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildInfoBox(
                  title: 'Perkiraan Lahir',
                  value: dueDate,
                  icon: Icons.child_care,
                  color: Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFetalDevelopment() {
    return Card(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.child_friendly,
                      color: Color(0xFF6B57D2),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Perkembangan Janin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const FetalDevelopmentDetailScreen(),
                      ),
                    );
                  },
                  child: const Text('Detail'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDevelopmentDetail(
              'Ukuran',
              _fetalData['size'] ?? '-',
              _fetalData['length'] ?? '-',
              Icons.straighten,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildDevelopmentDetail(
              'Berat',
              _fetalData['weight'] ?? '-',
              _fetalData['weightStatus'] ?? '-',
              Icons.monitor_weight_outlined,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentDetail(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingMessageButton extends StatelessWidget {
  const FloatingMessageButton({super.key});

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Layanan Konsultasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(
              context,
              'Konsultasi Dokter/Bidan',
              'Chat atau video call dengan tenaga medis',
              Icons.medical_services_outlined,
              () => _openDoctorConsultation(context),
            ),
            _buildOptionItem(
              context,
              'Chat dengan AI Assistant',
              'Informasi seputar kesehatan ibu & bayi',
              Icons.smart_toy_outlined,
              () => _openChatbot(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF6B57D2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF6B57D2),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF6B57D2),
      ),
    );
  }

  void _openDoctorConsultation(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorConsultationScreen(),
      ),
    );
  }

  void _openChatbot(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showMessageOptions(context),
      backgroundColor: const Color(0xFF6B57D2),
      child: const Icon(Icons.message_outlined),
    );
  }
}
