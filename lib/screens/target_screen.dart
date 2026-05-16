  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/intl.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'dart:convert';
  
  // Formatter otomatis untuk memunculkan titik ribuan saat mengetik nominal
  class CurrencyInputFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
      if (newValue.selection.baseOffset == 0) return newValue;
  
      String cleanText = newValue.text.replaceAll('.', '');
      double value = double.tryParse(cleanText) ?? 0;
      if (value == 0) return newValue.copyWith(text: '');
  
      final formatter = NumberFormat.decimalPattern('id');
      String newText = formatter.format(value);
  
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }
  
  class TargetScreen extends StatefulWidget {
    final double currentSaldo;
  
    const TargetScreen({Key? key, required this.currentSaldo}) : super(key: key);
  
    @override
    _TargetScreenState createState() => _TargetScreenState();
  }
  
  class _TargetScreenState extends State<TargetScreen> {
    List<Map<String, dynamic>> _listTarget = [];
  
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _savingController = TextEditingController();
  
    @override
    void initState() {
      super.initState();
      _loadAllTargetsData();
    }
  
    Future<void> _loadAllTargetsData() async {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('list_target_independen');
      if (jsonString != null) {
        setState(() {
          _listTarget = List<Map<String, dynamic>>.from(json.decode(jsonString));
        });
      }
    }
  
    Future<void> _saveAllTargetsData() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('list_target_independen', json.encode(_listTarget));
    }
  
    String _formatRupiah(double value) {
      return NumberFormat.decimalPattern('id').format(value);
    }
  
    // Fungsi khusus untuk menentukan warna secara dinamis berdasarkan persentase progress
    Color _getDynamicColor(int percentage) {
      if (percentage >= 100) {
        return const Color(0xFF00E676); // Hijau cerah kalau FULL
      } else if (percentage >= 50) {
        return const Color(0xFFFFB300); // Kuning/Oranye kalau SETENGAH
      } else {
        return const Color(0xFFFF5252); // Merah kalau DIKIT
      }
    }
  
    void _showAddTargetDialog() {
      _nameController.clear();
      _amountController.clear();
  
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Tambah Target Baru 🎯", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Misal: HP iPhone",
                  labelText: "Nama Target",
                  labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
                  filled: true,
                  fillColor: const Color(0xFF6C63FF).withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  labelText: "Nominal Target",
                  labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
                  filled: true,
                  fillColor: const Color(0xFF6C63FF).withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              onPressed: () {
                if (_nameController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                  String cleanAmount = _amountController.text.replaceAll('.', '');
                  double nominalVal = double.tryParse(cleanAmount) ?? 0;
  
                  setState(() {
                    _listTarget.add({
                      "id": DateTime.now().millisecondsSinceEpoch.toString(),
                      "nama": _nameController.text,
                      "target": nominalVal,
                      "terkumpul": 0.0,
                    });
                  });
                  _saveAllTargetsData();
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  
    void _showAddSavingDialog(int index) {
      _savingController.clear();
      var target = _listTarget[index];
      double sisaButuh = target['target'] - target['terkumpul'];
  
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Nabung buat ${target['nama']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: TextField(
            controller: _savingController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              prefixText: "Rp ",
              labelText: "Jumlah Uang Masuk",
              labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
              filled: true,
              fillColor: const Color(0xFF6C63FF).withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
              onPressed: () {
                String cleanSaving = _savingController.text.replaceAll('.', '');
                double jumlahNabung = double.tryParse(cleanSaving) ?? 0;
  
                if (jumlahNabung > sisaButuh) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("⚠️ Input kelebihan! Sisa kekurangan tinggal Rp ${_formatRupiah(sisaButuh)}")),
                  );
                  return;
                }
  
                setState(() {
                  _listTarget[index]['terkumpul'] += jumlahNabung;
                });
                _saveAllTargetsData();
                Navigator.pop(context);
  
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("🎉 Rp ${_formatRupiah(jumlahNabung)} berhasil dicatat ke celengan ${target['nama']}!")),
                );
              },
              child: const Text("Nabung", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }
  
    void _deleteTargetItem(int index) {
      setState(() {
        _listTarget.removeAt(index);
      });
      _saveAllTargetsData();
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F2FF),
        appBar: AppBar(
          title: Text("Target Finansial", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: _listTarget.isEmpty
            ? Center(
          child: Text(
            "Belum ada target finansial.\nKetuk tombol + di bawah untuk menambahkan!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          itemCount: _listTarget.length,
          itemBuilder: (context, index) {
            var item = _listTarget[index];
            double targetVal = item['target'].toDouble();
            double terkumpulVal = item['terkumpul'].toDouble();
            double sisaKekurangan = targetVal - terkumpulVal;
  
            double progressFraction = targetVal > 0 ? (terkumpulVal / targetVal).clamp(0.0, 1.0) : 0.0;
            int progressPercentage = (progressFraction * 100).toInt();
  
            // Memanggil fungsi penentu warna dinamis
            Color statusColor = _getDynamicColor(progressPercentage);
  
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8A84FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['nama'],
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, color: Colors.white70, size: 24),
                        onPressed: () => _deleteTargetItem(index),
                      )
                    ],
                  ),
                  Text("Total Kebutuhan: Rp ${_formatRupiah(targetVal)}", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sudah Terkumpul", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      Text(
                        "$progressPercentage%",
                        style: GoogleFonts.poppins(color: statusColor, fontSize: 14, fontWeight: FontWeight.bold), // Warna teks persentase dinamis
                      ),
                    ],
                  ),
                  Text("Rp ${_formatRupiah(terkumpulVal)}", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor), // Warna Progress Bar dinamis
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sisaKekurangan <= 0 ? "TARGET TERCAPAI! 🎉" : "Sisa Kekurangan: Rp ${_formatRupiah(sisaKekurangan)}",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: sisaKekurangan <= 0 ? const Color(0xFF00E676) : Colors.white70
                          ),
                        ),
                      ),
                      if (sisaKekurangan > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text("Nabung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () => _showAddSavingDialog(index),
                        )
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6C63FF),
          onPressed: _showAddTargetDialog,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      );
    }
  }