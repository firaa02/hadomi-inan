import 'package:flutter/material.dart';
import '../../../../../../widget/burger-navbar.dart';
import 'PostpartumRecoveryGuide-screen.dart'; // Sesuaikan path sesuai struktur folder
import 'newborncare-screen.dart';
import 'BreastfeedingGuide.dart';

class PostpartumScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PostpartumScreen({super.key});

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
          'Perawatan Pasca Melahirkan',
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
        currentRoute: '/postpartum',
      ),
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
            'Perawatan Pasca Melahirkan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Panduan lengkap untuk pemulihan dan perawatan setelah melahirkan',
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
    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSection(
                context: context,
                title: 'Panduan Pemulihan Pasca Melahirkan',
                description:
                    'Memberikan informasi tentang pemulihan tubuh setelah melahirkan.',
                icon: Icons.healing,
                color: Colors.blue,
                targetAudience: 'Ibu pasca melahirkan',
                supportText:
                    'Membantu ibu baru dalam proses pemulihan fisik dan emosional setelah melahirkan.',
                features: [
                  'Pemulihan fisik',
                  'Perawatan luka',
                  'Nutrisi ibu',
                  'Kesehatan mental',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostpartumRecoveryGuide(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSection(
                context: context,
                title: 'Perawatan Bayi Baru Lahir',
                description:
                    'Panduan perawatan bayi baru lahir seperti menyusui, mandi, dll.',
                icon: Icons.child_care,
                color: Colors.green,
                targetAudience: 'Ibu pasca melahirkan',
                supportText:
                    'Membantu ibu dalam merawat bayi baru lahir dengan tips dan trik praktis.',
                features: [
                  'Cara memandikan',
                  'Perawatan tali pusat',
                  'Pola tidur bayi',
                  'Tanda bayi sehat',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewbornCareGuide(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSection(
                context: context,
                title: 'Pemberian ASI dan Konsultasi Menyusui',
                description:
                    'Membantu ibu memahami teknik menyusui yang benar dan memberi akses ke konsultan laktasi.',
                icon: Icons.pregnant_woman,
                color: Colors.orange,
                targetAudience: 'Ibu menyusui',
                supportText:
                    'Membantu ibu dalam proses menyusui dengan informasi dan dukungan langsung dari ahli.',
                features: [
                  'Teknik menyusui',
                  'Posisi yang tepat',
                  'Konsultasi online',
                  'Solusi masalah ASI',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BreastfeedingGuide(),
                    ),
                  );
                },
                featured: true,
              ),
              const SizedBox(height: 24),
              _buildRecoveryTipsCard(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required BuildContext context, // Tambahkan parameter context
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

  Widget _buildRecoveryTipsCard() {
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
                  Icons.lightbulb_outline,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Tips Pemulihan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('Istirahat yang cukup saat bayi tidur'),
            _buildTipItem('Konsumsi makanan bergizi dan banyak minum air'),
            _buildTipItem('Lakukan perawatan luka dengan teratur'),
            _buildTipItem('Jangan ragu meminta bantuan keluarga'),
            _buildTipItem('Perhatikan tanda-tanda infeksi atau komplikasi'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFF6B57D2),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
