import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _notifItem(
              "Anggaran Makan hampir habis!",
              "Kamu sudah memakai 86% dari limit makan bulan ini. Sisa Rp 43.000.",
              Icons.warning_amber_rounded,
              Colors.red,
              "2 jam lalu"
          ),
          _notifItem(
              "Transaksi berhasil dicatat",
              "Pengeluaran Rp 25.000 kategori Makanan telah disimpan.",
              Icons.check_circle_outline,
              Colors.green,
              "3 jam lalu"
          ),
          _notifItem(
              "Target Laptop 50% tercapai!",
              "Tabungan laptop kamu sudah setengah jalan. Semangat terus!",
              Icons.track_changes,
              Colors.blue,
              "Kemarin"
          ),
        ],
      ),
    );
  }

  Widget _notifItem(String title, String desc, IconData icon, Color color, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                SizedBox(height: 5),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}