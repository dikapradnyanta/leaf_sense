import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'camera_page.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String diseaseLabel;
  final double confidence;
  final String recommendation;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.diseaseLabel,
    required this.confidence,
    required this.recommendation,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Color _getStatusColor(String label) {
    switch (label.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF4CAF50); // Hijau
      case 'penyakit ringan':
        return const Color(0xFFFF9800); // Oranye
      case 'penyakit menular':
        return const Color(0xFFF44336); // Merah
      case 'penyakit berat':
        return const Color(0xFFD32F2F); // Merah Tua
      case 'tidak dikenali':
        return Colors.grey;             // Abu-abu (Unknown)
      default:
        return Colors.grey;
    }
  }

  // LOGIC SHARE YANG AMAN (Async Gaps Fixed)
  Future<void> _captureAndShare() async {
    setState(() => _isSharing = true);

    try {
      // 1. Ambil Render Object dari RepaintBoundary
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 2. Convert ke Image (High Quality)
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Cek mounted setelah await pertama
      if (!mounted) return;

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. Simpan ke Temporary Directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/leaf_sense_result.png').create();
      await file.writeAsBytes(pngBytes);

      // Cek mounted sebelum dialog share
      if (!mounted) return;

      final xFile = XFile(file.path);

      // 4. Share File
      await Share.shareXFiles(
        [xFile],
        text: 'Cek tanaman saya! Terdeteksi: ${widget.diseaseLabel} dengan akurasi ${widget.confidence.toStringAsFixed(1)}% via Leaf Sense App 🌱',
      );

    } catch (e) {
      debugPrint("Error sharing: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membagikan: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.diseaseLabel);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hasil Diagnosis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // AREA KARTU (YANG AKAN DI-SHARE)
              // ============================================================
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // 1. FOTO BACKGROUND
                        Image.file(
                          File(widget.imagePath),
                          width: double.infinity,
                          height: 450,
                          fit: BoxFit.cover,
                        ),

                        // 2. GRADIENT OVERLAY
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // 3. KONTEN OVERLAY
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LOGO APP
                              SvgPicture.asset(
                                'assets/logo/logo-white.svg',
                                height: 32,
                              ),

                              const SizedBox(height: 16),

                              // NAMA PENYAKIT
                              Text(
                                widget.diseaseLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // GARIS INDIKATOR WARNA
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // STATISTIK (Confidence & Condition)
                              Row(
                                children: [
                                  _buildStatItem(
                                    "CONFIDENCE",
                                    "${widget.confidence.toStringAsFixed(1)}%",
                                    Colors.white,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.white24,
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  _buildStatItem(
                                    "CONDITION",
                                    // LOGIKA 3 KONDISI: Sehat / Unknown / Terinfeksi
                                    widget.diseaseLabel == "Healthy"
                                        ? "Sehat"
                                        : (widget.diseaseLabel == "Tidak Dikenali" ? "Unknown" : "Terinfeksi"),
                                    statusColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ============================================================
              // END OF CARD
              // ============================================================

              const SizedBox(height: 30),

              // REKOMENDASI PERAWATAN
              const Text(
                'Rekomendasi Perawatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC5E1A5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.recommendation,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF33691E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TOMBOL AKSI
              Row(
                children: [
                  // Tombol Share
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSharing ? null : _captureAndShare,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSharing
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: Color(0xFF4CAF50)),
                          SizedBox(width: 8),
                          Text(
                            'Share Card',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tombol Scan Lagi
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const CameraPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Scan Lagi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER STATISTIK
  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 1),
              )
            ],
          ),
        ),
      ],
    );
  }
}