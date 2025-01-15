import 'package:flutter/material.dart';
import 'api_url.dart'; // Pastikan untuk mengimpor ApiService
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final ApiService apiService = ApiService(); // Membuat instance ApiService

  // Fungsi untuk melakukan pendaftaran user
  Future<void> register(String username, String email, String password) async {
    setState(() {
      _isLoading = true; // Menandakan bahwa pendaftaran sedang diproses
      _errorMessage = null; // Reset pesan error sebelumnya
    });

    try {
      final data = await apiService.registerUser(email, username,
          password); // Menggunakan ApiService untuk pendaftaran
      final token = data['token'];
      print('Pendaftaran berhasil: $token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SuccessPage()), // Navigasi ke halaman SuccessPage setelah berhasil daftar
      );
    } catch (e) {
      setState(() {
        _errorMessage =
            e.toString(); // Menampilkan pesan error jika pendaftaran gagal
      });
    } finally {
      setState(() {
        _isLoading = false; // Menyelesaikan proses loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(), // Background gradient
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(), // Judul Sign Up
                  _buildImage(height), // Gambar robot
                  _buildTextField(
                    icon: Icons.person,
                    controller: _usernameController,
                    hintText: 'Enter your username',
                    isPassword: false,
                  ),
                  _buildTextField(
                    icon: Icons.email,
                    controller: _emailController,
                    hintText: 'Enter your email',
                    isPassword: false,
                  ),
                  _buildTextField(
                    icon: Icons.lock,
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    isPassword: true,
                  ),
                  if (_errorMessage != null)
                    _buildErrorMessage(), // Menampilkan pesan error jika ada
                  const SizedBox(height: 20),
                  _buildSubmitButton(), // Tombol submit untuk registrasi
                  const SizedBox(height: 25),
                  _buildDivider(), // Pembatas dengan tulisan "or"
                  _buildLoginRedirect(), // Redirect ke halaman login jika sudah punya akun
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun background dengan gradient
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 22, 30, 103),
            Color.fromARGB(255, 117, 121, 152),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan judul "Sign Up"
  Widget _buildTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 25, bottom: 50),
        child: Text(
          "Sign Up",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan gambar robot
  Widget _buildImage(double height) {
    return SizedBox(
      height: height / 3.7,
      child: Image.asset('assets/images/robot.png'),
    );
  }

  // Fungsi untuk menampilkan pesan error
  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(8),
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
    );
  }

  // Fungsi untuk menampilkan tombol submit registrasi
  Widget _buildSubmitButton() {
    return _isLoading
        ? const CircularProgressIndicator(
            color: Colors.white) // Menampilkan progress indicator saat loading
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                final username = _usernameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                if (username.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty) {
                  register(username, email,
                      password); // Panggil fungsi register jika semua field terisi
                } else {
                  setState(() {
                    _errorMessage =
                        'Please fill in all fields'; // Pesan error jika ada field yang kosong
                  });
                }
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          );
  }

  // Fungsi untuk membuat divider antara "or"
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white)),
        const Text("  or  ", style: TextStyle(color: Colors.white)),
        Expanded(child: Container(height: 1, color: Colors.white)),
      ],
    );
  }

  // Fungsi untuk mengarahkan pengguna ke halaman login jika sudah punya akun
  Widget _buildLoginRedirect() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text(
              "Sign In",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.lightBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun TextField
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
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        obscureText: isPassword, // Mengatur apakah input berupa password
      ),
    );
  }
}

// Halaman sukses setelah registrasi berhasil
class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(), // Background gradient
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildImage(height), // Gambar robot
                  const SizedBox(height: 20),
                  const Text(
                    'User registered successfully!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildLoginButton(context), // Tombol login
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun background dengan gradient
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 22, 30, 103),
            Color.fromARGB(255, 117, 121, 152),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan gambar robot pada halaman SuccessPage
  Widget _buildImage(double height) {
    return SizedBox(
      height: height / 4.7,
      child: Image.asset('assets/images/robot.png'),
    );
  }

  // Fungsi untuk membuat tombol login setelah registrasi sukses
  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      ),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: const Text(
        'Sign In',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Colors.white,
        ),
      ),
    );
  }
}
