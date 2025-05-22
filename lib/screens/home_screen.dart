import 'package:donation_app/widgets/donation_plans.dart';
import 'package:donation_app/widgets/ngotrust.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/blog.dart';
import '../widgets/testimonial.dart';
// import '../widgets/donation.dart';
import '../widgets/login.dart';
import '../widgets/form.dart';

// import '../widgets/donation_plans.dart';
import '../widgets/testimonials.dart';
import '../widgets/footer.dart';

class HomeScreen extends StatelessWidget {
  final fundraiserKey = GlobalKey();
  final testimonialsKey = GlobalKey();
  final blogKey = GlobalKey();
  final aboutKey = GlobalKey();
  final donationFormKey = GlobalKey();

  final scrollController = ScrollController();

  HomeScreen({super.key});

  void scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: MobileNavDrawer(
        onLinkTap: (section) {
          final lower = section.toLowerCase();
          switch (lower) {
            case 'donate':
              scrollTo(donationFormKey);
              break;
            case 'fundraiser':
              scrollTo(fundraiserKey);
              break;
            case 'testimonials':
              scrollTo(testimonialsKey);
              break;
            case 'blogs':
              scrollTo(blogKey);
              break;
            case 'about us':
              scrollTo(aboutKey);
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Navbar(
              onLinkTap: (section) {
                final lower = section.toLowerCase();
                switch (lower) {
                  case 'donate':
                    scrollTo(donationFormKey);
                    break;
                  case 'fundraiser':
                    scrollTo(fundraiserKey);
                    break;
                  case 'testimonials':
                    scrollTo(testimonialsKey);
                    break;
                  case 'blogs':
                    scrollTo(blogKey);
                    break;
                  case 'about us':
                    scrollTo(aboutKey);
                    break;
                }
              },
            ),
            HeroCarousel(onDonateTap: () => scrollTo(donationFormKey)),

            //             // HeroCarousel(),
            Container(
              key: fundraiserKey,
              child: FundraiserCardList(
                onDonateTap: () => scrollTo(donationFormKey),
              ),
            ),
            RaiseFundsSection(),
            Container(key: donationFormKey, child: DonationForm()),

            // DonationForm(),
            // Container(key: donationFormKey, child: FormImageSection()),
            // const DonationForm(),
            Container(key: testimonialsKey, child: TestimonialSection()),
            Container(key: blogKey, child: BlogSection()),
            Container(key: aboutKey, child: Footer()),
          ],
        ),
      ),
    );
  }
}
