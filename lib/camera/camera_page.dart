import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../classifier/classifier.dart';
import '../classifier/rule.dart';
import 'camera_service.dart';
import 'result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  // HAPUS: _initializeControllerFuture karena tidak digunakan

  final classifier = PlantDiseaseClassifier();

  // Animasi Scanner
  late AnimationController _animController;
  late Animation<double> _animOffset;

  bool _isModelLoaded = false;
  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animOffset = Tween<double>(begin: 0.0, end: 1.0).animate(_animController);
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.jpeg
          : ImageFormatGroup.bgra8888,
    );

    // FIX: Langsung await initialize() tanpa menyimpannya ke variabel future yang tidak dipakai
    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _loadModel() async {
    await classifier.loadModel();
    if (mounted) setState(() => _isModelLoaded = true);
  }

  void _toggleFlash() {
    if (_controller == null) return;
    setState(() => _isFlashOn = !_isFlashOn);
    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _processImage(String path) async {
    if (!_isModelLoaded) return;
    setState(() => _isProcessing = true);

    try {
      final imageFile = File(path);
      final result = classifier.predict(imageFile);
      final rule = getRecommendation(result['classId'] ?? 0);
      final confidence = (result['confidence'] ?? 0.0) * 100;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imagePath: path,
            diseaseLabel: rule['label'] ?? 'Unknown',
            confidence: confidence,
            recommendation: rule['recommendation'] ?? '',
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error processing: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menganalisis: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _isProcessing) return;
    try {
      final image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      debugPrint("Error capturing: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _processImage(image.path);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),

          // 2. Overlay Gelap
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.dstIn,
                  ),
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Border & Animasi Garis
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Aksen Sudut
                    Positioned(top: 0, left: 0, child: _buildCorner(false, false)),
                    Positioned(top: 0, right: 0, child: _buildCorner(false, true)),
                    Positioned(bottom: 0, left: 0, child: _buildCorner(true, false)),
                    Positioned(bottom: 0, right: 0, child: _buildCorner(true, true)),

                    // Garis Scanning Bergerak
                    if (_isProcessing || _isModelLoaded)
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Positioned(
                            top: 280 * _animOffset.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              // FIX: boxShadow dipindahkan ke dalam BoxDecoration
                              // FIX: withOpacity diganti dengan withValues
                              decoration: BoxDecoration(
                                color: _isProcessing
                                    ? Colors.green
                                    : Colors.white.withValues(alpha: 0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isProcessing ? Colors.green : Colors.white,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // 5. Text Petunjuk
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Text(
              _isProcessing
                  ? "Menganalisis..."
                  : "Posisikan daun di dalam kotak",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

          // 6. Tombol Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                    onPressed: _pickFromGallery,
                  ),
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isProcessing ? Colors.grey : const Color(0xFF4CAF50),
                          ),
                          child: _isProcessing
                              ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isBottom, bool isRight) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isBottom ? BorderSide.none : const BorderSide(color: Color(0xFF4CAF50), width: 4),
          bottom: isBottom ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
          left: isRight ? BorderSide.none : const BorderSide(color: Color(0xFF4CAF50), width: 4),
          right: isRight ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}