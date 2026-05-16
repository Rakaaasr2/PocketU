import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  HistoryScreen({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Transaksi"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: transactions.isEmpty
          ? Center(child: Text("Belum ada riwayat transaksi"))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          var item = transactions[index];
          double nom = item['nominal'];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: item['color'].withOpacity(0.1),
              child: Icon(item['icon'], color: item['color'], size: 20),
            ),
            title: Text(item['kategori'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${item['tgl']} • ${item['catatan']}"),
            trailing: Text(
              "Rp ${NumberFormat.decimalPattern('id').format(nom.abs())}",
              style: TextStyle(color: nom < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}