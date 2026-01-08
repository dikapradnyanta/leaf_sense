import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classifier/rule.dart';

class DisclaimerPage extends StatelessWidget {
  const DisclaimerPage({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Informasi & Referensi",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DISCLAIMER AI
            _buildSection(
              icon: Icons.info_outline,
              iconColor: Colors.orange,
              title: "Disclaimer AI",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDisclaimerItem(
                    "🤖 Teknologi AI",
                    "Aplikasi ini menggunakan teknologi Machine Learning berbasis TensorFlow Lite untuk mendeteksi penyakit tanaman.",
                  ),
                  _buildDisclaimerItem(
                    "📊 Akurasi Terbatas",
                    "AI tidak 100% akurat. Hasil diagnosis dapat dipengaruhi oleh kualitas foto, pencahayaan, dan kondisi daun.",
                  ),
                  _buildDisclaimerItem(
                    "⚠️ Bukan Pengganti Ahli",
                    "Aplikasi ini hanya alat bantu awal. Untuk diagnosis yang akurat dan penanganan tepat, konsultasikan dengan ahli pertanian atau agronomis profesional.",
                  ),
                  _buildDisclaimerItem(
                    "🔬 Ruang Lingkup",
                    "Model ini dilatih khusus untuk mendeteksi penyakit pada tanaman paprika, kentang, dan tomat berdasarkan dataset PlantVillage.",
                  ),
                  _buildDisclaimerItem(
                    "💊 Rekomendasi Umum",
                    "Rekomendasi penanganan yang diberikan bersifat umum. Dosis, jenis pestisida/fungisida, dan metode aplikasi harus disesuaikan dengan kondisi lokal dan regulasi setempat.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SUMBER REFERENSI
            _buildSection(
              icon: Icons.menu_book_outlined,
              iconColor: Colors.green,
              title: "Sumber Referensi",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rekomendasi penanganan penyakit disusun berdasarkan publikasi ilmiah dan panduan dari lembaga pertanian terpercaya:",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Loop Semua Referensi
                  ...references.map((ref) => _buildReferenceCard(
                    context,
                    title: ref['title']!,
                    sources: ref['sources']!,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DATASET INFO
            _buildSection(
              icon: Icons.dataset_outlined,
              iconColor: Colors.blue,
              title: "Dataset & Model",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDisclaimerItem(
                    "📁 PlantVillage Dataset",
                    "Model AI ini dilatih menggunakan PlantVillage dataset yang berisi ribuan gambar penyakit tanaman dari berbagai kondisi.",
                  ),
                  _buildDisclaimerItem(
                    "🎯 15 Kelas Penyakit",
                    "Model dapat mengenali 15 kelas berbeda meliputi kondisi sehat, infeksi bakteri, jamur, virus, dan hama pada 3 jenis tanaman.",
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _launchURL("https://github.com/spMohanty/PlantVillage-Dataset"),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text("Lihat Dataset PlantVillage"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // FOOTER
            Center(
              child: Column(
                children: [
                  Text(
                    "Leaf Sense © 2024",
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "v1.0.0",
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildDisclaimerItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(BuildContext context, {required String title, required String sources}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sources.trim(),
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}