import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Adaptive horizontal padding
    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 60.0
            : 150.0;

    return Container(
      color: const Color(0xFFFFEBEB), // Light red background
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('About Us', [
                    'About Give',
                    'Blog',
                    'Careers',
                    'Contact us',
                  ], true),
                  _buildSection('Fundraiser Support', [
                    'FAQs',
                    'Reach out',
                  ], true),
                  _buildSection('Start a Fundraiser for', ['NGO'], true),
                  _buildSection('Donate to', ['Social Causes', 'NGOs'], true),
                  const Spacer(),
                  _buildCurrencyAndSocial(isWide: true),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 30,
                    runSpacing: 20,
                    children: [
                      _buildSection('About Us', [
                        'About Give',
                        'Blog',
                        'Careers',
                        'Contact us',
                      ], false),
                      _buildSection('Fundraiser Support', [
                        'FAQs',
                        'Reach out',
                      ], false),
                      _buildSection('Start a Fundraiser for', ['NGO'], false),
                      _buildSection('Donate to', ['Social Causes', 'NGOs'], false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildCurrencyAndSocial(isWide: false),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, bool isWide) {
    final sectionContent = Padding(
      padding: const EdgeInsets.only(right: 32.0, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFFD32F2F), // Deep red for headings
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return isWide
        ? Expanded(child: sectionContent)
        : SizedBox(width: 160, child: sectionContent); // For tablet/mobile wrap
  }

  Widget _buildCurrencyAndSocial({required bool isWide}) {
    return Padding(
      padding: isWide ? EdgeInsets.zero : const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const Text(
            'Follow us on',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            children: const [
              Icon(
                FontAwesomeIcons.facebookF,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
              Icon(
                FontAwesomeIcons.twitter,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
              Icon(
                FontAwesomeIcons.instagram,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
              Icon(
                FontAwesomeIcons.linkedinIn,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
              Icon(
                FontAwesomeIcons.youtube,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
