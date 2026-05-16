import 'package:flutter/material.dart';

class ExportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ekspor Laporan"), backgroundColor: Color(0xFF6C63FF)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pilih periode", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: [
                _choiceChip("Bulan ini", true),
                _choiceChip("Bulan lalu", false),
                _choiceChip("3 Bulan", false),
                _choiceChip("Tahun ini", false),
              ],
            ),
            SizedBox(height: 30),
            Text("Format laporan", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _formatIcon(Icons.picture_as_pdf, "PDF", Colors.red),
                _formatIcon(Icons.table_chart, "Excel", Colors.green),
                _formatIcon(Icons.description, "CSV", Colors.blue),
              ],
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Laporan berhasil diunduh!")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C63FF)),
                child: Text("Unduh Sekarang", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Color(0xFF6C63FF).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? Color(0xFF6C63FF) : Colors.black),
    );
  }

  Widget _formatIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}