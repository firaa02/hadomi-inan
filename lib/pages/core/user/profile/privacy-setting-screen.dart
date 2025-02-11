import 'package:flutter/material.dart';

enum VisibilityOption { everyone, contacts, nobody }

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  Map<String, Map<String, dynamic>> privacySettings = {
    'Foto Profil': {
      'value': VisibilityOption.everyone,
      'icon': Icons.photo_outlined,
      'description': 'Foto profil Anda',
    },
    'Update Kehamilan': {
      'value': VisibilityOption.contacts,
      'icon': Icons.pregnant_woman_outlined,
      'description': 'Informasi terkait kehamilan Anda',
    },
    'Nomor Telepon': {
      'value': VisibilityOption.contacts,
      'icon': Icons.phone_outlined,
      'description': 'Nomor kontak Anda',
    },
    'Alamat': {
      'value': VisibilityOption.nobody,
      'icon': Icons.location_on_outlined,
      'description': 'Alamat tempat tinggal Anda',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan Privasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildSettingsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B57D2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.security_outlined,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Atur Privasi Data Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kontrol siapa yang dapat melihat informasi pribadi Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B57D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B57D2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Privasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPrivacyLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyLegend() {
    return Column(
      children: [
        _buildLegendItem(
          Icons.public,
          'Semua Orang',
          'Dapat dilihat oleh semua pengguna aplikasi',
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          Icons.group_outlined,
          'Kontak Saya',
          'Hanya dapat dilihat oleh kontak yang Anda tambahkan',
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          Icons.lock_outline,
          'Tidak Ada',
          'Informasi ini akan disembunyikan dari semua pengguna',
        ),
      ],
    );
  }

  Widget _buildLegendItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B57D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFF6B57D2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pengaturan Visibilitas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...privacySettings.entries.map((entry) {
              return _buildPrivacyOption(
                entry.key,
                entry.value['value'] as VisibilityOption,
                entry.value['icon'] as IconData,
                entry.value['description'] as String,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(
    String title,
    VisibilityOption currentValue,
    IconData icon,
    String description,
  ) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B57D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B57D2),
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getVisibilityText(currentValue),
                style: TextStyle(
                  fontSize: 13,
                  color: _getVisibilityColor(currentValue),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onTap: () => _showVisibilityDialog(title),
        ),
        const Divider(),
      ],
    );
  }

  Color _getVisibilityColor(VisibilityOption visibility) {
    switch (visibility) {
      case VisibilityOption.everyone:
        return Colors.green;
      case VisibilityOption.contacts:
        return Colors.blue;
      case VisibilityOption.nobody:
        return Colors.red;
    }
  }

  String _getVisibilityText(VisibilityOption visibility) {
    switch (visibility) {
      case VisibilityOption.everyone:
        return 'Semua orang';
      case VisibilityOption.contacts:
        return 'Kontak saya';
      case VisibilityOption.nobody:
        return 'Tidak ada';
    }
  }

  Future<void> _showVisibilityDialog(String setting) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Siapa yang dapat melihat\n$setting Anda?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVisibilityOption(
                context,
                setting,
                VisibilityOption.everyone,
                'Semua orang',
                Icons.public,
              ),
              _buildVisibilityOption(
                context,
                setting,
                VisibilityOption.contacts,
                'Kontak saya',
                Icons.group_outlined,
              ),
              _buildVisibilityOption(
                context,
                setting,
                VisibilityOption.nobody,
                'Tidak ada',
                Icons.lock_outline,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildVisibilityOption(
    BuildContext context,
    String setting,
    VisibilityOption visibility,
    String label,
    IconData icon,
  ) {
    final isSelected = privacySettings[setting]?['value'] == visibility;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            privacySettings[setting]?['value'] = visibility;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? const Color(0xFF6B57D2).withOpacity(0.1) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6B57D2) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isSelected ? const Color(0xFF6B57D2) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF6B57D2),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
