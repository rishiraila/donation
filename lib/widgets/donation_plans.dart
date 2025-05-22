import 'package:flutter/material.dart';

const List<Map<String, dynamic>> fundraisers = [
  {
    'image': 'assets/national.jpg',
    'title': 'Help abandoned grandparents fight hunger and also receive...',
    'org': 'by Share and Care Children’s Welfare Society',
    'donations': '19944',
    'daysLeft': '2',
    'raised': '₹2,40,09,553',
    'goal': '₹3,00,00,000',
    'progress': 0.8,
  },
  {
    'image': 'assets/larm.jpg',
    'title':
        'Your donation can help 40 blind girls get food, shelter and care...',
    'org': 'by Blind Welfare Society',
    'donations': '6324',
    'daysLeft': '2',
    'raised': '₹1,20,00,000',
    'goal': '₹1,80,00,000',
    'progress': 0.67,
  },
  {
    'image': 'assets/jaikishan.jpg',
    'title': 'Help provide shelter, food, clothes and medical support to...',
    'org': 'by Maitri',
    'donations': '21956',
    'daysLeft': '3',
    'raised': '₹2,41,11,580',
    'goal': '₹4,00,00,000',
    'progress': 0.6,
  },
];

class FundraiserCardList extends StatelessWidget {
  final VoidCallback onDonateTap;

  const FundraiserCardList({super.key, required this.onDonateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support a fundraiser',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pick a cause close to your heart and donate now',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 20,
              children:
                  fundraisers.map((fundraiser) {
                    return SizedBox(
                      width: 380,
                      child: FundraiserCard(
                        fundraiser: fundraiser,
                        onDonateTap: onDonateTap,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class FundraiserCard extends StatefulWidget {
  final Map<String, dynamic> fundraiser;
  final VoidCallback onDonateTap;

  const FundraiserCard({
    super.key,
    required this.fundraiser,
    required this.onDonateTap,
  });

  @override
  State<FundraiserCard> createState() => _FundraiserCardState();
}

class _FundraiserCardState extends State<FundraiserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: isHovered ? 12 : 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedScale(
          scale: isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        widget.fundraiser['image'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE082),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Tax Benefits Available',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fundraiser['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fundraiser['org'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 14,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.fundraiser['donations']} Donations',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.fundraiser['daysLeft']} Days Left',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: widget.fundraiser['progress'],
                        backgroundColor: Colors.grey[300],
                        color: Colors.orange,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.fundraiser['raised']} raised of ${widget.fundraiser['goal']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onDonateTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Donate Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
