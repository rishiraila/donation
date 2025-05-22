import 'dart:async';
import 'package:flutter/material.dart';

class NGOPartnersCarousel extends StatefulWidget {
  const NGOPartnersCarousel({super.key});

  @override
  State<NGOPartnersCarousel> createState() => _NGOPartnersCarouselState();
}

class _NGOPartnersCarouselState extends State<NGOPartnersCarousel> {
  final List<Map<String, String>> partners = [
    {'name': 'Blind Welfare Society', 'logo': 'assets/ngos/blind_welfare.png'},
    {'name': 'Bhartiye Netraheen Parishad', 'logo': 'assets/ngos/bhartiye_netraheen.png'},
    {'name': 'Palawi', 'logo': 'assets/ngos/palawi.png'},
    {'name': 'Jeevan Aanand Foundation', 'logo': 'assets/ngos/jeevan_aanand.png'},
    {'name': 'Saint Hardyal Educational Trust', 'logo': 'assets/ngos/saint_hardyal.png'},
    {'name': 'NeevJivan Foundation', 'logo': 'assets/ngos/neevjivan.png'},
    {'name': 'Helping Hands Trust', 'logo': 'assets/ngos/helping_hands.png'},
    {'name': 'Seva Sahayog Foundation', 'logo': 'assets/ngos/seva_sahayog.png'},
    {'name': 'Udaan India Foundation', 'logo': 'assets/ngos/udaan.png'},
    {'name': 'Hope For All', 'logo': 'assets/ngos/hope_for_all.png'},
    {'name': 'Navchetna Trust', 'logo': 'assets/ngos/navchetna.png'},
    {'name': 'Asha Kiran Foundation', 'logo': 'assets/ngos/asha_kiran.png'},
  ];

  late final PageController _pageController;
  late Timer _autoScrollTimer;

  List<List<Map<String, String>>> itemChunks = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Split items into chunks of 2
    for (int i = 0; i < partners.length; i += 2) {
      itemChunks.add(partners.sublist(i, i + 2 > partners.length ? partners.length : i + 2));
    }

    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= (itemChunks.length / 2).ceil()) {
          nextPage = 0; // Loop back
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (itemChunks.length / 2).ceil();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Text(
                'Our trusted NGO partners',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We have been raising funds for credible nonprofits for 20+ years',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 2;
              final visibleChunks = itemChunks.sublist(
                start,
                (start + 2 > itemChunks.length) ? itemChunks.length : start + 2,
              );
              final visibleItems = visibleChunks.expand((e) => e).toList();

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: visibleItems.map((partner) {
                  return Flexible(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                partner['logo']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            partner['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalPages,
            (index) => Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.black87 : Colors.black26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
