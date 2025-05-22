import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Placeholder pages — create these as separate Dart files or temporary stubs
import 'widgets/donation_plans.dart';
import 'widgets/blog.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/footer.dart';
import 'widgets/ngotrust.dart';
import 'widgets/testimonial.dart';
import 'widgets/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Give.do ',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        // '/donate': (context) => const DonatePage(),
        '/fundraiser':
            (context) => FundraiserCardList(
              onDonateTap: () {
                // This could be a placeholder or show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Donation form not available on this page.'),
                  ),
                );
              },
            ),
        '/testimonials': (context) => const TestimonialSection(),
        '/blogs': (context) => const BlogSection(),
        '/login': (context) => LoginPage(),
        // '/about': (context) => const AboutPage(),
        // '/login': (context) => const LoginPage(),
      },
    );
  }
}
