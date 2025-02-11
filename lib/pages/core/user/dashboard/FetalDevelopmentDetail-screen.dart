import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FetalDevelopmentDetailScreen extends StatefulWidget {
  const FetalDevelopmentDetailScreen({super.key});

  @override
  State<FetalDevelopmentDetailScreen> createState() =>
      _FetalDevelopmentDetailScreenState();
}

class _FetalDevelopmentDetailScreenState
    extends State<FetalDevelopmentDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _pregnancyData = {};
  Map<String, dynamic> _fetalData = {};
  Map<String, List<String>> _weeklyDevelopment = {};
  List<Map<String, String>> _weeklyTips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
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

        // Load weekly development details
        _loadWeeklyDevelopment(_pregnancyData['currentWeek'] ?? 1);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadWeeklyDevelopment(int week) {
    // Data perkembangan mingguan
    _weeklyDevelopment = {
      'Perkembangan Fisik': [
        'Kulit bayi mulai menebal dan tidak transparan lagi',
        'Telinga sudah dapat mendengar suara dengan jelas',
        'Sistem saraf mulai berkembang pesat',
        'Wajah bayi sudah terbentuk sempurna',
        'Jari tangan dan kaki sudah memiliki sidik jari',
        'Rambut, alis, dan bulu mata mulai tumbuh',
      ],
      'Perkembangan Organ': [
        'Paru-paru mulai memproduksi surfaktan',
        'Sistem pencernaan mulai berlatih mencerna',
        'Pembuluh darah berkembang dengan baik',
        'Otak terus berkembang dengan cepat',
        'Jantung berdetak semakin kuat',
        'Ginjal mulai memproduksi urin',
      ],
      'Gerakan Janin': [
        'Gerakan semakin aktif dan teratur',
        'Mulai memiliki pola tidur sendiri',
        'Dapat bereaksi terhadap suara dan sentuhan',
        'Sering menendang dan berputar',
        'Mulai berlatih mengisap jempol',
        'Responsif terhadap cahaya terang',
      ],
    };

    _weeklyTips = [
      {
        'title': 'Ajak bayi berbicara atau bernyanyi',
        'description':
            'Bayi dapat mendengar suara Anda dengan jelas, ini membantu perkembangan otaknya',
      },
      {
        'title': 'Lakukan yoga kehamilan',
        'description':
            'Membantu menjaga kelenturan dan kekuatan tubuh serta mengurangi stress',
      },
      {
        'title': 'Konsumsi makanan kaya zat besi',
        'description':
            'Mendukung perkembangan otak dan sistem saraf bayi serta mencegah anemia',
      },
      {
        'title': 'Jaga pola tidur',
        'description':
            'Tidur yang cukup penting untuk perkembangan janin dan kesehatan ibu',
      },
      {
        'title': 'Rutin berolahraga ringan',
        'description':
            'Membantu melancarkan peredaran darah dan mengurangi keluhan kehamilan',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perkembangan Janin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildDetailContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentWeek = _pregnancyData['currentWeek']?.toString() ?? '-';

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
        children: [
          Text(
            'Minggu ke $currentWeek',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderInfo(
                icon: Icons.straighten,
                value: _fetalData['length'] ?? '-',
                label: 'Panjang',
              ),
              _buildHeaderInfo(
                icon: Icons.monitor_weight_outlined,
                value: _fetalData['weight'] ?? '-',
                label: 'Berat',
              ),
              _buildHeaderInfo(
                icon: Icons.food_bank,
                value: _fetalData['size'] ?? '-',
                label: 'Ukuran',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B57D2),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._weeklyDevelopment.entries.map((entry) => Column(
                children: [
                  _buildSection(
                    title: entry.key,
                    icon: _getIconForSection(entry.key),
                    content: entry.value,
                  ),
                  const SizedBox(height: 20),
                ],
              )),
          _buildTipsCard(),
        ],
      ),
    );
  }

  IconData _getIconForSection(String section) {
    switch (section) {
      case 'Perkembangan Fisik':
        return Icons.child_friendly;
      case 'Perkembangan Organ':
        return Icons.favorite_border;
      case 'Gerakan Janin':
        return Icons.directions_run;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> content,
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
                Icon(
                  icon,
                  color: const Color(0xFF6B57D2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF6B57D2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
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
                  Icons.lightbulb_outline,
                  color: Color(0xFF6B57D2),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Tips Minggu Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._weeklyTips.map((tip) => Column(
                  children: [
                    _buildTipItem(tip['title']!, tip['description']!),
                    const SizedBox(height: 8),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6B57D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
