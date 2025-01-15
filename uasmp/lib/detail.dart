import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  // Widget ini menerima userId dan data produk (product) sebagai parameter.
  final String userId;
  final Map<String, dynamic>? product;

  const DetailPage({
    Key? key,
    required this.userId,
    this.product,
  }) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<DetailPage> {
  String? _errorMessage; // Menyimpan pesan kesalahan (jika ada).
  bool _isMaximized = false; // Status apakah gambar sedang diperbesar.

  @override
  void initState() {
    super.initState();
    // Jika data produk tersedia, tampilkan log produk saat diinisialisasi.
    if (widget.product != null) {
      print('Loading product data: ${widget.product}');
    }
  }

  @override
  void dispose() {
    // Fungsi dispose untuk membersihkan resource jika widget dihapus.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // Stack digunakan untuk membuat layout bertumpuk.
        children: [
          _buildBackground(), // Latar belakang gradient.
          SafeArea(
            child: SingleChildScrollView(
              // Scrollable content.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(), // Header dengan tombol kembali.
                  _buildProductCard(), // Kartu produk dengan gambar.
                  _buildItemName(), // Nama produk.
                  _buildProductDetails(), // Detail produk.
                  if (_errorMessage != null)
                    _buildErrorMessage(), // Pesan kesalahan.
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
          if (_isMaximized)
            _buildMaximizedImage(), // Overlay gambar diperbesar jika _isMaximized true.
        ],
      ),
    );
  }

  // Fungsi untuk membangun latar belakang gradient.
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

  // Fungsi untuk membangun header dengan tombol kembali.
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
            widget.product != null ? "Detail Product" : "Product Not Found",
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

  // Fungsi untuk membangun kartu produk yang berisi gambar produk.
  Widget _buildProductCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        widthFactor: 1.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                // Menangani klik pada gambar untuk memperbesar/memperkecil.
                onTap: () {
                  setState(() {
                    _isMaximized = !_isMaximized;
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    widget.product != null &&
                            widget.product!['image_item'] != null
                        ? widget.product!['image_item']
                        : 'https://via.placeholder.com/150',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan nama produk.
  Widget _buildItemName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Text(
        widget.product != null
            ? widget.product!['item_name'] ?? ''
            : 'No Product Name',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Fungsi untuk menampilkan deskripsi produk.
  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(
              widget.product != null
                  ? widget.product!['description'] ?? ''
                  : 'No Description',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menampilkan pesan kesalahan.
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

  // Fungsi untuk membangun overlay gambar yang diperbesar.
  Widget _buildMaximizedImage() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMaximized = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Image.network(
                widget.product != null && widget.product!['image_item'] != null
                    ? widget.product!['image_item']
                    : 'https://via.placeholder.com/150',
                fit: BoxFit.contain,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isMaximized = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
