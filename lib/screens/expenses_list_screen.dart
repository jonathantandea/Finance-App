import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Semua Transaksi',
          style: GoogleFonts.poppins(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 100), // Space untuk button island jika ingin ditambah di sini juga
        itemCount: provider.transactions.length,
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, // Menggunakan putih agar kontras dengan background
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
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
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700, // Bold untuk judul
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400, // Regular untuk tanggal
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  transaction.displayAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700, // Bold untuk angka
                    color: transaction.amountColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Bisa tambahkan FAB jika perlu tambah transaksi cepat dari halaman ini
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buka Form Tambah Transaksi")));
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}