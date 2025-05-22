import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashbod.dart'; // User dashboard
import '../admin/dashboardAdmin.dart'; // Admin dashboard

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum LoginType { user, admin }

class _LoginPageState extends State<LoginPage> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;
  String _error = '';
  LoginType _loginType = LoginType.user;

  Future<void> login() async {
    String mobile = mobileController.text.trim();
    String password = passwordController.text.trim();

    if (mobile.isEmpty) {
      showSnackbar("Please enter your mobile number");
      return;
    }

    if (_loginType == LoginType.admin && password.isEmpty) {
      showSnackbar("Please enter your password");
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final uri =
          _loginType == LoginType.user
              ? Uri.parse("https://backend-owxp.onrender.com/api/auth/login")
              : Uri.parse("https://backend-owxp.onrender.com/api/admin/login");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          _loginType == LoginType.user
              ? {"mobile": mobile}
              : {"mobile": mobile, "password": password},
        ),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (_loginType == LoginType.user && responseData.containsKey("donor")) {
          navigateToUserDashboard(
            responseData["donor"],
            responseData["donationHistory"] ?? [],
          );
        } else if (_loginType == LoginType.admin &&
            responseData.containsKey("admin")) {
          navigateToDashboard(responseData["admin"], []);
        } else {
          showSnackbar(responseData["message"] ?? "Login failed");
        }
      } else {
        showSnackbar(responseData["message"] ?? "Login failed");
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void navigateToUserDashboard(
    Map<String, dynamic> userData,
    List<dynamic> donationHistory,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => DashboardPage1(
              donorData: userData,
              donationHistory: donationHistory,
            ),
      ),
    );
  }

  void navigateToDashboard(
    Map<String, dynamic> userData,
    List<dynamic> donationHistory,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => AdminDashboard(adminName: userData['name'] ?? 'Admin'),
      ),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return _buildMobileLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  BoxDecoration _imageBox(String path) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2)),
      ],
      image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/jaikishan.jpg',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          _buildLoginForm(context, true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 500,
                  height: 360,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 40,
                        top: 20,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: Container(
                            width: 260,
                            height: 180,
                            decoration: _imageBox('assets/jaikishan.jpg'),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 160,
                        top: 120,
                        child: Transform.rotate(
                          angle: 0.05,
                          child: Container(
                            width: 260,
                            height: 180,
                            decoration: _imageBox('assets/larm.jpg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Every child deserves access to quality education and a brighter future. "
                    "Your support helps us bring hope, technology, and opportunity to underserved communities.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(child: _buildLoginForm(context, false)),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isMobile) {
    final redAccent = Color(0xFFE31C25);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Container(
        width: isMobile ? double.infinity : 400,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade500,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade500,
              ),
            ),
            SizedBox(height: 10),

            // Radio Buttons for login type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<LoginType>(
                      value: LoginType.user,
                      groupValue: _loginType,
                      activeColor: redAccent,
                      onChanged: (value) {
                        setState(() {
                          _loginType = value!;
                        });
                      },
                    ),
                    Text("User", style: TextStyle(color: redAccent)),
                  ],
                ),
                SizedBox(width: 30),
                Row(
                  children: [
                    Radio<LoginType>(
                      value: LoginType.admin,
                      groupValue: _loginType,
                      activeColor: redAccent,
                      onChanged: (value) {
                        setState(() {
                          _loginType = value!;
                        });
                      },
                    ),
                    Text("Admin", style: TextStyle(color: redAccent)),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10),
            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              cursorColor: redAccent,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                labelStyle: TextStyle(color: Colors.black54),
                prefixIcon: Icon(Icons.phone, color: redAccent),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: redAccent, width: 2),
                ),
              ),
            ),
            if (_loginType == LoginType.admin) ...[
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                cursorColor: redAccent,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.lock, color: redAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: redAccent, width: 2),
                  ),
                ),
              ),
            ],
            if (_error.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: redAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _loading
                        ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
