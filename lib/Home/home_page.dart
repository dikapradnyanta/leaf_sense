import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../camera/camera_page.dart';
import '../camera/result_page.dart';
import '../Home/settings_page.dart';
import '../Home/history_page.dart';
import '../classifier/classifier.dart';
import '../classifier/rule.dart';
import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk Guide (bisa di-close)
  bool _showGuide = true;

  // Classifier untuk fitur Galeri Langsung
  final classifier = PlantDiseaseClassifier();

  // Counter riwayat
  int _historyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadHistoryCount();
  }

  Future<void> _loadModel() async {
    await classifier.loadModel();
  }

  Future<void> _loadHistoryCount() async {
    try {
      final count = await DatabaseHelper.instance.getHistoryCount();
      if (mounted) {
        setState(() => _historyCount = count);
      }
    } catch (e) {
      debugPrint("Error loading history count: $e");
    }
  }

  // Refresh count setiap kali halaman muncul
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistoryCount();
  }

  // LOGIC: Proses Gambar dari Galeri Langsung
  Future<void> _pickAndAnalyzeGallery() async {
    final picker = ImagePicker();

    // 1. Ambil Gambar (Async)
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // 2. Cek apakah user membatalkan ATAU halaman sudah ditutup (Async Gap Fix)
    if (image == null || !mounted) return;

    try {
      // Tampilkan Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Prediksi (Berat)
      final imageFile = File(image.path);
      final result = classifier.predict(imageFile);
      final confidence = (result['confidence'] ?? 0.0) * 100;

      // Get recommendation dengan sistem baru
      final rule = getRecommendation(result['classId'] ?? 0, confidence);

      // Cek mounted sebelum menutup dialog
      // Pindah ke Result Page
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imagePath: image.path,
            diseaseName: rule['diseaseName'] ?? 'Unknown',
            diseaseNameId: rule['diseaseNameId'] ?? 'Tidak Diketahui',
            category: rule['category'] ?? 'Unknown',
            confidence: confidence,
            recommendation: rule['recommendation'] ?? '',
            colorValue: rule['color'] ?? 0xFF9E9E9E, // ✅ TAMBAHKAN INI
          ),
        ),
      ).then((_) {
        // Refresh history count setelah kembali dari result page
        _loadHistoryCount();
      });
    } catch (e) {
      // Error Handling
      if (mounted) {
        // Tutup dialog loading jika masih terbuka
        Navigator.pop(context);

        debugPrint("Error gallery: $e");

        // Tampilkan error (Safe Context)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menganalisis: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER MINIMALIS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, Plant Lover! 🌱",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SvgPicture.asset(
                        'assets/logo/logo-small-with text.svg',
                        height: 32,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.black87),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 2. DISMISSIBLE GUIDE
              if (_showGuide)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC5E1A5).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFF558B2F), size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Panduan Singkat",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF33691E),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showGuide = false),
                            child: const Icon(Icons.close, size: 20, color: Colors.grey),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "1. Pastikan pencahayaan cukup terang.\n"
                            "2. Posisikan daun tepat di tengah kotak.\n"
                            "3. Hindari background yang terlalu ramai.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF558B2F),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. MAIN ACTION AREA
              const Text(
                "Mulai Diagnosis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: "Scan Kamera",
                      icon: Icons.camera_alt_rounded,
                      color: const Color(0xFF4CAF50),
                      isPrimary: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CameraPage()),
                        ).then((_) {
                          // Refresh history count setelah kembali
                          _loadHistoryCount();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: "Upload Galeri",
                      icon: Icons.photo_library_rounded,
                      color: const Color(0xFFFF9800),
                      isPrimary: false,
                      onTap: _pickAndAnalyzeGallery,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 4. HISTORY SECTION (SEKARANG BISA DIKLIK!)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                  ).then((_) {
                    // Refresh count setelah kembali dari history page
                    _loadHistoryCount();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Riwayat Diagnosis",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _historyCount > 0
                                  ? "$_historyCount riwayat tersimpan"
                                  : "Belum ada riwayat tersimpan",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required bool isPrimary,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isPrimary ? null : Border.all(color: Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : color,
                size: 28,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isPrimary ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPrimary)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Real-time AI",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}