import 'package:flutter/material.dart';

class PostpartumRecoveryGuide extends StatelessWidget {
  const PostpartumRecoveryGuide({super.key});

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
          'Panduan Pemulihan',
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
        'Panduan lengkap untuk pemulihan fisik dan mental pasca melahirkan',
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
          _buildRecoverySection(
            title: 'Pemulihan Fisik',
            description: 'Panduan perawatan fisik setelah melahirkan',
            icon: Icons.healing,
            color: Colors.blue,
            recommendations: [
              'Istirahat yang cukup, tidur saat bayi tidur',
              'Lakukan perawatan luka dengan benar dan teratur',
              'Jaga kebersihan area pemulihan',
              'Gunakan pembalut yang nyaman dan sering ganti',
              'Lakukan latihan kegel secara bertahap'
            ],
            notes:
                'Proses pemulihan fisik berbeda-beda untuk setiap ibu. Jangan memaksakan diri dan ikuti saran dokter.',
          ),
          const SizedBox(height: 16),
          _buildRecoverySection(
            title: 'Nutrisi dan Diet',
            description: 'Panduan nutrisi untuk ibu menyusui',
            icon: Icons.restaurant_menu,
            color: Colors.green,
            recommendations: [
              'Konsumsi makanan bergizi seimbang',
              'Minum air putih minimal 8 gelas sehari',
              'Konsumsi protein untuk penyembuhan',
              'Makan sayur dan buah untuk vitamin',
              'Konsumsi suplemen sesuai anjuran dokter'
            ],
            notes:
                'Nutrisi yang baik penting untuk pemulihan dan produksi ASI.',
          ),
          const SizedBox(height: 16),
          _buildRecoverySection(
            title: 'Kesehatan Mental',
            description: 'Menjaga kesehatan mental dan emosional',
            icon: Icons.psychology,
            color: Colors.purple,
            recommendations: [
              'Terima bantuan dari keluarga dan teman',
              'Komunikasikan perasaan dengan orang terdekat',
              'Luangkan waktu untuk istirahat dan relaksasi',
              'Hindari stress berlebihan',
              'Cari dukungan sesama ibu baru'
            ],
            notes:
                'Jangan ragu untuk mencari bantuan profesional jika mengalami gejala depresi pasca melahirkan.',
          ),
          const SizedBox(height: 16),
          _buildRecoverySection(
            title: 'Aktivitas Fisik',
            description: 'Panduan aktivitas yang aman',
            icon: Icons.directions_walk,
            color: Colors.orange,
            recommendations: [
              'Mulai dengan jalan kaki ringan',
              'Lakukan peregangan lembut',
              'Hindari angkat beban berat',
              'Tingkatkan aktivitas secara bertahap',
              'Istirahat jika merasa lelah'
            ],
            notes:
                'Konsultasikan dengan dokter sebelum memulai latihan fisik yang lebih intens.',
          ),
          const SizedBox(height: 24),
          _buildWarningSignsCard(),
        ],
      ),
    );
  }

  Widget _buildRecoverySection({
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

  Widget _buildWarningSignsCard() {
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
                  Icons.warning_amber,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Tanda Bahaya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildWarningItem('Demam tinggi atau menggigil'),
            _buildWarningItem('Perdarahan berlebihan'),
            _buildWarningItem('Nyeri perut yang parah'),
            _buildWarningItem('Perasaan sedih yang berkepanjangan'),
            _buildWarningItem('Kesulitan bernapas atau nyeri dada'),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(String text) {
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
