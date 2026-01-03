import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../classifier.dart';
import '../rule.dart';
import 'camera_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  final classifier = PlantDiseaseClassifier();
  bool _isModelLoaded = false;

  String resultText = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      debugPrint("No cameras available");
      return;
    }

    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _loadModel() async {
    try {
      await classifier.loadModel();
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint("Camera not initialized");
      return;
    }

    if (!_isModelLoaded) {
      setState(() {
        resultText = "Model belum dimuat. Silakan tunggu...";
      });
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      resultText = "Memproses gambar...";
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final imageFile = File(image.path);

      final result = classifier.predict(imageFile);
      final rule = getRecommendation(result['classId'] ?? 0);

      setState(() {
        resultText =
            """Klasifikasi AI : ${rule['label']}
Confidence     : ${(result['confidence'] ?? 0.0).toStringAsFixed(2)}
Rekomendasi    : ${rule['recommendation']}""";
      });
    } catch (e) {
      debugPrint("Error taking picture: $e");
      setState(() {
        resultText = "Error: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deteksi Penyakit Tanaman")),
      body: Column(
        children: [
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _takePicture,
            child: _isProcessing
                ? const CircularProgressIndicator()
                : const Text("Ambil Gambar & Deteksi"),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              resultText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
