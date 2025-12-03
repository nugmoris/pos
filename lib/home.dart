import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'ganti_pwd.dart';
import 'login.dart';
import 'var_provider.dart';

class HomeSalesPage extends ConsumerStatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;
  final String varnmlok;
  final String myversion1;
  final String currentVersion;

  HomeSalesPage(this.varpbuser, this.varbagian, this.varlks, this.varnmlok,
      this.myversion1, this.currentVersion);

  @override
  ConsumerState<HomeSalesPage> createState() => _HomeSalesPageState();
}

class _HomeSalesPageState extends ConsumerState<HomeSalesPage> {
  final NumberFormat numberFormat = NumberFormat.decimalPattern('id_ID');

  void lapPenjualanFunction() {
    Navigator.pushNamed(context, '/lapjual', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void stockFunction() {
    Navigator.pushNamed(context, '/lapstok', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void daftarHargaFunction() {
    Navigator.pushNamed(context, '/daftarharga', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void setorFunction() {
    Navigator.pushNamed(context, '/setor', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void penjKaryawanFunction() {
    Navigator.pushNamed(context, '/penjkary', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void lapsetor() {
    Navigator.pushNamed(context, '/daftarsetor', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void julablmlunas() {
    Navigator.pushNamed(context, '/daftarblmlunas', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void laporanFunction() {
    Navigator.pushNamed(context, '/lapkas', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok
    ]);
  }

  void returjual() {
    Navigator.pushNamed(context, '/returjual', arguments: [
      widget.varpbuser,
      widget.varbagian,
      widget.varlks,
      widget.varnmlok,
      saldoProvider.toString(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final saldoKas = ref.watch(saldoProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                children: [
                  Text(
                    'Koperasi Kasih',
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.varnmlok,
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: Icon(Icons.menu_rounded, color: Color(0xFF1A1A1A)),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.lock_outline,
                                color: Color(0xFF1A1A1A)),
                            title: Text('Ganti Password',
                                style: GoogleFonts.plusJakartaSans()),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GantiPwdPage(widget.varpbuser),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text('Logout',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.red)),
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                      myversion1: widget.myversion1,
                                      currentVersion: widget.currentVersion),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.varpbuser,
                        style: GoogleFonts.plusJakartaSans(
                          color: Color(0xFF1A1A1A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'v${widget.currentVersion}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saldo Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 20),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Saldo Kas',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Rp ${saldoKas.isNegative ? numberFormat.format(-saldoKas) : numberFormat.format(saldoKas)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Quick Action Button
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/jual',
                            arguments: [
                              widget.varpbuser,
                              widget.varbagian,
                              widget.varlks,
                              widget.varnmlok,
                              saldoKas.toString(),
                            ],
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF10B981).withOpacity(0.4),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            CupertinoIcons.cart_fill_badge_plus,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Menu Grid
                    Text(
                      'Menu Utama',
                      style: GoogleFonts.plusJakartaSans(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                      children: [
                        _buildMenuCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Lap.\nPenjualan',
                          onTap: lapPenjualanFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Lap. \nStock',
                          onTap: stockFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.sell_outlined,
                          label: 'Daftar\nHarga',
                          onTap: daftarHargaFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.assignment_return_outlined,
                          label: 'Retur\nPenjualan',
                          onTap: returjual,
                        ),
                        _buildMenuCard(
                          icon: Icons.paid_outlined,
                          label: 'Setor',
                          onTap: setorFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.person_outline,
                          label: ' Lap. \nPenj.\nKaryawan',
                          onTap: penjKaryawanFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.description_outlined,
                          label: 'Laporan\nKas',
                          onTap: laporanFunction,
                        ),
                        _buildMenuCard(
                          icon: Icons.list_alt_outlined,
                          label: 'Daftar\nSetoran',
                          onTap: lapsetor,
                        ),
                        _buildMenuCard(
                          icon: Icons.pending_actions_outlined,
                          label: 'Belum\nLunas',
                          onTap: julablmlunas,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1A1A1A).withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF3B82F6),
                size: 28,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xFF1A1A1A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
