import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AppProvider extends ChangeNotifier {
  // Saldo awal (bisa diubah sesuai kebutuhan)
  double _balance = 1000000;

  // Data transaksi awal (Dummy Data)
  List<Transaction> _transactions = [
    Transaction(
      title: 'Gaji Bulanan',
      amount: 19000000,
      isIncome: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      title: 'Beli Motor',
      amount: 19000000,
      isIncome: false,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      title: 'Makan Siang',
      amount: 50000,
      isIncome: false,
      date: DateTime.now(),
    ),
  ];

  // --- GETTERS ---
  
  // Mendapatkan saldo saat ini
  double get balance => _balance;

  // Mendapatkan daftar semua transaksi
  List<Transaction> get transactions => _transactions;

  // Menghitung total pemasukan
  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  // Menghitung total pengeluaran
  double get totalSpending => _transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  // --- METHODS ---

  /// Menambahkan transaksi baru
  /// Parameter: title, amount, isIncome, date
  void addTransaction({
    required String title,
    required double amount,
    required bool isIncome,
    required DateTime date,
  }) {
    // Buat objek transaksi baru
    final newTransaction = Transaction(
      title: title,
      amount: amount,
      isIncome: isIncome,
      date: date,
    );

    // Masukkan ke paling atas list (index 0)
    _transactions.insert(0, newTransaction);

    // Update saldo
    if (isIncome) {
      _balance += amount;
    } else {
      _balance -= amount;
    }

    // Beritahu UI untuk refresh
    notifyListeners();
  }

  /// Menghapus transaksi berdasarkan index
  /// Digunakan oleh tombol "X" dan fitur Swipe-to-Delete
  void deleteTransaction(int index) {
    if (index >= 0 && index < _transactions.length) {
      final removedTransaction = _transactions[index];

      // Hapus dari list
      _transactions.removeAt(index);

      // Kembalikan saldo (reverse logic)
      if (removedTransaction.isIncome) {
        // Jika yang dihapus adalah pemasukan, maka saldo berkurang
        _balance -= removedTransaction.amount;
      } else {
        // Jika yang dihapus adalah pengeluaran, maka saldo bertambah (kembali)
        _balance += removedTransaction.amount;
      }

      // Beritahu UI untuk refresh
      notifyListeners();
    }
  }

  /// (Opsional) Membersihkan semua transaksi
  void clearAllTransactions() {
    _transactions.clear();
    _balance = 0;
    notifyListeners();
  }
}