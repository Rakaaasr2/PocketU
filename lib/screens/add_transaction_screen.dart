import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Dibutuhkan untuk TextInputFormatter
import 'package:intl/intl.dart';

// Class Formatter untuk merubah angka ke format ribuan secara otomatis saat mengetik
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    // Hapus titik yang ada sebelumnya untuk mendapatkan angka bersih
    String cleanText = newValue.text.replaceAll('.', '');
    double value = double.parse(cleanText);

    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String type = "Pengeluaran";
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> pengeluaranCategories = [
    {"name": "Makanan", "icon": Icons.fastfood, "color": Colors.orange},
    {"name": "Transport", "icon": Icons.directions_car, "color": Colors.blue},
    {"name": "Belanja", "icon": Icons.shopping_bag, "color": Colors.pink},
    {"name": "Hiburan", "icon": Icons.movie, "color": Colors.purple},
    {"name": "Tagihan", "icon": Icons.receipt_long, "color": Colors.red},
    {"name": "Kesehatan", "icon": Icons.medical_services, "color": Colors.teal},
  ];

  final List<Map<String, dynamic>> penghasilanCategories = [
    {"name": "Gaji", "icon": Icons.monetization_on, "color": Colors.green},
    {"name": "Bonus", "icon": Icons.card_giftcard, "color": Colors.orange},
    {"name": "Investasi", "icon": Icons.trending_up, "color": Colors.blue},
    {"name": "Lainnya", "icon": Icons.account_balance_wallet, "color": Colors.grey},
  ];

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentCategories =
    type == "Pengeluaran" ? pengeluaranCategories : penghasilanCategories;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF3F2FF), Color(0xFFEDECFF), Color(0xFFE5E2FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Tambah $type", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nominal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6C63FF)),
                  prefixText: "Rp ",
                  prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                  filled: true,
                  fillColor: const Color(0xFF6C63FF).withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
                ),
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  // DIUBAH JADI PUTIH BERSIH
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tanggal Transaksi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(DateFormat('dd MMMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(child: _typeButton("Pengeluaran", Icons.arrow_circle_down_rounded, Colors.red, type == "Pengeluaran")),
                  const SizedBox(width: 15),
                  Expanded(child: _typeButton("Penghasilan", Icons.arrow_circle_up_rounded, Colors.green, type == "Penghasilan")),
                ],
              ),

              const SizedBox(height: 25),
              const Text("Pilih Kategori", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2),
                itemCount: currentCategories.length,
                itemBuilder: (context, index) {
                  var cat = currentCategories[index];
                  bool isSelected = selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat['name']),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [if (!isSelected) const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'], color: isSelected ? Colors.white : cat['color']),
                          const SizedBox(height: 5),
                          Text(cat['name'], style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text("Catatan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Misal: Beli makan siang...",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_rounded, color: Colors.grey),
                  ),
                  filled: true,
                  // DIUBAH JADI PUTIH BERSIH
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () {
                String cleanAmount = _amountController.text.replaceAll('.', '');
                double amt = double.tryParse(cleanAmount) ?? 0;

                if (amt > 0 && selectedCategory != null) {
                  var catData = currentCategories.firstWhere((e) => e['name'] == selectedCategory);
                  Navigator.pop(context, {
                    "nominal": type == "Pengeluaran" ? -amt : amt,
                    "kategori": selectedCategory,
                    "catatan": _noteController.text,
                    "icon": catData['icon'],
                    "color": catData['color'],
                    "tgl": DateFormat('dd MMM yyyy').format(selectedDate),
                  });
                }
              },
              child: const Text("SIMPAN TRANSAKSI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String title, IconData icon, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        type = title;
        selectedCategory = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold
            )),
          ],
        ),
      ),
    );
  }
}