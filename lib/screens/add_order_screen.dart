import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false; // Default Spending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Order', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildInput('Title', _titleController, false),
              const SizedBox(height: 15),
              _buildInput('Amount', _amountController, true),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text('Spending/Income:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ToggleButtons(
                    isSelected: [_isIncome ? false : true, _isIncome],
                    onPressed: (int index) {
                      setState(() {
                        _isIncome = index == 1;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.black,
                    fillColor: AppColors.primary,
                    children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Spend')), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('Income'))],
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    Provider.of<AppProvider>(context, listen: false).addTransaction(
                      Transaction(
                        title: _titleController.text,
                        amount: amount,
                        isIncome: _isIncome,
                        date: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, bool isNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
          ),
        ),
      ],
    );
  }
}