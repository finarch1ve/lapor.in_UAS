import 'package:flutter/material.dart';
class TicketData {
  static List<Map<String, dynamic>> tickets = [
    {
      'id': '#001',
      'title': 'Tidak bisa login sistem',
      'status': 'Menunggu',
      'date': '21 Apr 2026',
      'category': 'Software',
      'history': [
        {'action': 'Tiket dibuat', 'time': '21 Apr 2026, 08:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '21 Apr 2026, 08:01', 'by': 'Sistem'},
      ],
    },
    {
      'id': '#002',
      'title': 'Printer rusak lantai 2',
      'status': 'Diproses',
      'date': '20 Apr 2026',
      'category': 'Hardware',
      'history': [
        {'action': 'Tiket dibuat', 'time': '20 Apr 2026, 09:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '20 Apr 2026, 09:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '20 Apr 2026, 10:00', 'by': 'Admin'},
        {'action': 'Status diubah ke Diproses', 'time': '20 Apr 2026, 11:00', 'by': 'Helpdesk'},
      ],
    },
    {
      'id': '#003',
      'title': 'Reset password email',
      'status': 'Selesai',
      'date': '19 Apr 2026',
      'category': 'Software',
      'history': [
        {'action': 'Tiket dibuat', 'time': '19 Apr 2026, 07:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '19 Apr 2026, 07:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '19 Apr 2026, 08:00', 'by': 'Admin'},
        {'action': 'Status diubah ke Diproses', 'time': '19 Apr 2026, 09:00', 'by': 'Helpdesk'},
        {'action': 'Tiket diselesaikan', 'time': '19 Apr 2026, 12:00', 'by': 'Helpdesk'},
      ],
    },
    {
      'id': '#004',
      'title': 'Koneksi internet lambat',
      'status': 'Menunggu',
      'date': '18 Apr 2026',
      'category': 'Network',
      'history': [
        {'action': 'Tiket dibuat', 'time': '18 Apr 2026, 14:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '18 Apr 2026, 14:01', 'by': 'Sistem'},
      ],
    },
    {
      'id': '#005',
      'title': 'Komputer tidak menyala',
      'status': 'Diproses',
      'date': '17 Apr 2026',
      'category': 'Hardware',
      'history': [
        {'action': 'Tiket dibuat', 'time': '17 Apr 2026, 10:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '17 Apr 2026, 10:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '17 Apr 2026, 11:00', 'by': 'Admin'},
      ],
    },
  ];

  static String generateId() {
    return '#${(tickets.length + 1).toString().padLeft(3, '0')}';
  }

  static String getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
