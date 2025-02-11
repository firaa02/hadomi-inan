import 'package:flutter/material.dart';

class NewbornCareGuide extends StatelessWidget {
  const NewbornCareGuide({super.key});

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
          'Perawatan Bayi Baru Lahir',
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
        'Panduan lengkap merawat bayi baru lahir dengan aman dan nyaman',
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
          _buildCareSection(
            title: 'Memandikan Bayi',
            description: 'Panduan cara memandikan bayi dengan aman',
            icon: Icons.bathtub,
            color: Colors.blue,
            recommendations: [
              'Siapkan semua perlengkapan sebelum memandikan',
              'Pastikan suhu air hangat (36-37°C)',
              'Dukung kepala dan leher bayi saat memandikan',
              'Mulai dari bagian paling bersih ke yang kotor',
              'Keringkan dengan lembut dan segera pakaikan baju'
            ],
            notes:
                'Tunggu hingga tali pusat lepas sebelum memandikan bayi secara penuh.',
          ),
          const SizedBox(height: 16),
          _buildCareSection(
            title: 'Perawatan Tali Pusat',
            description: 'Cara merawat tali pusat hingga lepas',
            icon: Icons.healing,
            color: Colors.green,
            recommendations: [
              'Jaga area tali pusat tetap kering dan bersih',
              'Bersihkan dengan alkohol 70% atau air steril',
              'Lipat popok di bawah tali pusat',
              'Hindari membungkus area tali pusat',
              'Perhatikan tanda-tanda infeksi'
            ],
            notes:
                'Tali pusat biasanya lepas dalam 5-15 hari. Hubungi dokter jika ada tanda infeksi.',
          ),
          const SizedBox(height: 16),
          _buildCareSection(
            title: 'Pola Tidur Bayi',
            description: 'Memahami dan mengatur pola tidur bayi',
            icon: Icons.bedtime,
            color: Colors.purple,
            recommendations: [
              'Bayi baru lahir tidur 16-17 jam sehari',
              'Tidurkan bayi dalam posisi terlentang',
              'Atur suhu ruangan 24-26°C',
              'Kenali tanda-tanda mengantuk',
              'Bedakan tangisan lelah dan lapar'
            ],
            notes:
                'Setiap bayi memiliki pola tidur berbeda. Yang terpenting adalah kualitas tidurnya.',
          ),
          const SizedBox(height: 16),
          _buildCareSection(
            title: 'Mengganti Popok',
            description: 'Panduan mengganti popok dengan benar',
            icon: Icons.child_care,
            color: Colors.orange,
            recommendations: [
              'Ganti popok segera saat basah/kotor',
              'Bersihkan dari depan ke belakang',
              'Keringkan area popok dengan lembut',
              'Berikan krim ruam jika diperlukan',
              'Pastikan popok tidak terlalu ketat'
            ],
            notes:
                'Bayi baru lahir bisa membutuhkan 8-10 kali pergantian popok sehari.',
          ),
          const SizedBox(height: 24),
          _buildDangerSignsCard(),
        ],
      ),
    );
  }

  Widget _buildCareSection({
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

  Widget _buildDangerSignsCard() {
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
                  'Tanda Bahaya pada Bayi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildWarningItem('Suhu badan tinggi atau rendah'),
            _buildWarningItem('Malas minum atau muntah terus'),
            _buildWarningItem('Tali pusat kemerahan atau berbau'),
            _buildWarningItem('Bayi kuning (ikterus)'),
            _buildWarningItem('Tangisan lemah atau tidak menangis'),
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
