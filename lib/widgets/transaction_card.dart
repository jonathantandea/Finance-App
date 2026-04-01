import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(transaction.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            transaction.displayAmount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: transaction.amountColor),
          ),
        ],
      ),
    );
  }
}