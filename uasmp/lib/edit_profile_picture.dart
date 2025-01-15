import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'api_url.dart'; // Import the ApiService class

class EditProfilePicture extends StatefulWidget {
  final String userId; // User ID untuk mengidentifikasi pengguna.

  const EditProfilePicture({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePictureState createState() => _EditProfilePictureState();
}

class _EditProfilePictureState extends State<EditProfilePicture> {
  final TextEditingController _imageUrlController =
      TextEditingController(); // Controller untuk input URL gambar.
  bool _isLoading =
      false; // Status untuk menandakan apakah proses sedang berjalan.
  String? _errorMessage; // Menyimpan pesan kesalahan jika ada.
  Map<String, dynamic> userData =
      {}; // Menyimpan data pengguna yang diambil dari server.
  bool isLoadingProfile =
      true; // Status untuk menandakan apakah data profil sedang dimuat.
  final ApiService apiService = ApiService(); // Inisialisasi ApiService.

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Memuat data profil pengguna saat widget diinisialisasi.
  }

  // Fungsi untuk mengambil data profil pengguna dari server.
  Future<void> fetchUserProfile() async {
    try {
      final response = await apiService.fetchProfile(
          widget.userId); // Mengambil data profil berdasarkan userId.
      setState(() {
        userData = response;
        isLoadingProfile = false;
        // Jika terdapat URL profil, set URL tersebut ke controller.
        if (userData['profile'] != null) {
          _imageUrlController.text = userData['profile'];
        }
      });
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoadingProfile = false;
        _errorMessage =
            "Failed to load profile data"; // Set pesan kesalahan jika gagal memuat data.
      });
    }
  }

  // Fungsi untuk menyimpan gambar profil baru ke server.
  Future<void> saveProfilePicture() async {
    setState(() {
      _isLoading = true; // Set status loading menjadi true.
      _errorMessage = null; // Reset pesan kesalahan.
    });

    final String imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      // Validasi input URL gambar.
      setState(() {
        _errorMessage =
            "Please provide a valid image URL."; // Pesan kesalahan jika URL kosong.
        _isLoading = false; // Set status loading menjadi false.
      });
      return;
    }

    try {
      print('Sending update request for user ID: ${widget.userId}');
      print('Image URL: $imageUrl');

      final success = await apiService.updateProfile(
          widget.userId, imageUrl); // Mengirim permintaan update profil.

      if (success) {
        if (!mounted) return;

        // Navigasi ke halaman profil jika update berhasil.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: widget.userId),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              "Failed to update profile picture. Please try again."; // Pesan jika update gagal.
        });
      }
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        _errorMessage =
            "An error occurred. Please try again."; // Pesan jika terjadi error.
      });
    } finally {
      setState(() {
        _isLoading = false; // Set status loading menjadi false.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang gradient.
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
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tombol kembali.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Menampilkan gambar profil saat ini.
                  isLoadingProfile
                      ? const CircularProgressIndicator()
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageUrlController
                                      .text.isNotEmpty &&
                                  _imageUrlController.text.startsWith('http')
                              ? NetworkImage(_imageUrlController.text)
                              : userData['profile'] != null
                                  ? NetworkImage(userData['profile']
                                          .startsWith('http')
                                      ? userData['profile']
                                      : 'http://192.168.1.24:5000/${userData['profile']}')
                                  : null,
                          child: (_imageUrlController.text.isEmpty &&
                                  userData['profile'] == null)
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Edit Profile Picture",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Input URL gambar.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      controller: _imageUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.link, color: Colors.white),
                        hintText: "Paste the link to your picture",
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
                      onChanged: (text) {
                        // Memperbarui pratinjau gambar saat URL berubah.
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Menampilkan pesan kesalahan jika ada.
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Tombol simpan.
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 40,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed:
                              saveProfilePicture, // Simpan gambar profil.
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
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
