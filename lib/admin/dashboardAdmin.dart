import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'donors.dart';
import 'donors_details.dart';
import 'reports.dart';

class AdminDashboard extends StatefulWidget {
  final String? adminName;

  const AdminDashboard({Key? key, this.adminName}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int? _hoveredIndex;
  String _adminName = '';

  final List<Widget> _tabs = [
    DashboardTab(),
    DonorsPage(),
    DonorDetailsAdminPage(),
    ReportsPage(),
  ];

  final List<String> _tabTitles = [
    'Dashboard',
    'Donors',
    'Donor Details',
    'Reports',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadAdminSession();
  }

  Future<void> _loadAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('admin_name');

    if (savedName != null) {
      setState(() {
        _adminName = savedName;
      });
    } else if (widget.adminName != null) {
      _adminName = widget.adminName!;
      prefs.setString('admin_name', _adminName);
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_name');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _onTabSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width < 600) {
      Navigator.pop(context); // Close drawer on mobile
    }
  }

  Widget buildSidebar() {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome $_adminName',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          buildTabButton('Dashboard', 0, icon: Icons.dashboard),
          buildTabButton('Donors', 1, icon: Icons.people),
          buildTabButton('Transaction Details', 2, icon: Icons.info_outline),
          buildTabButton('Reports', 3, icon: Icons.bar_chart),
          const Spacer(),
          buildTabButton('Logout', -1, icon: Icons.logout, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildTabButton(
    String title,
    int index, {
    bool isLogout = false,
    required IconData icon,
  }) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: isLogout ? _onLogout : () => _onTabSelect(index),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.black),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        onEnter: (event) {
          setState(() {
            _hoveredIndex = index;
          });
        },
        onExit: (event) {
          setState(() {
            _hoveredIndex = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? Drawer(child: buildSidebar()) : null,
      appBar:
          isMobile
              ? AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                iconTheme: const IconThemeData(
                  color: Colors.transparent,
                ), // hide default menu icon
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tabTitles[_selectedIndex],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
              )
              : null,
      body: Row(
        children: [
          if (!isMobile) buildSidebar(),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tabTitles[_selectedIndex],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: _onLogout,
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _tabs[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
