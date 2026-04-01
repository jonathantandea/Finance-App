import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncomeType = false;

  void _showAddTransactionSheet() {
    _titleController.clear();
    _amountController.clear();
    setState(() => _isIncomeType = false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  Text('Tambah Transaksi', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                  const SizedBox(height: 25),
                  TextField(controller: _titleController, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkText), decoration: _inputDecoration('Judul')),
                  const SizedBox(height: 15),
                  TextField(controller: _amountController, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkText), decoration: _inputDecoration('Jumlah')),
                  const SizedBox(height: 25),
                  Text('Jenis Transaksi:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Expanded(child: _toggleOption(setModalState, 'Pengeluaran', false, AppColors.spendingRed)),
                        const SizedBox(width: 4),
                        Expanded(child: _toggleOption(setModalState, 'Pemasukan', true, AppColors.incomeGreen)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
                        final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
                        context.read<AppProvider>().addTransaction(
                          title: _titleController.text,
                          amount: amount,
                          isIncome: _isIncomeType,
                          date: DateTime.now(),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Disimpan!', style: GoogleFonts.poppins()), backgroundColor: _isIncomeType ? AppColors.incomeGreen : AppColors.spendingRed));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 8, shadowColor: AppColors.primary.withOpacity(0.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _toggleOption(StateSetter setModalState, String label, bool value, Color color) {
    final isSelected = _isIncomeType == value;
    return GestureDetector(
      onTap: () => setModalState(() => _isIncomeType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.grey[600], fontSize: 13)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      filled: true, fillColor: AppColors.background.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkText), onPressed: () => Navigator.pop(context)),
        title: Text('Semua Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.darkText, fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView.builder(
        // Padding bawah diperbesar agar item terakhir tidak tertutup FAB
        padding: const EdgeInsets.only(top: 10, bottom: 120), 
        itemCount: provider.transactions.length,
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          
          return Dismissible(
            key: Key(transaction.title + transaction.date.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: AppColors.spendingRed, borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Hapus?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  content: Text('Hapus "${transaction.title}"?', style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.spendingRed), child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white))),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              context.read<AppProvider>().deleteTransaction(index);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus'), backgroundColor: AppColors.spendingRed));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16), // Padding diperkecil sedikit agar muat
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  // Icon Kategori
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: transaction.isIncome ? AppColors.incomeGreen.withOpacity(0.1) : AppColors.spendingRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction.isIncome ? AppColors.incomeGreen : AppColors.spendingRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Judul & Tanggal (Menggunakan Flexible agar tidak overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Jumlah & Tombol X
                  Row(
                    mainAxisSize: MainAxisSize.min, // Agar tidak melebar berlebihan
                    children: [
                      Text(
                        transaction.displayAmount,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: transaction.amountColor),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          context.read<AppProvider>().deleteTransaction(index);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dihapus'), backgroundColor: AppColors.spendingRed));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                          child: Icon(Icons.close, size: 16, color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionSheet,
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text('Tambah', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}