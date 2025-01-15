import 'package:flutter/material.dart';
import 'login_page.dart';
import 'edit_profile_picture.dart';
import 'product.dart';
import 'home_page.dart';
import 'api_url.dart'; // Mengimpor ApiService

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {}; // Menyimpan data user
  bool isLoading = true; // Status loading data user

  // Variabel untuk mengatur jarak padding
  final double verticalPadding = 20.0;

  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  // Fungsi ini dipanggil saat widget pertama kali diinisialisasi untuk mendapatkan data profil pengguna
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Fungsi untuk mengambil data profil pengguna dari API
  Future<void> fetchUserProfile() async {
    try {
      final data = await _apiService.fetchProfile(widget.userId);
      if (mounted) {
        setState(() {
          userData = data;
          isLoading =
              false; // Mengubah status loading setelah data berhasil didapatkan
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // Mengubah status loading jika terjadi error
        });
      }
    }
  }

  // Fungsi untuk membangun tampilan halaman profil
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dengan gradien
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
          // Menampilkan loading spinner jika data belum diambil
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    children: [
                      // Tombol kembali untuk navigasi ke halaman sebelumnya (HomePage)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      HomePage(userId: widget.userId),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin =
                                        Offset(-1.0, 0.0); // Bergeser ke kiri
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      // Header 'Profile'
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, top: 20.0, bottom: 50),
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Foto Profil dengan ikon edit di sudut kanan bawah
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: userData['profile'] != null
                                        ? NetworkImage(userData['profile']
                                                .startsWith('http')
                                            ? userData['profile']
                                            : '${_apiService.baseUrl}/${userData['profile']}')
                                        : null,
                                    child: userData['profile'] == null
                                        ? Icon(Icons.person,
                                            size: 60, color: Colors.grey[600])
                                        : null,
                                  ),
                                  // Ikon edit untuk mengubah foto profil
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfilePicture(
                                                  userId: widget.userId),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 23,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Menampilkan username pengguna
                              Text(
                                userData['username'] ?? 'Username',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Menampilkan email pengguna
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    userData['email'] ?? 'Email',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Tombol untuk logout
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Log out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: verticalPadding),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Navigation Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavItem(Icons.home, 'Home', false), // Home
                              _buildNavItem(
                                  Icons.add_circle_outline, 'Product', false),
                              _buildNavItem(Icons.person, 'Profile', true),
                            ],
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

  // Widget untuk membangun item navigasi bottom bar
  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _navigateToPage(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 30,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk navigasi ke halaman yang dipilih pada bottom bar
  void _navigateToPage(String page) {
    Widget targetPage;

    switch (page) {
      case 'Product':
        targetPage = AddProduct(userId: widget.userId);
        break;
      case 'Home':
        targetPage = HomePage(userId: widget.userId);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // Bergeser ke kiri
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
