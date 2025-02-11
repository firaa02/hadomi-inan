import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'checkup',
      'title': 'Pengingat Pemeriksaan',
      'message': 'Jadwal pemeriksaan kehamilan minggu ke-24 dalam 2 hari',
      'time': '2 jam yang lalu',
      'icon': Icons.calendar_month,
      'color': Colors.blue,
      'isRead': false,
    },
    {
      'type': 'development',
      'title': 'Perkembangan Janin',
      'message': 'Bayi Anda sekarang sebesar papaya! Lihat perkembangannya',
      'time': '5 jam yang lalu',
      'icon': Icons.child_friendly,
      'color': Colors.green,
      'isRead': false,
    },
    {
      'type': 'tip',
      'title': 'Tips Harian',
      'message': 'Waktu yang tepat untuk memulai senam hamil',
      'time': '1 hari yang lalu',
      'icon': Icons.tips_and_updates,
      'color': Colors.orange,
      'isRead': true,
    },
    {
      'type': 'reminder',
      'title': 'Pengingat Vitamin',
      'message': 'Jangan lupa minum vitamin prenatal Anda hari ini',
      'time': '1 hari yang lalu',
      'icon': Icons.medication,
      'color': Colors.purple,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification['isRead'] = true;
                }
              });
            },
            child: const Text(
              'Tandai Dibaca',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNotificationStat(
            'Baru',
            notifications.where((n) => !n['isRead']).length.toString(),
            Icons.notifications_active,
          ),
          _buildNotificationStat(
            'Total',
            notifications.length.toString(),
            Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStat(String label, String count, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['message']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Warna background yang lebih kontras untuk notifikasi yang belum dibaca
          color:
              notification['isRead'] ? Colors.white : const Color(0xFFF0EEFF),
          borderRadius: BorderRadius.circular(12),
          // Border khusus untuk notifikasi yang belum dibaca
          border: notification['isRead']
              ? null
              : Border.all(color: const Color(0xFF6B57D2).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Indikator unread di sisi kiri
            if (!notification['isRead'])
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B57D2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: notification['isRead']
                      ? FontWeight.w500
                      : FontWeight.bold,
                  fontSize: 16,
                  // Warna text yang lebih gelap untuk unread
                  color: notification['isRead']
                      ? Colors.black87
                      : const Color(0xFF2D3142),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      color: notification['isRead']
                          ? Colors.grey[600]
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!notification['isRead'])
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B57D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Baru',
                            style: TextStyle(
                              color: Color(0xFF6B57D2),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  notification['isRead'] = true;
                });
                _handleNotificationTap(notification);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan melihat notifikasi di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Implement navigation or actions based on notification type
    switch (notification['type']) {
      case 'checkup':
        // Navigate to appointment screen
        print('Navigate to appointment screen');
        break;
      case 'development':
        // Navigate to fetal development screen
        print('Navigate to fetal development screen');
        break;
      case 'tip':
        // Navigate to tips detail
        print('Navigate to tips detail');
        break;
      case 'reminder':
        // Navigate to medication reminder
        print('Navigate to medication reminder');
        break;
    }
  }
}
