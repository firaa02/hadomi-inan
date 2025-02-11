import 'package:flutter/material.dart';

class BreastfeedingGuide extends StatelessWidget {
  const BreastfeedingGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Panduan Menyusui',
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
            _buildContentSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Text(
        'Panduan lengkap teknik menyusui dan informasi konsultasi laktasi',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContentSections() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGuideSection(
            title: 'Teknik Menyusui',
            description: 'Panduan posisi dan cara menyusui yang benar',
            icon: Icons.baby_changing_station,
            color: Colors.blue,
            recommendations: [
              'Posisikan bayi sejajar dengan payudara',
              'Pastikan mulut bayi terbuka lebar',
              'Seluruh puting dan areola masuk ke mulut bayi',
              'Dagu bayi menempel pada payudara',
              'Bibir bayi terlipat keluar'
            ],
            notes:
                'Posisi yang tepat akan membuat menyusui lebih nyaman dan efektif.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Posisi Menyusui',
            description: 'Berbagai posisi menyusui yang nyaman',
            icon: Icons.pregnant_woman,
            color: Colors.green,
            recommendations: [
              'Posisi menggendong (Cradle Hold)',
              'Posisi football hold',
              'Posisi berbaring menyamping',
              'Posisi duduk dengan bantal menyusui',
              'Posisi laid-back breastfeeding'
            ],
            notes: 'Coba berbagai posisi untuk menemukan yang paling nyaman.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Perawatan Payudara',
            description: 'Cara merawat payudara selama menyusui',
            icon: Icons.healing,
            color: Colors.orange,
            recommendations: [
              'Jaga kebersihan payudara',
              'Gunakan bra yang nyaman dan mendukung',
              'Oleskan ASI pada puting yang lecet',
              'Kompres hangat sebelum menyusui',
              'Kompres dingin untuk mengurangi bengkak'
            ],
            notes:
                'Perawatan payudara yang baik mencegah masalah dalam menyusui.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Konsultasi Laktasi',
            description: 'Layanan konsultasi dengan ahli laktasi',
            icon: Icons.medical_services,
            color: Colors.purple,
            recommendations: [
              'Konsultasi online via aplikasi',
              'Kunjungan konsultan ke rumah',
              'Konsultasi di klinik laktasi',
              'Grup dukungan sesama ibu menyusui',
              'Forum tanya jawab dengan ahli'
            ],
            notes:
                'Jangan ragu untuk berkonsultasi jika mengalami kesulitan menyusui.',
          ),
          const SizedBox(height: 24),
          _buildCommonIssuesCard(),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> recommendations,
    required String notes,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panduan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendations.map((recommendation) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonIssuesCard() {
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
                  Icons.help_outline,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Masalah Umum',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildIssueItem('Puting lecet atau nyeri'),
            _buildIssueItem('Payudara bengkak'),
            _buildIssueItem('ASI tidak cukup'),
            _buildIssueItem('Bayi sulit menghisap'),
            _buildIssueItem('Mastitis atau radang payudara'),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(String text) {
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
