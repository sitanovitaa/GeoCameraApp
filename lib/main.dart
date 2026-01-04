import 'dart:io'; // Untuk mengakses File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'preview_page.dart'; // Import PreviewPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GeoCameraPage(),
    );
  }
}

class GeoCameraPage extends StatefulWidget {
  const GeoCameraPage({super.key});

  @override
  State<GeoCameraPage> createState() => _GeoCameraPageState();
}

class _GeoCameraPageState extends State<GeoCameraPage> {
  // Variabel untuk menyimpan file foto
  File? _image;

  // Variabel untuk menyimpan teks lokasi
  String _locationMessage = "Lokasi belum diambil";

  // Variabel loading agar UI tidak freeze
  bool _isLoading = false;

  // Tambahkan di bawah variabel _isLoading
  bool _isPhotoVisible = false;

  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Tambahkan state untuk status tombol di _GeoCameraPageState
  bool _isButtonPressed = false;

  // FUNGSI 1: Meminta Izin & Ambil Lokasi
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi (GPS) nonaktif.');
    }

    // Cek izin aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak permanen.');
    }

    // Jika semua aman, ambil posisi saat ini
    return await Geolocator.getCurrentPosition();
  }

  // Buat fungsi untuk menangani efek tekan
  void _animateButton() async {
    setState(() {
      _isButtonPressed = true; // Kecilkan tombol
    });

    // Tunggu sebentar (100ms) lalu kembalikan ukuran
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _isButtonPressed = false; // Kembalikan ukuran normal
    });
  }

  // FUNGSI UTAMA: Ambil Foto lalu Ambil Lokasi
  Future<void> _takePictureAndLocation() async {
    // 1. Reset animasi (Sembunyikan foto lama jika ada)
    setState(() {
      _isPhotoVisible = false;
      _isLoading = true;
    });

    try {
      // 1. Buka Kamera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Kompresi agar tidak terlalu besar
      );

      // Jika user menekan tombol 'Back' (batal foto)
      if (photo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Ambil Lokasi (Hanya jika foto berhasil diambil)
      Position position = await _determinePosition();

      // 3. Update State (Tampilan)
      setState(() {
        _image = File(photo.path); // Konversi XFile ke File
        _locationMessage =
            "Latitude: ${position.latitude}\nLongitude: ${position.longitude}";
        _isLoading = false;

        // 2. Memicu animasi (Tampilkan foto)
        _isPhotoVisible = true;
      });

    } catch (e) {
      // Tangani error (misal: GPS mati, atau Izin ditolak)
      setState(() {
        _isLoading = false;
        _locationMessage = "Gagal mengambil data: $e";
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoCamera Praktikum'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AREA FOTO
              // Cari bagian Container yang menampilkan foto
              // Bungkus dengan AnimatedOpacity
              AnimatedOpacity(
                opacity: _isPhotoVisible ? 1.0 : 0.0, // Logika animasi
                duration: const Duration(milliseconds: 1000), // Durasi 1 detik
                curve: Curves.easeInOut, // Gaya animasi (lebih halus)
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            Text("Belum ada foto"),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            // Navigasi ke halaman preview
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PreviewPage(imageFile: _image!),
                              ),
                            );
                          },
                          // WIDGET HERO: Tag harus SAMA dengan tag di halaman tujuan
                          child: Hero(
                            tag: 'foto_hasil',
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // AREA LOKASI
              Text(
                _locationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // TOMBOL AKSI
              // Ganti kode ElevatedButton yang lama dengan kode ini
              GestureDetector(
                onTap: () {
                  _animateButton(); // Jalankan animasi
                  _takePictureAndLocation(); // Jalankan fungsi utama
                },
                child: AnimatedScale(
                  scale: _isButtonPressed ? 0.9 : 1.0, // Jika ditekan, skala 0.9 (90%)
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Ambil Foto & Lokasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
