import 'package:flutter/material.dart';

class TestimonialSection extends StatelessWidget {
  const TestimonialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Here’s what people say about",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          RichText(
            text: TextSpan(
              text: '',
              style: TextStyle(fontSize: 24, color: Colors.black),
              children: [
                TextSpan(
                  text: ' give',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              TestimonialCard(
                text:
                    "People often wonder where the money would go. I can tell you, I started working with GiveIndia when the pandemic first broke a year ago. We validate them, it's a very good, reliable organization.",
                name: "Vinod Khosla",
                subtitle: "khosla ventures",
                imageUrl: "https://i.imgur.com/jV8IlJt.png",
              ),
              TestimonialCard(
                text:
                    "GiveIndia was one of the first to understand the challenges that we as a society faced and mobilised enormous resources to support the people in need – a commendable job, thank you.",
                name: "Sanjay Gupta",
                subtitle: "Google",
                imageUrl: "https://i.imgur.com/0XJZh1u.png",
              ),
              TestimonialCard(
                text:
                    "When Nick & I decided to start our #TogetherForIndia fundraiser for the COVID-19 crisis, we wanted a partner with experience & boots on the ground. So we turned to GiveIndia.We validate them, it's a very good, reliable organization.",
                name: "Priyanka Chopra",
                subtitle: "Priyanka Chopra Jonas Foundation",
                imageUrl: "assets/andrej.jpg",
                borderColor: Color(0xFFFFEBEB),
              ),
              TestimonialCard(
                text:
                    "There is a healthcare crisis looming and we must act fast to protect our frontline workers. Doctors, nurses and paramedics' safety is crucial. We validate them, it's a very good, reliable organization.",
                name: "Dr. Devi Shetty",
                subtitle: "Narayana Health",
                imageUrl: "assets/jaikishan.jpg",
              ),
              TestimonialCard(
                text:
                    "GiveIndia's pursuit of bringing trust, convenience and choice for donors, is aligned with our goal to enable more informed and intentional generosity by everyday givers.We validate them, it's a very good, reliable organization.",
                name: "Robert Rosen ",
                subtitle: "Bill & Melinda Gates Foundation",
                imageUrl: "https://i.imgur.com/GtIqhyW.png",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String text;
  final String name;
  final String subtitle;
  final String imageUrl;
  final Color borderColor;

  const TestimonialCard({
    super.key,
    required this.text,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    this.borderColor = const Color(0xFFEFEFEF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 240, // <-- Set fixed height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87),
              maxLines: 6, // Control height
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 22,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

