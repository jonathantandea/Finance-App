import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../providers/user_profile_provider.dart';
import '../utils/constants.dart';
import 'expenses_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Controller untuk Input Transaksi
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncomeType = false;

  @override
  void initState() {
    super.initState();
    // Setup Animasi Masuk Premium
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Fungsi Menampilkan BottomSheet Input Transaksi
  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Handle Bar
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Tambah Transaksi', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              
              // Input Title
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('Judul (mis: Makan Siang)'),
              ),
              const SizedBox(height: 15),
              
              // Input Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Jumlah (mis: 50000)'),
              ),
              const SizedBox(height: 20),

              // Toggle Income/Spending
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Expanded(child: _toggleOption('Pengeluaran', false)),
                    Expanded(child: _toggleOption('Pemasukan', true)),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Tombol Simpan di BottomSheet
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                      final amount = double.tryParse(_amountController.text) ?? 0;
                      context.read<AppProvider>().addTransaction(
                        title: _titleController.text,
                        amount: amount,
                        isIncome: _isIncomeType,
                        date: DateTime.now(),
                      );
                      Navigator.pop(context);
                      _titleController.clear();
                      _amountController.clear();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transaksi berhasil ditambahkan!', style: GoogleFonts.poppins()), backgroundColor: AppColors.incomeGreen),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Simpan Transaksi', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleOption(String label, bool value) {
    final isSelected = _isIncomeType == value;
    return GestureDetector(
      onTap: () => setState(() => _isIncomeType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isSelected ? Colors.black : Colors.grey[600])),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      filled: true,
      fillColor: AppColors.background.withOpacity(0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    // Kita tidak perlu listen UserProfileProvider di sini kecuali ingin menampilkan nama real-time tanpa restart
    // Tapi karena kita pakai Provider, nama akan update otomatis jika kita akses via context.watch atau read di widget tree
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // 1. HEADER DENGAN AKSES PROFIL
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Halo,', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkText, fontWeight: FontWeight.w400)),
                                  // Nama diambil dari UserProfileProvider
                                  Consumer<UserProfileProvider>(
                                    builder: (context, profileProv, _) {
                                      return Text(
                                        profileProv.profile.name,
                                        style: GoogleFonts.poppins(fontSize: 20, color: AppColors.darkText, fontWeight: FontWeight.w700),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // IKON PROFIL KLIKABLE
                              GestureDetector(
                                onTap: () {
                                  // Navigasi dengan CupertinoPageRoute manual jika ingin spesifik, 
                                  // tapi karena sudah diset global di main.dart, Navigator.push biasa sudah cukup.
                                  Navigator.push(context, CupertinoPageRoute(builder: (_) => const ProfileScreen()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.primary,
                                    child: const Icon(Icons.person, color: Colors.black, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. BOX ISLAND UTAMA
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Balance', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w400)),
                                  GestureDetector(
                                    onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                                    child: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600], size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isBalanceVisible
                                    ? 'Rp.${appProvider.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
                                    : 'Rp. ••••••••',
                                style: GoogleFonts.poppins(fontSize: 32, color: AppColors.darkText, fontWeight: FontWeight.w700, letterSpacing: -1.0),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  _buildSummaryItem('Pemasukan', '+Rp.${appProvider.totalIncome.toStringAsFixed(0)}', AppColors.incomeGreen),
                                  Container(height: 40, width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 10)),
                                  _buildSummaryItem('Pengeluaran', '-Rp.${appProvider.totalSpending.toStringAsFixed(0)}', AppColors.spendingRed),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. FLOATING ISLAND (Transaksi Terakhir)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Transaksi Terakhir', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkText, fontWeight: FontWeight.w600)),
                                  TextButton(
                                    onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const ExpensesListScreen())),
                                    child: Text('Lihat Semua', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              if (appProvider.transactions.isEmpty)
                                Center(child: Text('Belum ada transaksi', style: GoogleFonts.poppins(color: Colors.grey)))
                              else
                                ...appProvider.transactions.take(3).map((trx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                                            child: Icon(trx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: trx.isIncome ? AppColors.incomeGreen : AppColors.spendingRed, size: 16),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(trx.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                              Text('${trx.date.day}/${trx.date.month}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.grey[600])),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(trx.displayAmount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: trx.amountColor)),
                                    ],
                                  ),
                                )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. BUTTON ISLAND (DIREVISI: HAPUS SETTINGS, TAMBAH LOGIKA ADD)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home
                  _buildNavButton(Icons.home_rounded, true, () {}),
                  // Expenses
                  _buildNavButton(Icons.receipt_long_rounded, false, () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const ExpensesListScreen()));
                  }),
                  // ADD BUTTON (TENGAH BESAR) - SEKARANG BERFUNGSI
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.black, size: 28),
                        onPressed: _showAddTransactionSheet, // Logika dipanggil di sini
                      ),
                    ),
                  ),
                  // Profile (Ganti Settings dengan Profile jika mau, atau biarkan kosong/hanya 4 tombol)
                  // Sesuai request: Hapus Settings. Kita ganti ikon terakhir dengan Profile agar seimbang, atau biarkan 3 tombol + 1 tengah.
                  // Mari kita buat tombol ke-4 adalah Profile juga untuk akses cepat alternatif
                  _buildNavButton(Icons.person_outline_rounded, false, () {
                     Navigator.push(context, CupertinoPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: isActive ? AppColors.primary : Colors.grey[600], size: 24),
      ),
    );
  }
}