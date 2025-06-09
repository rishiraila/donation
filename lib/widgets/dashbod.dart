import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:my_donation_app/main.dart';
import 'package:donation_app/widgets/donation.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../screens/home_screen.dart';
// import 'package:my_donation_app/donation_form.dart';
// import 'package:my_donation_app/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false);
  }
}

class DashboardPage1 extends StatefulWidget {
  final dynamic donorData;
  final List<dynamic> donationHistory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DashboardPage1({required this.donorData, required this.donationHistory});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage1> {
  String selectedPage = "Dashboard";
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? donationSummary;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controllers for form fields
  late TextEditingController mobileController;
  late TextEditingController nameController;
  late TextEditingController purposeController;
  late TextEditingController addressController;
  late TextEditingController areaController;
  late TextEditingController pincodeController;
  late TextEditingController emailController;
  late TextEditingController cityController;
  late TextEditingController documentNumberController;
  String documentType = "Aadhar"; // Default selection

  void signOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ), // ✅ Replace with your main login page
      (route) => false, // ✅ Remove all previous routes
    );
  }

  void updateDonorDetails() async {
    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/update-donor",
    ); // Replace with your backend URL

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobile": mobileController.text,
        "name": nameController.text,
        "address": addressController.text,
        "area": areaController.text,
        "city": cityController.text,
        "pincode": pincodeController.text,
        "email": emailController.text,
        "document_type": documentType,
        "document_number": documentNumberController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["message"])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update donor details: ${response.body}"),
        ),
      );
    }
  }

  void updateTaxDetails() async {
    final documentNumber = documentNumberController.text.trim();

    // PAN Validation
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    // Aadhar Validation
    final aadharRegex = RegExp(r'^\d{12}$');

    if (documentType == "PAN") {
      if (!panRegex.hasMatch(documentNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid PAN number. Format: ABCDE1234F")),
        );
        return;
      }
    } else if (documentType == "Aadhar") {
      if (!aadharRegex.hasMatch(documentNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid Aadhar number. Must be 12 digits")),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a valid document type")),
      );
      return;
    }

    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/update-donor",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "document_type": documentType,
        "document_number": documentNumber,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["message"])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update tax details: ${response.body}"),
        ),
      );
    }
  }

  void downloadInvoice(String donationId) async {
    final url =
        'https://backend-owxp.onrender.com/api/donations/invoice?donationId=$donationId';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: downloadUrl)
              ..setAttribute("download", "invoice_$donationId.pdf")
              ..click();
        html.Url.revokeObjectUrl(downloadUrl);
      } else {
        print("This function is only for Flutter Web.");
      }
    } else {
      print("Failed to download invoice: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDonationHistory();

    // Initialize controllers with data from `donorData`
    mobileController = TextEditingController(
      text: widget.donorData["mobile"] ?? "",
    );
    nameController = TextEditingController(
      text: widget.donorData["name"] ?? "",
    );
    purposeController = TextEditingController(
      text: widget.donorData["donation_purpose"] ?? "",
    );
    addressController = TextEditingController(
      text: widget.donorData["address"] ?? "",
    );
    areaController = TextEditingController(
      text: widget.donorData["area"] ?? "",
    );
    pincodeController = TextEditingController(
      text: widget.donorData["pincode"] ?? "",
    );
    emailController = TextEditingController(
      text: widget.donorData["email"] ?? "",
    );
    cityController = TextEditingController(
      text: widget.donorData["city"] ?? "",
    );
    documentNumberController = TextEditingController(
      text: widget.donorData["document_number"] ?? "",
    );
    documentType =
        widget.donorData["document_type"] ?? "Aadhar"; // Default value
  }

  List<dynamic> donationHistory = []; // ✅ Use a state variable

  void fetchDonationHistory() async {
    final url = Uri.parse(
      "https://backend-owxp.onrender.com/api/donations/history?mobile=${widget.donorData["mobile"]}",
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final history = data["donationHistory"];

      if (history != null && history.isNotEmpty) {
        final successfulDonations =
            history.where((item) {
              return item["status"] != null &&
                  item["status"].toString().toLowerCase() == "success";
            }).toList();

        if (successfulDonations.isNotEmpty) {
          // Sort donations by created_at descending (latest first)
          successfulDonations.sort((a, b) {
            DateTime dateA =
                DateTime.tryParse(a["created_at"] ?? "") ?? DateTime(1970);
            DateTime dateB =
                DateTime.tryParse(b["created_at"] ?? "") ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

          // Calculate total amount donated
          double totalAmount = 0.0;
          for (var item in successfulDonations) {
            totalAmount +=
                double.tryParse(item["amount"]?.toString() ?? "0") ?? 0.0;
          }

          // Get latest donation info
          final latestDonation = successfulDonations.first;

          // Debug print to check keys and values
          print("Latest donation: $latestDonation");

          // Extract date from created_at and format it
          String lastDonationDateRaw = latestDonation["created_at"] ?? "N/A";
          String lastDonationDate = "N/A";
          if (lastDonationDateRaw != "N/A") {
            try {
              DateTime parsedDate = DateTime.parse(lastDonationDateRaw);
              lastDonationDate =
                  "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
            } catch (e) {
              lastDonationDate = lastDonationDateRaw; // fallback raw string
            }
          }

          // Get top cause from donation_purpose key
          String topCause = latestDonation["donation_purpose"] ?? "N/A";

          // Get donor name (fallback to "Donor")
          String name = latestDonation["name"] ?? "Donor";

          setState(() {
            donationHistory = successfulDonations;
            donationSummary = {
              "name": name,
              "totalAmount": totalAmount,
              "totalDonations": successfulDonations.length,
              "lastDonationDate": lastDonationDate,
              "topCause": topCause,
            };
          });
        } else {
          setState(() {
            donationHistory = [];
            donationSummary = {
              "name": "Donor",
              "totalAmount": 0.0,
              "totalDonations": 0,
              "lastDonationDate": "N/A",
              "topCause": "N/A",
            };
          });
        }
      } else {
        // No donation history at all
        setState(() {
          donationHistory = [];
          donationSummary = {
            "name": "Donor",
            "totalAmount": 0.0,
            "totalDonations": 0,
            "lastDonationDate": "N/A",
            "topCause": "N/A",
          };
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch donation history")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer:
          isLargeScreen
              ? null
              : SideBarMenu(
                selectedPage: selectedPage,
                onSelect: (page) {
                  setState(() {
                    selectedPage = page;
                  });
                },
                mobile: widget.donorData["mobile"] ?? "Unknown",
                signOut: signOut,
              ),
      body: Row(
        children: [
          if (isLargeScreen)
            SideBarMenu(
              selectedPage: selectedPage,
              onSelect: (page) {
                setState(() {
                  selectedPage = page;
                });
              },
              mobile: widget.donorData["mobile"] ?? "Unknown",
              signOut: signOut,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // Custom AppBar
                // Container(
                //   color: Colors.white,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 12,
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         selectedPage,
                //         style: const TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black87,
                //         ),
                //       ),
                //       if (!isLargeScreen)
                //         IconButton(
                //           icon: const Icon(Icons.menu, color: Colors.black),
                //           onPressed:
                //               () => _scaffoldKey.currentState?.openDrawer(),
                //         ),
                //     ],
                //   ),
                // ),

                // Main content
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPage,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            if (selectedPage == "Dashboard") ...[
                              donationSummary == null
                                  ? Center(child: CircularProgressIndicator())
                                  : Builder(
                                    builder: (context) {
                                      final summary = donationSummary!;

                                      return LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isMobile =
                                              constraints.maxWidth < 600;

                                          return SingleChildScrollView(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isMobile ? 8.0 : 16.0,
                                              vertical: 16.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Welcome, ${summary["name"]} 👋',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Thank you for being part of our mission. Your generosity matters!',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 24),

                                                /// 👇 Responsive Layout: Wrap on Desktop, Grid on Mobile
                                                isMobile
                                                    ? GridView.count(
                                                      crossAxisCount: 2,
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      mainAxisSpacing: 10,
                                                      crossAxisSpacing: 10,
                                                      children: [
                                                        buildStatCard(
                                                          "Total Donated",
                                                          "₹${summary["totalAmount"]}",
                                                          Icons
                                                              .volunteer_activism,
                                                        ),
                                                        buildStatCard(
                                                          "Total Donations",
                                                          "${summary["totalDonations"]}",
                                                          Icons.receipt_long,
                                                        ),
                                                        buildStatCard(
                                                          "Last Donation",
                                                          "${summary["lastDonationDate"]}",
                                                          Icons.event,
                                                        ),
                                                        buildStatCard(
                                                          "Top Cause",
                                                          "${summary["topCause"]}",
                                                          Icons.favorite,
                                                        ),
                                                      ],
                                                    )
                                                    : Wrap(
                                                      spacing: 10,
                                                      runSpacing: 10,
                                                      children: [
                                                        buildStatCard(
                                                          "Total Donated",
                                                          "₹${summary["totalAmount"]}",
                                                          Icons
                                                              .volunteer_activism,
                                                        ),
                                                        buildStatCard(
                                                          "Total Donations",
                                                          "${summary["totalDonations"]}",
                                                          Icons.receipt_long,
                                                        ),
                                                        buildStatCard(
                                                          "Last Donation",
                                                          "${summary["lastDonationDate"]}",
                                                          Icons.event,
                                                        ),
                                                        buildStatCard(
                                                          "Top Cause",
                                                          "${summary["topCause"]}",
                                                          Icons.favorite,
                                                        ),
                                                      ],
                                                    ),

                                                SizedBox(height: 32),
                                                Text(
                                                  'Every contribution makes a difference.',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Text(
                                                  'Your generous donations have empowered children, uplifted families, and helped us reach remote communities with critical support. '
                                                  'With your help, we provide food, education, and healthcare to those who need it most. Together, we are not just donating — '
                                                  'we are building a movement of compassion, dignity, and hope.',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                    height: 1.6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                            ],

                            if (selectedPage == "Update Profile") ...[
                              SizedBox(height: 10),
                              Text(
                                "To avail benefits of 80G, updating PAN and AADHAR is mandatory.",
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  bool isMobile = constraints.maxWidth < 600;

                                  return Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        isMobile
                                            ? Column(
                                              children: [
                                                buildStyledTextField(
                                                  "Mobile No*",
                                                  mobileController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty)
                                                      return 'Required';
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                buildStyledTextField(
                                                  "Name*",
                                                  nameController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty)
                                                      return 'Required';
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Mobile No*",
                                                    mobileController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty)
                                                        return 'Required';
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Name*",
                                                    nameController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty)
                                                        return 'Required';
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                        SizedBox(height: 10),
                                        isMobile
                                            ? Column(
                                              children: [
                                                buildStyledTextField(
                                                  "Purpose",
                                                  purposeController,
                                                ),
                                                SizedBox(height: 10),
                                                buildStyledTextField(
                                                  "Address",
                                                  addressController,
                                                ),
                                              ],
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Purpose",
                                                    purposeController,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Address",
                                                    addressController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        SizedBox(height: 10),
                                        isMobile
                                            ? Column(
                                              children: [
                                                buildStyledTextField(
                                                  "Area",
                                                  areaController,
                                                ),
                                                SizedBox(height: 10),
                                                buildStyledTextField(
                                                  "Pincode",
                                                  pincodeController,
                                                ),
                                              ],
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Area",
                                                    areaController,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Pincode",
                                                    pincodeController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        SizedBox(height: 10),
                                        isMobile
                                            ? Column(
                                              children: [
                                                buildStyledTextField(
                                                  "Email",
                                                  emailController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty)
                                                      return 'Required';
                                                    if (!RegExp(
                                                      r'\S+@\S+\.\S+',
                                                    ).hasMatch(value)) {
                                                      return 'Enter valid email';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                buildStyledTextField(
                                                  "City",
                                                  cityController,
                                                ),
                                              ],
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Email",
                                                    emailController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty)
                                                        return 'Required';
                                                      if (!RegExp(
                                                        r'\S+@\S+\.\S+',
                                                      ).hasMatch(value)) {
                                                        return 'Enter valid email';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "City",
                                                    cityController,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        SizedBox(height: 10),
                                        isMobile
                                            ? Column(
                                              children: [
                                                buildDropdownField(
                                                  "Document Type",
                                                  ["Aadhar", "PAN"],
                                                  documentType,
                                                  (newValue) {
                                                    setState(() {
                                                      documentType = newValue!;
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                buildStyledTextField(
                                                  "Document Number",
                                                  documentNumberController,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty)
                                                      return 'Required';
                                                    if (documentType == "PAN") {
                                                      final panRegex = RegExp(
                                                        r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                                                      );
                                                      if (!panRegex.hasMatch(
                                                        value.toUpperCase(),
                                                      )) {
                                                        return 'Enter valid PAN (e.g. ABCDE1234F)';
                                                      }
                                                    } else if (documentType ==
                                                        "Aadhar") {
                                                      final aadhaarRegex =
                                                          RegExp(r'^\d{12}$');
                                                      if (!aadhaarRegex
                                                          .hasMatch(value)) {
                                                        return 'Enter valid 12-digit Aadhar number';
                                                      }
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: buildDropdownField(
                                                    "Document Type",
                                                    ["Aadhar", "PAN"],
                                                    documentType,
                                                    (newValue) {
                                                      setState(() {
                                                        documentType =
                                                            newValue!;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: buildStyledTextField(
                                                    "Document Number",
                                                    documentNumberController,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty)
                                                        return 'Required';
                                                      if (documentType ==
                                                          "PAN") {
                                                        final panRegex = RegExp(
                                                          r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                                                        );
                                                        if (!panRegex.hasMatch(
                                                          value.toUpperCase(),
                                                        )) {
                                                          return 'Enter valid PAN (e.g. ABCDE1234F)';
                                                        }
                                                      } else if (documentType ==
                                                          "Aadhar") {
                                                        final aadhaarRegex =
                                                            RegExp(r'^\d{12}$');
                                                        if (!aadhaarRegex
                                                            .hasMatch(value)) {
                                                          return 'Enter valid 12-digit Aadhar number';
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                        SizedBox(height: 20),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                updateDonorDetails();
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Please fill required fields correctly",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 50,
                                                vertical: 15,
                                              ),
                                            ),
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],

                            if (selectedPage == "Tax Detail Update") ...[
                              SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    bool isMobile = constraints.maxWidth < 600;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isMobile)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left Column - Info
                                              Expanded(
                                                flex: 1,
                                                child: taxInfoSection(),
                                              ),
                                              SizedBox(width: 50),
                                              // Right Column - Form
                                              Expanded(
                                                flex: 1,
                                                child: taxFormSection(),
                                              ),
                                            ],
                                          ),
                                        if (isMobile)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              taxInfoSection(),
                                              SizedBox(height: 30),
                                              taxFormSection(),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],

                            if (selectedPage == "Donation history") ...[
                              SizedBox(height: 10),
                              SizedBox(height: 20),
                              widget.donationHistory.isEmpty
                                  ? Center(
                                    child: Text(
                                      "No donation history available.",
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minWidth: 1200,
                                      ), // Allow horizontal scroll
                                      child: DataTable(
                                        columnSpacing: 6.0, // Reduced spacing
                                        dataRowHeight: 60.0,
                                        headingRowColor:
                                            WidgetStateProperty.resolveWith(
                                              (states) => Colors.grey.shade300,
                                            ),
                                        columns: [
                                          DataColumn(
                                            label: Text(
                                              "Date",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Name",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Purpose",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Amount",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Mode",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Reference ID",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Donation ID",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Payment Status",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Invoice",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                        rows:
                                            widget.donationHistory.map<
                                              DataRow
                                            >((donation) {
                                              String formattedDate = '';
                                              if (donation["created_at"] !=
                                                  null) {
                                                DateTime dateTime =
                                                    DateTime.parse(
                                                      donation["created_at"],
                                                    );
                                                formattedDate = DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(dateTime);
                                              }

                                              bool isSuccess =
                                                  (donation["status"]
                                                          ?.toLowerCase() ==
                                                      "success");

                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(
                                                      formattedDate,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["name"] ?? "-",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["donation_purpose"] ??
                                                          "-",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      "₹${donation["amount"] ?? "0"}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["payment_mode"] ??
                                                          "Razorpay",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["razorpay_payment_id"] ??
                                                          "-",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["razorpay_order_id"] ??
                                                          "-",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      donation["status"] ?? "-",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    isSuccess
                                                        ? ElevatedButton.icon(
                                                          onPressed: () {
                                                            if (donation["id"] !=
                                                                null) {
                                                              downloadInvoice(
                                                                donation["id"]
                                                                    .toString(),
                                                              );
                                                            } else {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    "Invalid donation ID. Cannot download invoice.",
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.download,
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "Download",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 10,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        : Text(
                                                          "-",
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget taxInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tax Detail Update",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Why we need your Tax Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        SizedBox(height: 10),
        Text(
          "To issue 80G tax benefit certificates, we require your PAN or AADHAR. Your data is securely handled and will never be shared.",
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 20),
        Icon(Icons.verified, color: Colors.green, size: 32),
      ],
    );
  }

  Widget taxFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please provide your tax details.",
          style: TextStyle(color: Colors.red),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 400,
          child: buildDropdownField(
            "Document Type",
            ["Aadhar", "PAN"],
            documentType,
            (newValue) {
              setState(() {
                documentType = newValue!;
              });
            },
          ),
        ),
        SizedBox(height: 15),
        SizedBox(
          width: 400,
          child: buildStyledTextField(
            "Document Number",
            documentNumberController,
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: updateTaxDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              "Save",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStyledTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: Colors.red,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF7F2FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.redAccent, size: 30),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    Color? bgColor,
  }) {
    return SizedBox(
      width: 350, // Increased width as you want
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.redAccent, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // White background
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      dropdownColor: Colors.white, // Dropdown list background color
      items:
          items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
    );
  }
}

class SideBarMenu extends StatelessWidget {
  final Function(String) onSelect;
  final String selectedPage;
  final String mobile;
  final VoidCallback signOut;

  SideBarMenu({
    required this.onSelect,
    required this.selectedPage,
    required this.mobile,
    required this.signOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Keep text left-aligned
              children: [
                Text(
                  "Welcome $mobile",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10), // Spacing between text and image
                Center(
                  // Center the image inside the drawer
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      50,
                    ), // Optional: Circular Image
                    child: Image.asset(
                      '../../assets/assets/andrej.jpg',
                      width: 80, // Set width
                      height: 80, // Set height
                      fit: BoxFit.cover, // Ensure proper fit
                    ),
                  ),
                ),
              ],
            ),
          ),

          buildDrawerButton("Dashboard"),
          buildDrawerButton("Update Profile"),
          buildDrawerButton("Tax Detail Update"),
          buildDrawerButton("Donation history"),
          buildDrawerButton("Sign Out"),
        ],
      ),
    );
  }

  Widget buildDrawerButton(String title) {
    bool isActive = selectedPage == title;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child:
          isActive
              ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (title == "Sign Out") {
                    signOut();
                  } else {
                    onSelect(title);
                  }
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
              : TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (title == "Sign Out") {
                    signOut();
                  } else {
                    onSelect(title);
                  }
                },
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
    );
  }
}
