import 'package:flutter/material.dart';

class RaiseFundsSection extends StatelessWidget {
  const RaiseFundsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF1EE),
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(maxWidth: 1000),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftColumn(isMobile),
                    const SizedBox(height: 24),
                    _buildRightImages(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: _buildLeftColumn(isMobile)),
                    const SizedBox(width: 32),
                    Expanded(flex: 5, child: _buildRightImages(isMobile)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raise funds for your cause!',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Onboard on Give.do and create impact by raising funds for your initiatives',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(
                  fontSize: isMobile ? 13.5 : 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
              child: const Text('Enroll your NGO on give'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(
                  fontSize: isMobile ? 13.5 : 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                side: const BorderSide(color: Colors.black87),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
              child: const Text('Raise funds for a listed NGO'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightImages(bool isMobile) {
    return SizedBox(
      height: isMobile ? 220 : 280,
      child: Stack(
        children: [
          Positioned(
            left: isMobile ? 20 : 40,
            top: isMobile ? 20 : 30,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/andrej.jpg',
                  width: isMobile ? 160 : 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: isMobile ? 20 : 20,
            bottom: isMobile ? 20 : 20,
            child: Transform.rotate(
              angle: 0.03,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/jaikishan.jpg',
                  width: isMobile ? 140 : 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
