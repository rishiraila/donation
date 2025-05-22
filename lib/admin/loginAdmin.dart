import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './dashboardAdmin.dart';

class AdminAuthScreen extends StatefulWidget {
  @override
  _AdminAuthScreenState createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  final Color redAccent = Color(0xFFE31C25);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    final url = _isLogin
        ? 'https://backend-owxp.onrender.com/api/admin/login'
        : 'https://backend-owxp.onrender.com/api/admin/register';

    final body = _isLogin
        ? {
            'mobile': _mobileController.text.trim(),
            'password': _passwordController.text.trim(),
          }
        : {
            'name': _nameController.text.trim(),
            'mobile': _mobileController.text.trim(),
            'password': _passwordController.text.trim(),
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_isLogin && data['success'] == true) {
          String adminName = data['admin']['name'] ?? 'Admin';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(adminName: adminName),
            ),
          );
        } else if (!_isLogin && data['success'] == true) {
          setState(() {
            _isLogin = true;
            _error = 'Registration successful! Please log in.';
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Something went wrong';
          });
        }
      } else {
        setState(() {
          _error = data['message'] ?? 'Something went wrong';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Server error: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: redAccent),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: redAccent),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/jaikishan.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildForm(true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.red.shade50,
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage('assets/jaikishan.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage('assets/larm.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Empowering changemakers through secure admin access. "
                    "Manage donations and impact lives with confidence.",
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
          child: Center(child: _buildForm(false)),
        ),
      ],
    );
  }

  Widget _buildForm(bool isMobile) {
    InputDecoration inputDecoration(String label, IconData? icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: redAccent) : null,
        labelStyle: TextStyle(color: Colors.black87),
        border: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      );
    }

    Widget underlineField({required Widget child}) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: child,
      );
    }

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
              color: redAccent.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? "Welcome Back, Admin!" : "Register as Admin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: redAccent,
                ),
              ),
              SizedBox(height: 20),
              if (!_isLogin)
                underlineField(
                  child: TextFormField(
                    controller: _nameController,
                    cursorColor: redAccent,
                    decoration: inputDecoration('Name', null),
                    validator: (val) => val!.isEmpty ? 'Name required' : null,
                  ),
                ),
              if (!_isLogin) SizedBox(height: 20),
              underlineField(
                child: TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  cursorColor: redAccent,
                  decoration: inputDecoration('Mobile', Icons.phone),
                  validator: (val) =>
                      val!.isEmpty ? 'Mobile number required' : null,
                ),
              ),
              SizedBox(height: 20),
              underlineField(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: redAccent,
                  decoration: inputDecoration('Password', Icons.lock),
                  validator: (val) =>
                      val!.length < 6 ? 'Min 6 characters' : null,
                ),
              ),
              SizedBox(height: 30),
              _loading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          _isLogin ? 'Login' : 'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _error = '';
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already registered? Login',
                  style: TextStyle(color: redAccent),
                ),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
