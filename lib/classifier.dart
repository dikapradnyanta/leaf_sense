import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantDiseaseClassifier {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  late List<int> _inputShape;
  late List<int> _outputShape;

  // PERBAIKAN: Gunakan TensorType, sesuai dengan API tflite_flutter v0.10+
  late TensorType _inputType;
  late TensorType _outputType;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/plant_disease_model.tflite',
      );

      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      // PERBAIKAN: Assignment sekarang valid karena tipenya sama (TensorType)
      _inputType = _interpreter!.getInputTensor(0).type;
      _outputType = _interpreter!.getOutputTensor(0).type;

      _isLoaded = true;

      debugPrint("✅ Model loaded successfully (API v0.12.1)");
      debugPrint("📥 Input shape: $_inputShape");
      debugPrint("📥 Input type: $_inputType");
      debugPrint("📤 Output shape: $_outputShape");
      debugPrint("📤 Output type: $_outputType");
    } catch (e) {
      debugPrint("❌ Error loading model: $e");
    }
  }

  // Pra-pemrosesan untuk API modern
  ByteBuffer _preprocessImage(img.Image image) {
    final inputHeight = _inputShape[1];
    final inputWidth = _inputShape[2];
    img.Image resizedImage =
    img.copyResize(image, width: inputWidth, height: inputHeight);

    // PERBAIKAN: Gunakan enum TensorType.float32 untuk perbandingan
    if (_inputType == TensorType.float32) {
      final float32List = Float32List(1 * inputHeight * inputWidth * 3);
      int bufferIndex = 0;
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          // Normalisasi nilai R, G, B ke [0.0, 1.0]
          float32List[bufferIndex++] = (pixel.r / 255.0);
          float32List[bufferIndex++] = (pixel.g / 255.0);
          float32List[bufferIndex++] = (pixel.b / 255.0);
        }
      }
      return float32List.buffer;
    } else {
      // Jika model mengharapkan uint8, kembalikan byte langsung
      return resizedImage
          .getBytes(order: img.ChannelOrder.rgb)
          .buffer;
    }
  }

  Map<String, dynamic> predict(File imageFile) {
    if (!_isLoaded || _interpreter == null) throw Exception("Model not loaded");

    try {
      // 1. Load & decode gambar
      final bytes = imageFile.readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception("Failed to decode image");

      debugPrint("📸 Image loaded: ${image.width}x${image.height}");

      // 2. Pra-pemrosesan gambar
      final inputBuffer = _preprocessImage(image);

      // 3. Buat Map untuk menampung output
      final output = <int, Object>{
        0: List.filled(_outputShape.reduce((a, b) => a * b), 0.0)
            .reshape(_outputShape)
      };

      debugPrint(
          "✅ Image preprocessed. Input buffer size: ${inputBuffer
              .lengthInBytes} bytes");

      // 4. Jalankan inferensi
      _interpreter!.runForMultipleInputs([inputBuffer], output);

      debugPrint("📊 Raw output: ${output[0]}");

      // 5. Proses hasil
      // Ambil hasil dari map output dan konversi ke tipe yang benar
      final List<dynamic> rawProbabilities = (output[0] as List).first;
      final List<double> probabilities = rawProbabilities.cast<double>();

      int classId = 0;
      double maxScore = -double.infinity;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxScore) {
          maxScore = probabilities[i];
          classId = i;
        }
      }

      debugPrint(
          "✅ Prediction - ClassID: $classId, Confidence: ${(maxScore * 100)
              .toStringAsFixed(2)}%");

      return {
        'classId': classId,
        'confidence': maxScore,
        'probabilities': probabilities,
      };
    } catch (e, s) {
      debugPrint("❌ Error during prediction: $e");
      debugPrint("Stack trace: $s");
      throw Exception("Prediction failed: $e");
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}