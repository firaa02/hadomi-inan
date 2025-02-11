import 'package:flutter/material.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

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
          'Daftar Perlengkapan Persalinan',
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
        'Daftar lengkap perlengkapan yang perlu disiapkan untuk persalinan',
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
          _buildChecklistSection(
            title: 'Perlengkapan Ibu',
            description: 'Kebutuhan pribadi ibu selama di rumah sakit',
            icon: Icons.pregnant_woman,
            color: Colors.pink,
            items: [
              'Baju ganti (4-5 set)',
              'Celana dalam (4-5 pcs)',
              'Pembalut ibu nifas (2-3 pack)',
              'Bra menyusui (2-3 pcs)',
              'Daster atau baju tidur (3-4 pcs)',
              'Handuk mandi dan waslap',
              'Peralatan mandi dan toiletries',
              'Sandal dan sepatu',
            ],
            notes:
                'Pilih pakaian yang nyaman dan mudah digunakan untuk menyusui.',
          ),
          const SizedBox(height: 16),
          _buildChecklistSection(
            title: 'Perlengkapan Bayi',
            description: 'Kebutuhan bayi baru lahir',
            icon: Icons.child_friendly,
            color: Colors.blue,
            items: [
              'Popok bayi (1-2 pack)',
              'Baju bayi (4-5 set)',
              'Bedong (3-4 pcs)',
              'Sarung tangan dan kaki bayi',
              'Topi bayi (2-3 pcs)',
              'Selimut bayi',
              'Tissue basah khusus bayi',
              'Perlengkapan perawatan tali pusat',
            ],
            notes:
                'Siapkan ukuran baju yang sesuai untuk bayi baru lahir (newborn size).',
          ),
          const SizedBox(height: 16),
          _buildChecklistSection(
            title: 'Dokumen Penting',
            description: 'Berkas-berkas yang diperlukan',
            icon: Icons.document_scanner,
            color: Colors.green,
            items: [
              'KTP suami dan istri',
              'Kartu Keluarga',
              'Buku KIA',
              'Kartu BPJS/Asuransi',
              'Surat rujukan (jika ada)',
              'Hasil USG terakhir',
              'Hasil laboratorium',
              'Uang tunai untuk keperluan darurat',
            ],
            notes:
                'Simpan semua dokumen dalam map plastik agar tidak basah atau rusak.',
          ),
          const SizedBox(height: 16),
          _buildChecklistSection(
            title: 'Perlengkapan Tambahan',
            description: 'Barang pendukung selama persalinan',
            icon: Icons.medical_services,
            color: Colors.orange,
            items: [
              'Makanan dan minuman ringan',
              'Kamera untuk dokumentasi',
              'Charger handphone',
              'Bantal dan selimut pribadi',
              'Kantong plastik',
              'Notes dan pulpen',
              'Musik relaksasi',
              'Sandal dalam ruangan',
            ],
            notes:
                'Barang tambahan untuk kenyamanan selama proses persalinan dan pemulihan.',
          ),
          const SizedBox(height: 24),
          _buildReminderCard(),
        ],
      ),
    );
  }

  Widget _buildChecklistSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> items,
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
                    'Daftar Barang:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) => Padding(
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
                                item,
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

  Widget _buildReminderCard() {
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
                  Icons.notifications_active,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Pengingat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReminderItem('Siapkan tas persalinan 2-3 minggu sebelum HPL'),
            _buildReminderItem('Pisahkan dokumen penting dalam map terpisah'),
            _buildReminderItem('Cek kelengkapan barang secara berkala'),
            _buildReminderItem('Simpan di tempat yang mudah dijangkau'),
            _buildReminderItem('Informasikan lokasi tas kepada keluarga'),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(String text) {
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
