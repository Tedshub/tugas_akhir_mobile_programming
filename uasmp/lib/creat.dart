import 'package:flutter/material.dart';
import 'api_url.dart'; // Import kelas ApiService
import 'dart:io';
import 'product.dart';

class CreatPage extends StatefulWidget {
  final String userId;

  const CreatPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreatState createState() => _CreatState();
}

class _CreatState extends State<CreatPage> {
  // Controller untuk mengelola input teks dari pengguna
  final TextEditingController _imageItemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false; // Indikator apakah aplikasi sedang memproses
  String? _errorMessage; // Menyimpan pesan kesalahan
  bool _isSuccess = false; // Indikator apakah proses berhasil

  ApiService _apiService = ApiService(); // Inisialisasi objek ApiService

  @override
  void dispose() {
    // Membersihkan controller ketika widget dihapus dari pohon widget
    _imageItemController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambahkan produk baru
  Future<void> _addProduct() async {
    // Validasi input pengguna
    if (_imageItemController.text.trim().isEmpty ||
        _itemNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields'; // Pesan kesalahan
      });
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan indikator loading
      _errorMessage = null;
    });

    try {
      // Kirim data ke API melalui ApiService
      final bool success = await _apiService.addContent(
        _imageItemController.text.trim(),
        _itemNameController.text.trim(),
        _descriptionController.text.trim(),
      );

      if (success) {
        setState(() {
          _isSuccess = true; // Tandai proses berhasil
          _errorMessage = null;
        });

        // Tunggu beberapa detik sebelum navigasi
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Navigasi ke halaman AddProduct jika berhasil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddProduct(userId: widget.userId),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to add product'; // Pesan jika gagal
        });
      }
    } catch (e) {
      // Tangani berbagai jenis kesalahan
      print('Error occurred: $e');
      if (e is SocketException) {
        print('SocketException: Unable to reach the server.');
      } else if (e is HttpException) {
        print('HttpException: Failed to connect to the server.');
      } else {
        print('Unexpected error: $e');
      }
      setState(() {
        _errorMessage = 'Network error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hentikan indikator loading
        });
      }
    }
  }

  // Fungsi untuk membangun tampilan halaman
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(), // Background dengan gradient
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(), // Header dengan tombol kembali dan judul
                  _buildImage(height), // Widget untuk menampilkan gambar produk
                  _buildTextField(
                    icon: Icons.image,
                    controller: _imageItemController,
                    hintText: 'Image URL',
                    isPassword: false,
                  ),
                  _buildTextField(
                    icon: Icons.edit,
                    controller: _itemNameController,
                    hintText: 'Product Name',
                    isPassword: false,
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    isPassword: false,
                    maxLines: 3,
                  ),
                  if (_errorMessage != null)
                    _buildErrorMessage(), // Tampilkan error jika ada
                  if (_isSuccess)
                    _buildSuccessMessage(), // Tampilkan pesan sukses jika berhasil
                  const SizedBox(height: 20),
                  _buildSubmitButton(), // Tombol untuk menambahkan produk
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat background gradient
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

  // Widget untuk membuat header dengan tombol kembali
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Add Product",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan gambar produk
  Widget _buildImage(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: CircleAvatar(
        radius: height / 7.4,
        backgroundColor: Colors.grey[200],
        child: _imageItemController.text.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  _imageItemController.text.trim(),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              )
            : const Icon(
                Icons.image,
                size: 40,
                color: Colors.white,
              ),
      ),
    );
  }

  // Widget untuk menampilkan pesan kesalahan
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[300]),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan pesan sukses
  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[300]),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Product added successfully!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat tombol kirim
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed:
            _isLoading ? null : _addProduct, // Panggil fungsi _addProduct
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Add Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }

  // Widget untuk membuat field input
  Widget _buildTextField({
    IconData? icon,
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        onChanged: (text) {
          setState(() {});
        },
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
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
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        obscureText: isPassword,
      ),
    );
  }
}
