import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'camera_page.dart';
import '../database/database_helper.dart';
import '../database/history_model.dart';
import '../services/settings_service.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String diseaseName; // Nama penyakit (Early Blight, Bacterial Spot, dll)
  final String category; // Kategori kondisi (Healthy, Bacterial Infection, dll)
  final double confidence;
  final String recommendation;
  final int colorValue; // Warna dari categoryColors

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.diseaseName,
    required this.category,
    required this.confidence,
    required this.recommendation,
    required this.colorValue,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  // AUTO-SAVE KE DATABASE (CEK SETTINGS DULU)
  Future<void> _saveToHistory() async {
    try {
      // Cek apakah user mengaktifkan "Simpan Riwayat"
      final shouldSave = await SettingsService.instance.getSaveHistory();

      if (!shouldSave) {
        debugPrint("⏭️ Auto-save disabled by user");
        return;
      }

      final history = DiagnosisHistory(
        imagePath: widget.imagePath,
        diseaseName: widget.diseaseName,
        category: widget.category,
        confidence: widget.confidence,
        recommendation: widget.recommendation,
        colorValue: widget.colorValue,
        timestamp: DateTime.now(),
      );

      await DatabaseHelper.instance.insertHistory(history);
      debugPrint("💾 History auto-saved successfully");
    } catch (e) {
      debugPrint("❌ Failed to save history: $e");
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
        text:
        'Cek tanaman saya! Terdeteksi: ${widget.category} dengan akurasi ${widget.confidence.toStringAsFixed(1)}% via Leaf Sense App 🌱',
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
    final statusColor = Color(widget.colorValue);

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

                              // KATEGORI KONDISI (5 kategori sederhana untuk UI)
                              Text(
                                widget.category,
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
                                    widget.category,
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

              // INFO DETAIL PENYAKIT (Hanya muncul jika bukan Unknown)
              if (widget.diseaseName != "Unknown")
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Terdeteksi:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.diseaseName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.diseaseName != "Unknown") const SizedBox(height: 16),

              // REKOMENDASI PERAWATAN
              Text(
                widget.confidence < 50.0
                    ? 'Rekomendasi Umum (Confidence Rendah)'
                    : 'Rekomendasi Penanganan',
                style: const TextStyle(
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
                    Icon(
                      widget.confidence < 50.0
                          ? Icons.info_outlined
                          : Icons.medical_services_outlined,
                      color: const Color(0xFF4CAF50),
                    ),
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

              // Tambahan warning jika confidence rendah
              if (widget.confidence < 50.0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Tingkat keyakinan di bawah 50%. Untuk diagnosis akurat, konsultasikan dengan ahli pertanian.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.green),
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