import 'package:flutter/material.dart';
import 'creat.dart';
import 'edit.dart';
import 'profile_page.dart';
import 'home_page.dart';
import 'api_url.dart';

// Widget AddProduct menerima userId sebagai parameter dari halaman sebelumnya
class AddProduct extends StatefulWidget {
  final String userId;

  const AddProduct({Key? key, required this.userId}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProduct> {
  // Daftar produk yang diambil dari API
  List<dynamic> productList = [];
  // Menandakan apakah data sedang dimuat
  bool isLoading = true;
  // Instansiasi objek ApiService untuk berkomunikasi dengan API
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi untuk mengambil daftar produk saat halaman dibuka
    fetchProductList();
  }

  // Fungsi untuk mengambil daftar produk dari API
  Future<void> fetchProductList() async {
    try {
      // Mengambil data produk menggunakan method fetchAllContent dari ApiService
      final response = await apiService.fetchAllContent();
      setState(() {
        productList =
            response; // Menyimpan data produk yang diambil ke dalam productList
        isLoading = false; // Menandakan pemuatan selesai
      });
    } catch (e) {
      // Menangani jika terjadi kesalahan saat mengambil data
      print('Error: $e');
      setState(() {
        isLoading =
            false; // Menandakan pemuatan selesai meskipun terjadi kesalahan
      });
    }
  }

  // Fungsi untuk menangani navigasi ke halaman lain
  void _handleNavigation(String page) {
    if (page == 'Profile') {
      // Menavigasi ke halaman Profile dengan animasi geser ke kanan
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ProfilePage(userId: widget.userId),
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
    } else if (page == 'Home') {
      // Menavigasi ke halaman Home dengan animasi geser ke kiri
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomePage(userId: widget.userId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Stack(
          children: [
            // Area konten dengan SafeArea agar tidak tertutup oleh status bar
            SafeArea(
              child: Column(
                children: [
                  // Header halaman
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 25, bottom: 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Daftar produk yang dapat digulir
                  Expanded(
                    child: isLoading
                        ? Center(
                            child:
                                CircularProgressIndicator()) // Menampilkan indikator loading jika data sedang dimuat
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              top: 16,
                              left: 16,
                              right: 16,
                              bottom:
                                  180, // Padding tambahan untuk tombol bawah
                            ),
                            itemCount: productList.length,
                            itemBuilder: (context, index) {
                              final product = productList[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                color: const Color.fromARGB(255, 181, 185, 221),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        product['image_item'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['item_name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              product['description'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Tombol untuk menghapus dan mengedit produk
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () async {
                                              try {
                                                // Menghapus produk melalui API
                                                final success = await apiService
                                                    .deleteContent(
                                                        product['id_item']
                                                            .toString());
                                                if (success) {
                                                  // Jika sukses, hapus produk dari daftar
                                                  setState(() {
                                                    productList.remove(product);
                                                  });

                                                  // Menampilkan snackbar sukses
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Product deleted successfully'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                // Jika gagal, tampilkan snackbar error
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Failed to delete product: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            color: Colors.blue,
                                            onPressed: () {
                                              // Menavigasi ke halaman EditProduct
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPage(
                                                    userId: widget.userId,
                                                    product: product,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            // Tombol untuk menambah produk
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  // Menavigasi ke halaman CreateProduct
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CreatPage(userId: widget.userId),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
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
                  'Add Product',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Bar navigasi bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                      // Item navigasi Home
                      _buildNavItem(Icons.home, 'Home', false),
                      // Item navigasi Product (terpilih)
                      _buildNavItem(Icons.add_circle_outline, 'Product', true),
                      // Item navigasi Profile
                      _buildNavItem(Icons.person, 'Profile', false),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun item navigasi di bottom bar
  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () =>
          _handleNavigation(label), // Menangani aksi ketika item ditekan
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
}
