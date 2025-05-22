import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final Function(String)? onLinkTap;
  const Navbar({super.key, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child:
          screenWidth < 800
              ? _buildMobileNavbar(context)
              : _buildDesktopNavbar(context),
    );
  }

  Widget _buildDesktopNavbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text(
          'give',
          style: TextStyle(
            color: Colors.red,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            _navButton(context, 'Donate'),
            _navButton(context, 'Fundraiser'),
            _navButton(context, 'Testimonials'),
            _navButton(context, 'Blogs'),
            _navButton(context, 'About Us'),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _navButton(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        if (onLinkTap != null) {
          onLinkTap!(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildMobileNavbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'give',
          style: TextStyle(
            color: Colors.red,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
        ),
      ],
    );
  }
}

class MobileNavDrawer extends StatelessWidget {
  final Function(String)? onLinkTap;
  const MobileNavDrawer({super.key, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Top branding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  // Replace with your actual logo
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('../../assets/andrej.jpg'),
                    ),
                  const SizedBox(width: 12),
                  const Text(
                    'give',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Navigation links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _drawerNavItem(context, 'Donate'),
                  _drawerNavItem(context, 'Fundraiser'),
                  _drawerNavItem(context, 'Testimonials'),
                  _drawerNavItem(context, 'Blogs'),
                  _drawerNavItem(context, 'About Us'),
                   const SizedBox(height: 20),

            // Login button (immediately after navigation links)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Login'),
            ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _drawerNavItem(BuildContext context, String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (onLinkTap != null) {
          onLinkTap!(title);
        }
      },
    );
  }

}
