import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/bandingin_tab.dart';
import '../tabs/profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _tabs = [
    const DashboardTab(),
    BandinginTab(key: bandinginTabKey),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Banding.in'),
        backgroundColor: const Color(0xFFD6ECFB),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: primaryBlue,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF98CBEB), width: 1.5),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 80,
            child: IndexedStack(
              index: _selectedIndex,
              children: _tabs,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: cardWhite,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(0, Icons.grid_view, 'Dashboard'),
                            const SizedBox(width: 40),
                            _buildNavItem(2, Icons.account_circle_outlined, 'Profil'),
                          ],
                        ),
                        Positioned(
                          top: -20,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: md, vertical: radiusMd),
                              decoration: BoxDecoration(
                                gradient: _selectedIndex == 1 ? premiumGradient : null,
                                color: _selectedIndex == 1 ? null : bgDashed,
                                borderRadius: BorderRadius.circular(radiusLg),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.compare_arrows_rounded,
                                    color: _selectedIndex == 1 ? Colors.white : textDark,
                                  ),
                                  Text(
                                    'Bandingkan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _selectedIndex == 1 ? Colors.white : textDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(sm),
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue.withAlpha(25) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isSelected ? primaryBlue : greyText),
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isSelected ? primaryBlue : greyText,
            ),
          ),
        ],
      ),
    );
  }
}
