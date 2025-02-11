import 'package:flutter/material.dart';
import '../../../../widget/burger-navbar.dart';
import 'guide-screen.dart';
import 'checklist-screen.dart';
import 'simulation-screen.dart';

class DeliveryPrepScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DeliveryPrepScreen({super.key});

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
          'Persiapan Persalinan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
      ),
      drawer: BurgerNavBar(
        scaffoldKey: _scaffoldKey,
        currentRoute: '/delivery-prep',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildMainContent(context), // Pass context to _buildMainContent
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
            'Panduan Persiapan Persalinan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Persiapkan diri Anda menghadapi persalinan dengan penuh keyakinan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // Add context parameter
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            title: 'Panduan Persiapan Persalinan',
            description:
                'Memberikan informasi tentang persiapan kelahiran dan teknik pernapasan.',
            icon: Icons.book,
            color: Colors.blue,
            targetAudience: 'Ibu hamil',
            supportText:
                'Membantu ibu hamil siap secara mental dan fisik untuk menghadapi persalinan.',
            features: [
              'Teknik pernapasan',
              'Posisi persalinan',
              'Tanda-tanda persalinan',
              'Persiapan mental',
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuideScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Daftar Perlengkapan Persalinan',
            description:
                'Daftar barang yang perlu dibawa ke rumah sakit untuk persalinan.',
            icon: Icons.checklist,
            color: Colors.green,
            targetAudience: 'Ibu hamil',
            supportText:
                'Membantu ibu hamil menyiapkan perlengkapan yang dibutuhkan untuk persalinan.',
            features: [
              'Perlengkapan ibu',
              'Perlengkapan bayi',
              'Dokumen penting',
              'Kebutuhan darurat',
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChecklistScreen(),
                ),
              );
            },
            featured: true,
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Simulasi Persalinan',
            description:
                'Panduan latihan pernapasan dan posisi tubuh selama persalinan.',
            icon: Icons.sports_gymnastics,
            color: Colors.orange,
            targetAudience: 'Ibu hamil',
            supportText:
                'Memberikan latihan interaktif untuk mempersiapkan ibu hamil menghadapi persalinan.',
            features: [
              'Video tutorial',
              'Latihan pernapasan',
              'Posisi persalinan',
              'Tips relaksasi',
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimulationScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildEmergencyContactCard(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String targetAudience,
    required String supportText,
    required List<String> features,
    required VoidCallback onTap,
    bool featured = false,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: featured
                                ? color.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            targetAudience,
                            style: TextStyle(
                              fontSize: 12,
                              color: featured ? color : Colors.grey[600],
                              fontWeight: featured
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                supportText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features
                    .map((feature) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xFF6B57D2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emergency,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Kontak Darurat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmergencyItem('Ambulans', '118/119'),
            _buildEmergencyItem('Rumah Sakit', '(021) xxx-xxxx'),
            _buildEmergencyItem('Bidan/Dokter', '(021) xxx-xxxx'),
            _buildEmergencyItem('Keluarga', 'xxx-xxxx-xxxx'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyItem(String title, String contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3142),
            ),
          ),
          Text(
            contact,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B57D2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
