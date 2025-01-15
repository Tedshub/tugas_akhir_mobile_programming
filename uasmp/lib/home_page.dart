import 'package:flutter/material.dart';
import 'api_url.dart';
import 'profile_page.dart';
import 'product.dart';
import 'message.dart';
import 'detail.dart';

/// Widget utama untuk halaman Home
class HomePage extends StatefulWidget {
  final String userId; // ID pengguna yang diteruskan ke halaman

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/// State untuk HomePage
class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService(); // Instance API untuk mengakses data
  Map<String, dynamic> userData = {}; // Data profil pengguna
  List<dynamic> productList = []; // Data produk
  bool isLoading = true; // Indikator loading data

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Ambil data profil pengguna
    fetchProductList(); // Ambil daftar produk
  }

  /// Mengambil data profil pengguna dari API
  Future<void> fetchUserProfile() async {
    try {
      final profile = await apiService.fetchProfile(widget.userId);
      setState(() {
        userData = profile;
      });
    } catch (e) {
      showErrorDialog('Failed to load profile.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Mengambil daftar produk dari API
  Future<void> fetchProductList() async {
    try {
      final products = await apiService.fetchAllContent();
      setState(() {
        productList = products;
      });
    } catch (e) {
      showErrorDialog('Failed to load products.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Menampilkan dialog error jika ada kegagalan
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigasi ke halaman yang dipilih berdasarkan nama
  void _handleNavigation(String page) {
    Widget targetPage;

    if (page == 'Profile') {
      targetPage = ProfilePage(userId: widget.userId);
    } else if (page == 'Product') {
      targetPage = AddProduct(userId: widget.userId);
    } else if (page == 'Message') {
      targetPage = Message(userId: widget.userId);
    } else {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
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

  /// Widget utama untuk menampilkan UI halaman Home
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Stack(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildProductGrid(),
                      ],
                    ),
                  ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  /// Membuat header halaman
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _handleNavigation('Message');
                },
                child: const Icon(
                  Icons.send,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _handleNavigation('Profile');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: userData['profile'] != null
                        ? NetworkImage(userData['profile'].startsWith('http')
                            ? userData['profile']
                            : '${apiService.baseUrl}/${userData['profile']}')
                        : null,
                    child: userData['profile'] == null
                        ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Membuat grid untuk menampilkan daftar produk
  Widget _buildProductGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.75,
        ),
        itemCount: productList.length,
        itemBuilder: (context, index) {
          var product = productList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    userId: widget.userId,
                    product: product,
                  ),
                ),
              );
            },
            child: Card(
              color: const Color.fromARGB(255, 181, 185, 221),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.45,
                    width: double.infinity,
                    child: Image.network(
                      product['image_item'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product['item_name'],
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.043,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Membuat bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
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
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.add_circle_outline, 'Product', false),
              _buildNavItem(Icons.person, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  /// Membuat widget navigasi untuk bottom navigation bar
  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    Color iconColor = isSelected ? Colors.blue : Colors.grey;
    Color textColor = isSelected ? Colors.blue : Colors.grey;

    return GestureDetector(
      onTap: () {
        if (label == 'Profile' || label == 'Product') {
          _handleNavigation(label);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
