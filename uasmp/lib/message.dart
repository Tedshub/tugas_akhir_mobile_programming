import 'package:flutter/material.dart';
import 'api_url.dart';

// Widget Message menerima userId dari halaman sebelumnya sebagai parameter.
class Message extends StatefulWidget {
  final String userId;

  const Message({Key? key, required this.userId}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  // Data profil pengguna yang akan diambil dari server
  Map<String, dynamic> userData = {};

  // Menandakan apakah data profil sedang dimuat
  bool isLoadingProfile = true;

  // Menyimpan pesan error jika terjadi kesalahan
  String? _errorMessage;

  // Instance dari ApiService untuk berkomunikasi dengan server
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi untuk mengambil data profil pengguna saat widget pertama kali dibangun
    fetchUserProfile();
  }

  // Fungsi untuk mengambil data profil pengguna dari API
  Future<void> fetchUserProfile() async {
    try {
      // Mengambil data profil dengan memanggil fungsi apiService.fetchProfile
      final data = await apiService.fetchProfile(widget.userId);

      setState(() {
        userData = data;
        isLoadingProfile = false; // Menandakan bahwa pemuatan selesai
      });
    } catch (e) {
      // Menangani kesalahan dan menyimpan pesan error
      print('Error fetching profile: $e');
      setState(() {
        isLoadingProfile = false;
        _errorMessage = "No incoming messages";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang dengan gradien warna biru
          Container(
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
          ),
          // Konten utama dalam SafeArea agar tidak terganggu oleh status bar
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol kembali untuk navigasi ke halaman sebelumnya
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 13.0, top: 10),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        iconSize: 30, // Ukuran ikon lebih besar
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Memberikan jarak vertikal
                  // Judul halaman
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Message",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Menampilkan loader jika data masih dimuat
                  if (isLoadingProfile)
                    const CircularProgressIndicator(color: Colors.white)
                  // Menampilkan pesan error jika terjadi kesalahan
                  else if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    )
                  // Jika tidak ada error, menampilkan placeholder untuk pesan
                  else if (!isLoadingProfile && _errorMessage == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 200),
                      child: Text(
                        "The message will be displayed here",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
