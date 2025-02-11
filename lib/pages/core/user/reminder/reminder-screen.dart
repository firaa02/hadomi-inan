import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../widget/burger-navbar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TabController _tabController;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddSupplementDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController scheduleController = TextEditingController();
    TimeOfDay? supplementTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Vitamin & Suplemen'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Vitamin/Suplemen',
                        hintText: 'Contoh: Vitamin C',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: scheduleController,
                      decoration: const InputDecoration(
                        labelText: 'Jadwal',
                        hintText: 'Contoh: Setiap pagi',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            supplementTime = picked;
                          });
                        }
                      },
                      child: Text(
                        supplementTime != null
                            ? 'Waktu: ${supplementTime!.format(context)}'
                            : 'Pilih Waktu',
                      ),
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
                    if (nameController.text.isNotEmpty &&
                        scheduleController.text.isNotEmpty &&
                        supplementTime != null) {
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

                        await _firestore.collection('supplements').add({
                          'userId': user.uid,
                          'name': nameController.text,
                          'schedule': scheduleController.text,
                          'time': {
                            'hour': supplementTime!.hour,
                            'minute': supplementTime!.minute
                          },
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Vitamin & Suplemen berhasil ditambahkan'),
                            backgroundColor: Color(0xFF6B57D2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menambahkan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B57D2),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddAppointmentDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController doctorController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Janji Temu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Janji Temu',
                        hintText: 'Contoh: Pemeriksaan Rutin',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: doctorController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Dokter',
                        hintText: 'Contoh: Dr. Sarah',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi',
                        hintText: 'Contoh: RS XXX',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                        hintText: 'Contoh: USG Kehamilan',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        selectedDate != null
                            ? 'Tanggal: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Pilih Tanggal',
                      ),
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
                    if (titleController.text.isNotEmpty &&
                        doctorController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        selectedDate != null) {
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

                        await _firestore.collection('appointments').add({
                          'userId': user.uid,
                          'title': titleController.text,
                          'doctor': doctorController.text,
                          'location': locationController.text,
                          'notes': notesController.text,
                          'date': Timestamp.fromDate(selectedDate!),
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Janji Temu berhasil ditambahkan'),
                            backgroundColor: Color(0xFF6B57D2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menambahkan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B57D2),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Supplement list with Firestore integration
  Widget _buildSupplementList() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login terlebih dahulu'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('supplements')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada vitamin & suplemen'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: _buildSupplementCard(
                name: data['name'] ?? '',
                schedule: data['schedule'] ?? '',
                time:
                    '${data['time']['hour'].toString().padLeft(2, '0')}:${data['time']['minute'].toString().padLeft(2, '0')}',
                nextDose: DateTime.now().add(const Duration(hours: 12)),
                color: Colors.green,
                onDelete: () => _deleteSupplement(doc.id),
              ),
            );
          },
        );
      },
    );
  }

  // Delete supplement method
  Future<void> _deleteSupplement(String docId) async {
    try {
      await _firestore.collection('supplements').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vitamin & Suplemen berhasil dihapus'),
          backgroundColor: Color(0xFF6B57D2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Appointment list with Firestore integration
  Widget _buildAppointmentList() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login terlebih dahulu'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .snapshots(), // Hapus orderBy untuk sementara
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Belum ada janji temu'),
          );
        }

        // Sort data secara manual jika perlu
        final sortedDocs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final dateA = (a['date'] as Timestamp).toDate();
            final dateB = (b['date'] as Timestamp).toDate();
            return dateA.compareTo(dateB);
          });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final doc = sortedDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final appointmentDate = (data['date'] as Timestamp).toDate();

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: _buildAppointmentCard(
                title: data['title'] ?? '',
                doctor: data['doctor'] ?? '',
                location: data['location'] ?? '',
                datetime: appointmentDate,
                notes: data['notes'] ?? '',
                color: Colors.blue,
                onDelete: () => _deleteAppointment(doc.id),
              ),
            );
          },
        );
      },
    );
  }

  // Delete appointment method
  Future<void> _deleteAppointment(String docId) async {
    try {
      await _firestore.collection('appointments').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Janji temu berhasil dihapus'),
          backgroundColor: Color(0xFF6B57D2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Supplement card with delete option
  Widget _buildSupplementCard({
    required String name,
    required String schedule,
    required String time,
    required DateTime nextDose,
    required Color color,
    required VoidCallback onDelete,
  }) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        schedule,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildCountdownHours(nextDose),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Appointment card with delete option
  Widget _buildAppointmentCard({
    required String title,
    required String doctor,
    required String location,
    required DateTime datetime,
    required String notes,
    required Color color,
    required VoidCallback onDelete,
  }) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notes,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event, color: color),
                      const SizedBox(width: 8),
                      Text(
                        '${datetime.day}/${datetime.month}/${datetime.year}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildCountdownDays(datetime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Countdown hours widget
  Widget _buildCountdownHours(DateTime nextDose) {
    Duration difference = nextDose.difference(DateTime.now());
    String timeLeft = '${difference.inHours}j ${difference.inMinutes % 60}m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6B57D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        timeLeft,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B57D2),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Countdown days widget
  Widget _buildCountdownDays(DateTime appointmentDate) {
    Duration difference = appointmentDate.difference(DateTime.now());
    String timeLeft = '${difference.inDays} hari lagi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        timeLeft,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B57D2),
          fontWeight: FontWeight.bold,
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
          'Pengingat',
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
          tabs: const [
            Tab(
              icon: Icon(Icons.medication),
              text: 'Vitamin & Suplemen',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Janji Temu',
            ),
          ],
        ),
      ),
      drawer: BurgerNavBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/reminder',
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSupplementTab(),
          _buildAppointmentTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show different dialog based on current tab
          if (_tabController.index == 0) {
            _showAddSupplementDialog();
          } else {
            _showAddAppointmentDialog();
          }
        },
        backgroundColor: const Color(0xFF6B57D2),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Supplement tab
  Widget _buildSupplementTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSupplementHeader(),
          _buildSupplementList(),
        ],
      ),
    );
  }

  // Supplement header
  Widget _buildSupplementHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Pengingat Vitamin & Suplemen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jangan lewatkan jadwal konsumsi vitamin dan suplemen Anda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Appointment tab
  Widget _buildAppointmentTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF6B57D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Janji Temu Medis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola jadwal pemeriksaan kehamilan Anda',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildAppointmentList(),
        ],
      ),
    );
  }
}
