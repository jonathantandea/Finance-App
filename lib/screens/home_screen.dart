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

  @override
  void initState() {
    super.initState();
    // Load data dari SharedPreferences saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    // Tampilkan Loading Screen sementara data diambil
    if (appProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

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
                        // 1. HEADER (RAPI - Tanpa Box Kosong)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Grup Kiri: Logo + Nama
                              Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet, color: AppColors.primary)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Halo,', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.w400)),
                                      Consumer<UserProfileProvider>(
                                        builder: (context, profileProv, _) {
                                          return Text(
                                            profileProv.profile.name,
                                            style: GoogleFonts.poppins(fontSize: 18, color: AppColors.darkText, fontWeight: FontWeight.w700),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Grup Kanan: Ikon Profil
                              GestureDetector(
                                onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const ProfileScreen())),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary,
                                    child: const Icon(Icons.person, color: Colors.black, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. BOX ISLAND UTAMA (Saldo)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.all(20),
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
                                  Text('Total Balance', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                  GestureDetector(
                                    onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                                    child: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600], size: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isBalanceVisible
                                    ? 'Rp.${appProvider.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
                                    : 'Rp. ••••••••',
                                style: GoogleFonts.poppins(fontSize: 28, color: AppColors.darkText, fontWeight: FontWeight.w700, letterSpacing: -1.0),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _buildSummaryItem('Pemasukan', '+Rp.${appProvider.totalIncome.toStringAsFixed(0)}', AppColors.incomeGreen),
                                  Container(height: 35, width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 15)),
                                  _buildSummaryItem('Pengeluaran', '-Rp.${appProvider.totalSpending.toStringAsFixed(0)}', AppColors.spendingRed),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. FLOATING ISLAND (Transaksi Terakhir)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  Text('Aktivitas Terbaru', style: GoogleFonts.poppins(fontSize: 15, color: AppColors.darkText, fontWeight: FontWeight.w600)),
                                  TextButton(
                                    onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const ExpensesListScreen())),
                                    child: Text('Lihat Semua', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (appProvider.transactions.isEmpty)
                                Center(child: Text('Belum ada transaksi', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)))
                              else
                                ...appProvider.transactions.take(3).map((trx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                            child: Icon(trx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: trx.isIncome ? AppColors.incomeGreen : AppColors.spendingRed, size: 14),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(trx.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                              Text('${trx.date.day}/${trx.date.month}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.grey[600])),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(trx.displayAmount, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: trx.amountColor)),
                                    ],
                                  ),
                                )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. BUTTON ISLAND (3 Tombol)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavButton(Icons.home_rounded, true, () {}),
                  _buildNavButton(Icons.receipt_long_rounded, false, () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const ExpensesListScreen()));
                  }),
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
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isActive ? AppColors.primary : Colors.grey[600], size: 24),
      ),
    );
  }
}