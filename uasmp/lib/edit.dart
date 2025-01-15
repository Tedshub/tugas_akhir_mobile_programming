import 'package:flutter/material.dart';
import 'product.dart'; // Halaman produk untuk navigasi setelah berhasil menambahkan atau memperbarui produk
import 'api_url.dart'; // Kelas API untuk menghubungkan ke backend

// Widget utama untuk halaman pengeditan/penambahan produk
class EditPage extends StatefulWidget {
  final String userId; // ID pengguna yang sedang aktif
  final Map<String, dynamic>? product; // Data produk yang akan diedit, jika ada

  const EditPage({
    Key? key,
    required this.userId,
    this.product,
  }) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

// State untuk widget EditPage
class _EditState extends State<EditPage> {
  // Controller untuk input data
  final TextEditingController _imageItemController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Status untuk loading, pesan error, dan keberhasilan
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  final ApiService _apiService = ApiService(); // Instance kelas ApiService

  // Inisialisasi state
  @override
  void initState() {
    super.initState();
    // Jika ada data produk, isi field dengan data yang ada
    if (widget.product != null) {
      _imageItemController.text = widget.product!['image_item'] ?? '';
      _itemNameController.text = widget.product!['item_name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
    }

    // Perbarui state setiap kali URL gambar berubah
    _imageItemController.addListener(() {
      setState(() {});
    });
  }

  // Membersihkan controller saat widget dihancurkan
  @override
  void dispose() {
    _imageItemController.dispose();
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambahkan atau memperbarui produk
  Future<void> _submitProduct() async {
    // Validasi input
    if (_imageItemController.text.trim().isEmpty ||
        _itemNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage =
            'Please fill in all fields'; // Pesan error jika input kosong
      });
      return;
    }

    // Mulai proses loading
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success;
      // Jika ada data produk, lakukan update
      if (widget.product != null) {
        String idItem = widget.product!['id_item'].toString(); // ID produk
        success = await _apiService.updateContent(
          idItem,
          _imageItemController.text.trim(),
          _itemNameController.text.trim(),
          _descriptionController.text.trim(),
        );
      } else {
        // Jika tidak ada data produk, tambahkan produk baru
        success = await _apiService.addContent(
          _imageItemController.text.trim(),
          _itemNameController.text.trim(),
          _descriptionController.text.trim(),
        );
      }

      // Jika berhasil, tampilkan pesan sukses
      if (success) {
        setState(() {
          _isSuccess = true;
          _errorMessage = null;
        });

        // Tunggu sebentar sebelum navigasi ke halaman sebelumnya
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddProduct(userId: widget.userId),
            ),
          );
        }
      }
    } catch (e) {
      // Tangani error
      print('Error occurred: $e');
      setState(() {
        _errorMessage =
            'Failed to ${widget.product != null ? "update" : "add"} product: ${e.toString()}';
      });
    } finally {
      // Matikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Membangun UI halaman
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(), // Latar belakang gradien
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(), // Header dengan tombol kembali
                  _buildImage(height), // Gambar produk
                  _buildTextField(
                    icon: Icons.image,
                    controller: _imageItemController,
                    hintText: 'Image URL',
                    isPassword: false,
                  ), // Input URL gambar
                  _buildTextField(
                    icon: Icons.edit,
                    controller: _itemNameController,
                    hintText: 'Product Name',
                    isPassword: false,
                  ), // Input nama produk
                  _buildTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    isPassword: false,
                    maxLines: 3,
                  ), // Input deskripsi produk
                  if (_errorMessage != null)
                    _buildErrorMessage(), // Pesan error
                  if (_isSuccess) _buildSuccessMessage(), // Pesan sukses
                  const SizedBox(height: 20),
                  _buildSubmitButton(), // Tombol simpan
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk latar belakang gradien
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

  // Widget untuk header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.product != null ? "Edit Product" : "Add Product",
            style: const TextStyle(
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
    return SizedBox(
      height: height / 3.7,
      child: CircleAvatar(
        backgroundImage: NetworkImage(
          _imageItemController.text.isNotEmpty
              ? _imageItemController.text
              : 'https://via.placeholder.com/150',
        ),
        radius: height / 7.4,
      ),
    );
  }

  // Widget untuk input teks
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

  // Widget untuk pesan error
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

  // Widget untuk pesan sukses
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
          Expanded(
            child: Text(
              widget.product != null
                  ? 'Product updated successfully!'
                  : 'Product added successfully!',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tombol simpan
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
        onPressed: _isLoading ? null : _submitProduct,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.product != null ? 'Update Product' : 'Add Product',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }
}
