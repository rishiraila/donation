import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationForm extends StatefulWidget {
  const DonationForm({super.key});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  String? selectedPurpose;
  TextEditingController otherPurposeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isExistingDonor = false;
  bool isFetchingDonor = false;

  final ScrollController _scrollController = ScrollController();

  late Razorpay _razorpay;
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController purposeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController documentNumberController = TextEditingController();
  String? selectedDocumentType = "Aadhar";
  String? orderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    mobileController.addListener(() {
      final mobile = mobileController.text.trim();
      if (mobile.length == 10) {
        fetchDonorByMobile(mobile);
      } else {
        setState(() {
          nameController.clear();
          emailController.clear();
          isExistingDonor = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchDonorByMobile(String mobile) async {
    if (mobile.length != 10) return;

    setState(() => isFetchingDonor = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://backend-owxp.onrender.com/api/donations/getDonorByMobile?mobile=$mobile',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['exists'] == true) {
          nameController.text = data['name'];
          emailController.text = data['email'];
          isExistingDonor = true;
        } else {
          nameController.clear();
          emailController.clear();
          isExistingDonor = false;
        }
      }
    } catch (e) {
      print("Donor fetch failed: $e");
    }

    setState(() => isFetchingDonor = false);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final data = {
      "razorpay_payment_id": response.paymentId,
      "razorpay_order_id": orderId ?? "",
      "razorpay_signature": response.signature ?? "",
      "name": nameController.text.trim(),
      "mobile": mobileController.text.trim(),
      "amount": amountController.text.trim(),
      "donation_purpose": purposeController.text.trim(),
      "area": areaController.text.trim(),
      "city": cityController.text.trim(),
      "pincode": pincodeController.text.trim(),
      "document_type": selectedDocumentType,
      "document_number": documentNumberController.text.trim(),
      "address": addressController.text.trim(),
      "email": emailController.text.trim(),
    };

    final responseApi = await http.post(
      Uri.parse(
        "https://backend-owxp.onrender.com/api/donations/verify-payment",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (responseApi.statusCode == 200) {
      _showDialog(
        "Success",
        "Thank you for your donation of ₹${amountController.text}!",
      );
    } else {
      _showDialog(
        "Error",
        "Payment was successful but storing donation failed.",
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showDialog("Payment Failed", response.message ?? "Unknown error");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
  }

  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true); // Show loader
    try {
      // Create order on the server
      final response = await http.post(
        Uri.parse(
          "https://backend-owxp.onrender.com/api/donations/create-order",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "mobile": mobileController.text,
          "amount": amountController.text,
          "donation_purpose":
              selectedPurpose == "Other"
                  ? otherPurposeController.text
                  : selectedPurpose,

          "address": addressController.text,
          "area": areaController.text,
          "city": cityController.text,
          "pincode": pincodeController.text,
          "document_type": selectedDocumentType,
          "document_number": documentNumberController.text,
          "email": emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["order"]?["id"] != null) {
          orderId = data["order"]["id"];
          openCheckout();
        } else {
          _showDialog("Error", "Order ID not found.");
          setState(() => _isLoading = false); // Hide loader on error
        }
      } else {
        _showDialog("Error", "Order creation failed.");
        setState(() => _isLoading = false); // Hide loader on error
      }
    } catch (e) {
      _showDialog("Error", "Something went wrong.");
      setState(() => _isLoading = false); // Hide loader on exception
    }
  }

  void openCheckout() {
    if (orderId == null || orderId!.isEmpty) {
      _showDialog("Error", "Order ID is missing.");
      setState(() => _isLoading = false); // Hide loader
      return;
    }

    _razorpay.open({
      "key": "rzp_test_K2K20arHghyhnD",
      "amount": int.parse(amountController.text) * 100,
      "name": nameController.text,
      "description": "Donation",
      "order_id": orderId,
      "prefill": {
        "contact": mobileController.text,
        "email": emailController.text,
      },
      "external": {
        "wallets": ["paytm"],
      },
    });
    setState(() => _isLoading = false); // Hide loader
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(title, style: const TextStyle(color: Colors.black)),
            content: Text(msg, style: const TextStyle(color: Colors.black87)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  if (title == "Success") {
                    _formKey.currentState?.reset(); // Reset form state
                    nameController.clear();
                    mobileController.clear();
                    emailController.clear();
                    amountController.clear();
                    selectedPurpose = null;
                    otherPurposeController.clear();

                    addressController.clear();
                    areaController.clear();
                    cityController.clear();
                    pincodeController.clear();
                    documentNumberController.clear();
                    setState(() {
                      selectedDocumentType = "Aadhar"; 
                      isExistingDonor = false;// Reset dropdown
                    });

                    // Scroll to top
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );

                    // Show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Donation submitted successfully!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text("OK", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        cursorColor: Colors.red,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Required';

          final trimmed = value.trim();

          // Custom validations based on label
          switch (label) {
            case "Name":
              if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(trimmed))
                return 'Only letters allowed';
              break;
            case "Amount":
              if (!RegExp(r"^\d+(\.\d{1,2})?$").hasMatch(trimmed))
                return 'Enter a valid amount';
              break;
            case "Phone":
              if (!RegExp(r"^\d{10}$").hasMatch(trimmed))
                return 'Enter a 10-digit phone number';
              break;
            case "Email":
              if (!RegExp(
                r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
              ).hasMatch(trimmed))
                return 'Enter a valid email';
              break;
            case "Pincode":
              if (!RegExp(r"^\d{6}$").hasMatch(trimmed))
                return 'Enter a valid 6-digit pincode';
              break;
            case "Document Number":
              if (selectedDocumentType == "Aadhar" &&
                  !RegExp(r"^\d{12}$").hasMatch(trimmed)) {
                return 'Enter a valid 12-digit Aadhar number';
              } else if (selectedDocumentType == "PAN" &&
                  !RegExp(r"^[A-Z]{5}[0-9]{4}[A-Z]$").hasMatch(trimmed)) {
                return 'Invalid PAN format';
              } else if (selectedDocumentType == "Passport" &&
                  !RegExp(r"^[A-PR-WY][0-9]{7}$").hasMatch(trimmed)) {
                return 'Invalid Passport format';
              }
              break;
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 800;

        return Center(
          child: Container(
            width: isMobile ? double.infinity : 1200,
            margin: const EdgeInsets.symmetric(vertical: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
              ],
            ),
            child:
                isMobile
                    ? Column(
                      // ⬅️ Mobile view: stack vertically
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(),
                        const SizedBox(height: 24),
                        _buildFormSection(isMobile: true),
                      ],
                    )
                    : Row(
                      // ⬅️ Desktop view: side by side
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(),
                        const SizedBox(width: 40),
                        Expanded(child: _buildFormSection(isMobile: false)),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/jaikishan.jpg',
        height: 300,
        width: 300,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPurposeDropdown(bool isMobile) {
    final purposes = ["Food", "Clothes", "Education", "Charity", "Other"];

    return GestureDetector(
      onTap: () => _showPurposePopup(isMobile),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Purpose",
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 1),
          ),
        ),
        child: Text(
          selectedPurpose == null
              ? 'Select Purpose'
              : (selectedPurpose == "Other"
                  ? (otherPurposeController.text.isEmpty
                      ? "Other"
                      : "Other - ${otherPurposeController.text}")
                  : selectedPurpose!),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  void _showPurposePopup(bool isMobile) {
    final purposes = ["Food", "Clothes", "Education", "Charity", "Other"];
    String? tempSelected = selectedPurpose;

    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          child: AlertDialog(
            title: const Text("Select Purpose"),
            content: StatefulBuilder(
              builder: (context, setStateDialog) {
                return SizedBox(
                  width: isMobile ? double.infinity : 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...purposes.map((p) {
                        return ListTile(
                          title: Text(p),
                          leading: Radio<String>(
                            value: p,
                            groupValue: tempSelected,
                            activeColor: Colors.red,
                            onChanged: (value) {
                              setStateDialog(() {
                                tempSelected = value!;
                              });
                              if (value != "Other") {
                                Navigator.pop(context);
                                setState(() => selectedPurpose = value!);
                              }
                            },
                          ),
                          onTap: () {
                            setStateDialog(() {
                              tempSelected = p;
                            });
                            if (p != "Other") {
                              Navigator.pop(context);
                              setState(() => selectedPurpose = p);
                            }
                          },
                        );
                      }).toList(),
                      if (tempSelected == "Other")
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextFormField(
                            controller: otherPurposeController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.red,
                            decoration: const InputDecoration(
                              hintText: "Enter custom purpose",
                              hintStyle: TextStyle(fontSize: 14),
                              isDense: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  selectedPurpose = value.trim();
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType inputType = TextInputType.text,
  bool enabled = true,
  bool isLoading = false,
  bool isVerified = false,
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: inputType,
    cursorColor: Colors.red,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      suffixIcon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            )
          : isVerified
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return 'Required';

      if (label == "Email" && !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value.trim())) {
        return 'Enter a valid email';
      }
      if (label == "Name" && !RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
        return 'Only letters allowed';
      }
      if (label == "Phone" && !RegExp(r"^\d{10}$").hasMatch(value.trim())) {
        return 'Enter a valid 10-digit phone number';
      }

      return null;
    },
  );
}


  Widget _buildFormSection({required bool isMobile}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '“The meaning of life is to find your gift. The purpose of life is to give it away.”',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
      const SizedBox(height: 24),
      Form(
        key: _formKey,
        child: Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            // 1. 📱 Mobile field first
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildTextField(
                controller: mobileController,
                label: "Phone",
                inputType: TextInputType.phone,
              ),
            ),

            // 2. 👤 Name field
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildTextField(
                controller: nameController,
                label: "Name",
                enabled: !isExistingDonor,
                isLoading: isFetchingDonor,
                isVerified: isExistingDonor,
              ),
            ),

            // 3. 📧 Email field
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildTextField(
                controller: emailController,
                label: "Email",
                inputType: TextInputType.emailAddress,
                enabled: !isExistingDonor,
                isLoading: isFetchingDonor,
                isVerified: isExistingDonor,
              ),
            ),

            // 4. 💸 Amount
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildField(amountController, "Amount", inputType: TextInputType.number),
            ),

            // 5. 🎯 Purpose (2-column)
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildPurposeDropdown(isMobile),
            ),

            // 6. 📝 Other Purpose (if selected)
            if (selectedPurpose == "Other")
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: _buildField(otherPurposeController, "Other Purpose"),
              ),

            // 7. 🏠 Address fields
            _buildField(addressController, "Address"),
            _buildField(areaController, "Area"),
            _buildField(cityController, "City"),
            _buildField(pincodeController, "Pincode", inputType: TextInputType.number),

            // 8. 🪪 Document Type (2-column)
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: _buildDropdown(),
            ),

            // 9. 🔢 Document Number
            _buildField(documentNumberController, "Document Number"),
          ],
        ),
      ),
      const SizedBox(height: 24),
      _isLoading
          ? const CircularProgressIndicator(color: Colors.red)
          : ElevatedButton(
              onPressed: _isLoading ? null : createOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              ),
              child: const Text('Donate', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
    ],
  );
}

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDocumentType,
      decoration: const InputDecoration(
        labelText: "Document Type",
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      items:
          ["Aadhar", "PAN", "Passport"].map((doc) {
            return DropdownMenuItem(value: doc, child: Text(doc));
          }).toList(),
      onChanged: (value) => setState(() => selectedDocumentType = value),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
