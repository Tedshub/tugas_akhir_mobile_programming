import 'package:flutter/material.dart';
import 'home_page.dart';
import 'api_url.dart'; // Import untuk service API
import 'dart:convert';
import 'register_page.dart'; // Halaman register untuk navigasi

// Halaman Login
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk teks username dan password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  bool _isLoading = false; // Indikator loading
  String? _errorMessage; // Pesan error

  // Fungsi untuk proses login
  Future<void> login(String username, String password) async {
    setState(() {
      _isLoading = true; // Aktifkan indikator loading
      _errorMessage = null; // Reset pesan error
    });

    try {
      // Memanggil API login
      final responseData = await _apiService.loginUser(username, password);

      // Memeriksa apakah respons mengandung token
      if (responseData.containsKey('token')) {
        final token = responseData['token'];
        final tokenParts = token.split('.');
        if (tokenParts.length != 3) {
          throw Exception(
              'Invalid token format'); // Token harus memiliki format valid
        }

        // Decode payload dari token untuk mendapatkan userId
        final payload = json.decode(
          utf8.decode(
            base64Url.decode(base64Url.normalize(tokenParts[1])),
          ),
        );

        final userId = payload['userId'];

        // Navigasi ke halaman utama (HomePage)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userId.toString()),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Token not found in response'; // Jika token tidak ditemukan
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error during login: $e'; // Tampilkan pesan error jika ada kesalahan
      });
    } finally {
      setState(() {
        _isLoading = false; // Matikan indikator loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height =
        MediaQuery.of(context).size.height; // Mendapatkan tinggi layar
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang dengan gradien
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 22, 30, 103),
                  Color.fromARGB(255, 117, 121, 152),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header teks "Sign In"
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, left: 25, bottom: 50),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Gambar ilustrasi login
                    SizedBox(
                      height: height / 3.7,
                      child: Image.asset('assets/images/login.png'),
                    ),
                    // Input username
                    _buildTextField(
                      icon: Icons.person,
                      controller: _usernameController,
                      hintText: 'Enter your username',
                      isPassword: false,
                    ),
                    // Input password
                    _buildTextField(
                      icon: Icons.lock,
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      isPassword: true,
                    ),
                    // Tampilkan pesan error jika ada
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Indikator loading atau tombol login
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            final username = _usernameController.text.trim();
                            final password = _passwordController.text.trim();
                            if (username.isEmpty || password.isEmpty) {
                              setState(() {
                                _errorMessage = 'Please fill in all fields';
                              });
                              return;
                            }
                            login(username, password); // Proses login
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    // Separator "or"
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.white),
                        ),
                        const Text(
                          "  or  ",
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.white),
                        ),
                      ],
                    ),
                    // Tombol Google Sign-In
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 45),
                        ),
                        onPressed: () {
                          // Implementasi Google Sign-In
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.network(
                                "https://e7.pngegg.com/pngimages/337/722/png-clipart-google-search-google-account-google-s-google-play-google-company-text-thumbnail.png",
                                height: 35,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromARGB(255, 51, 51, 51),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Navigasi ke halaman Sign-Up
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      RegisterPage(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                        position: offsetAnimation,
                                        child: child);
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.lightBlue,
                              ),
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
        ],
      ),
    );
  }

  // Fungsi untuk membuat text field
  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType:
            isPassword ? TextInputType.visiblePassword : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        obscureText: isPassword,
      ),
    );
  }
}
