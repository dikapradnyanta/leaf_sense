import 'dart:io';
import 'dart:typed_data';
import 'dart:math'; // PENTING: Untuk perhitungan matematika warna
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantDiseaseClassifier {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  late List<int> _inputShape;
  late List<int> _outputShape;
  late TensorType _inputType;
  late TensorType _outputType;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/plant_disease_model.tflite',
      );

      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputShape = _interpreter!.getOutputTensor(0).shape;
      _inputType = _interpreter!.getInputTensor(0).type;
      _outputType = _interpreter!.getOutputTensor(0).type;

      _isLoaded = true;
      debugPrint("✅ Model loaded successfully");
    } catch (e) {
      debugPrint("❌ Error loading model: $e");
    }
  }

  // --- LOGIKA FILTER HSV (SANGAT KETAT) ---
  bool _isPlantColor(img.Image image) {
    int validPixels = 0;
    int totalCheckedPixels = 0;

    // Kita hanya cek area tengah (Center Crop 60%)
    // Karena biasanya daun ada di tengah, pinggiran seringkali background sampah
    int startX = (image.width * 0.2).toInt();
    int endX = (image.width * 0.8).toInt();
    int startY = (image.height * 0.2).toInt();
    int endY = (image.height * 0.8).toInt();

    // Loop pixel dengan step 4 biar tidak berat (performance)
    for (int y = startY; y < endY; y += 4) {
      for (int x = startX; x < endX; x += 4) {
        final pixel = image.getPixel(x, y);

        // Konversi RGB ke HSV Manual
        double r = pixel.r / 255.0;
        double g = pixel.g / 255.0;
        double b = pixel.b / 255.0;

        double maxVal = [r, g, b].reduce(max);
        double minVal = [r, g, b].reduce(min);
        double delta = maxVal - minVal;

        // 1. Hitung Hue (Warna Dasar)
        double hue = 0.0;
        if (delta == 0) {
          hue = 0.0;
        } else if (maxVal == r) {
          hue = 60 * (((g - b) / delta) % 6);
        } else if (maxVal == g) {
          hue = 60 * (((b - r) / delta) + 2);
        } else {
          hue = 60 * (((r - g) / delta) + 4);
        }
        if (hue < 0) hue += 360;

        // 2. Hitung Saturation (Kepekatan Warna)
        double saturation = maxVal == 0 ? 0 : delta / maxVal;

        // 3. Hitung Value (Kecerahan)
        double value = maxVal;

        // --- ATURAN KETAT (STRICT RULES) ---

        // Aturan 1: Rentang Warna Daun (Hue)
        // Coklat (10-40), Kuning (40-60), Hijau (60-150)
        // Kita tolak Ungu (240+), Biru (200+), Merah Pink (300+)
        bool isPlantHue = (hue >= 10 && hue <= 165);

        // Aturan 2: Tidak Boleh Pucat (Saturation)
        // Tolak abu-abu, tembok putih, lantai keramik (Saturation < 15%)
        bool isSaturated = (saturation > 0.15);

        // Aturan 3: Tidak Boleh Terlalu Gelap (Value)
        // Tolak bayangan gelap atau foto malam (Value < 20%)
        bool isBrightEnough = (value > 0.2);

        if (isPlantHue && isSaturated && isBrightEnough) {
          validPixels++;
        }

        totalCheckedPixels++;
      }
    }

    // Hitung Rasio
    double plantRatio = validPixels / totalCheckedPixels;
    debugPrint("🌿 Strict Plant Ratio: ${(plantRatio * 100).toStringAsFixed(1)}%");

    // SYARAT LOLOS: Minimal 30% dari area tengah harus terdeteksi sebagai "Unsur Daun"
    return plantRatio > 0.30;
  }

  ByteBuffer _preprocessImage(img.Image image) {
    final inputHeight = _inputShape[1];
    final inputWidth = _inputShape[2];

    // 1. Center Crop dulu biar rasio tidak gepeng
    final size = image.width < image.height ? image.width : image.height;
    final img.Image croppedImage = img.copyCrop(
        image,
        x: (image.width - size) ~/ 2,
        y: (image.height - size) ~/ 2,
        width: size,
        height: size
    );

    // 2. Resize
    final img.Image resizedImage = img.copyResize(
        croppedImage,
        width: inputWidth,
        height: inputHeight
    );

    if (_inputType == TensorType.float32) {
      final float32List = Float32List(1 * inputHeight * inputWidth * 3);
      int bufferIndex = 0;
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // KIRIM NILAI RAW (0-255) karena di Colab biasanya ada Rescaling
          float32List[bufferIndex++] = pixel.r.toDouble();
          float32List[bufferIndex++] = pixel.g.toDouble();
          float32List[bufferIndex++] = pixel.b.toDouble();
        }
      }
      return float32List.buffer;
    } else {
      return resizedImage.getBytes(order: img.ChannelOrder.rgb).buffer;
    }
  }

  Map<String, dynamic> predict(File imageFile) {
    if (!_isLoaded || _interpreter == null) throw Exception("Model not loaded");

    try {
      final bytes = imageFile.readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception("Failed to decode image");

      // --- FILTER WARNA KETAT ---
      if (!_isPlantColor(image)) {
        debugPrint("⛔ DITOLAK: Objek tidak memenuhi syarat warna tanaman.");
        return {
          'classId': -1, // ID "Tidak Dikenali"
          'confidence': 0.0,
          'probabilities': [],
        };
      }

      final inputBuffer = _preprocessImage(image);
      final output = <int, Object>{
        0: List.filled(_outputShape.reduce((a, b) => a * b), 0.0).reshape(_outputShape)
      };

      _interpreter!.runForMultipleInputs([inputBuffer], output);

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

      return {
        'classId': classId,
        'confidence': maxScore,
        'probabilities': probabilities,
      };
    } catch (e) {
      debugPrint("❌ Error during prediction: $e");
      throw Exception("Prediction failed: $e");
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}