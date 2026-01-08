// ============================================================================
// MAPPING 15 KELAS KE 5 KATEGORI KONDISI
// ============================================================================

const Map<int, String> classNames = {
  -1: "Unknown",
  0: "Pepper Bell Bacterial Spot",
  1: "Pepper Bell Healthy",
  2: "Potato Early Blight",
  3: "Potato Late Blight",
  4: "Potato Healthy",
  5: "Tomato Bacterial Spot",
  6: "Tomato Early Blight",
  7: "Tomato Late Blight",
  8: "Tomato Leaf Mold",
  9: "Tomato Septoria Leaf Spot",
  10: "Tomato Spider Mites",
  11: "Tomato Target Spot",
  12: "Tomato Yellow Leaf Curl Virus",
  13: "Tomato Mosaic Virus",
  14: "Tomato Healthy",
};

// Mapping ke 5 Kategori Kondisi (untuk UI Card)
const Map<int, String> categoryMapping = {
  -1: "Unknown",
  0: "Bacterial Infection",
  1: "Healthy",
  2: "Fungal Infection",
  3: "Fungal Infection",
  4: "Healthy",
  5: "Bacterial Infection",
  6: "Fungal Infection",
  7: "Fungal Infection",
  8: "Fungal Infection",
  9: "Fungal Infection",
  10: "Pest Damage",
  11: "Fungal Infection",
  12: "Viral Infection",
  13: "Viral Infection",
  14: "Healthy",
};

// Nama Penyakit untuk Display (Tanpa Nama Tanaman)
const Map<int, String> diseaseNames = {
  -1: "Unknown",
  0: "Bacterial Spot",
  1: "Healthy",
  2: "Early Blight",
  3: "Late Blight",
  4: "Healthy",
  5: "Bacterial Spot",
  6: "Early Blight",
  7: "Late Blight",
  8: "Leaf Mold",
  9: "Septoria Leaf Spot",
  10: "Spider Mites",
  11: "Target Spot",
  12: "Yellow Leaf Curl Virus",
  13: "Mosaic Virus",
  14: "Healthy",
};

// Warna per Kategori
const Map<String, int> categoryColors = {
  "Unknown": 0xFF9E9E9E, // Abu-abu
  "Healthy": 0xFF4CAF50, // Hijau
  "Bacterial Infection": 0xFFFF9800, // Oranye
  "Fungal Infection": 0xFFF44336, // Merah
  "Viral Infection": 0xFFD32F2F, // Merah Tua
  "Pest Damage": 0xFFFF6F00, // Oranye Gelap
};

// ============================================================================
// REKOMENDASI SPESIFIK (HIGH CONFIDENCE >= 50%)
// ============================================================================

const Map<int, String> specificRecommendations = {
  -1: """
Objek tidak terdeteksi sebagai tanaman.

Saran:
• Pastikan foto fokus pada daun dengan pencahayaan cukup
• Hindari background yang terlalu ramai atau berwarna
• Posisikan daun di tengah frame
• Coba ambil foto ulang dengan kondisi lebih baik
""",

  // === HEALTHY ===
  1: """
Tanaman dalam kondisi sehat!

Perawatan Rutin:
• Pertahankan jadwal penyiraman yang konsisten
• Berikan pupuk NPK seimbang setiap 2 minggu
• Pastikan sirkulasi udara baik di sekitar tanaman
• Monitor rutin untuk deteksi dini penyakit
""",

  4: """
Tanaman dalam kondisi sehat!

Perawatan Rutin:
• Jaga kelembaban tanah tetap stabil (tidak tergenang)
• Berikan pupuk kalium untuk perkembangan optimal
• Lakukan pembumbunan secara berkala
• Rotasi tanaman setiap 3-4 tahun
""",

  14: """
Tanaman dalam kondisi sehat!

Perawatan Rutin:
• Siram di pangkal tanaman, hindari membasahi daun
• Gunakan mulsa untuk mencegah percikan tanah
• Pangkas tunas samping untuk sirkulasi udara
• Berikan pupuk seimbang secara teratur
""",

  // === BACTERIAL INFECTIONS ===
  0: """
Penanganan Segera:
• Isolasi tanaman yang terinfeksi dari tanaman sehat
• Buang dan musnahkan daun yang terinfeksi (jangan dikompos)
• Semprotkan copper-based fungicide (tembaga hidroksida) setiap 7-10 hari
• Hindari penyiraman dari atas (overhead watering)
• Kurangi kelembaban dengan meningkatkan jarak tanam
• Gunakan benih bersertifikat bebas penyakit untuk penanaman berikutnya
""",

  5: """
Penanganan Segera:
• Isolasi tanaman terinfeksi segera
• Buang daun yang menunjukkan gejala dan musnahkan
• Aplikasikan copper fungicide + mancozeb setiap 7-10 hari
• Hindari bekerja dengan tanaman saat basah (pagi hari setelah embun)
• Gunakan sistem irigasi tetes, bukan sprinkler
• Praktikkan rotasi tanaman minimal 2 tahun
• Tingkatkan jarak tanam untuk sirkulasi udara
""",

  // === FUNGAL INFECTIONS ===
  2: """
Penanganan Segera:
• Buang dan bakar daun tua yang terinfeksi (bintik konsentris)
• Aplikasikan fungisida berbasis chlorothalonil atau mancozeb
• Tingkatkan pembumbunan untuk melindungi umbi dari spora
• Hindari stress tanaman dengan pemupukan nitrogen yang cukup
• Gunakan mulsa organik tebal untuk mencegah percikan tanah
• Panen umbi saat kulit sudah matang sepenuhnya
• Simpan umbi di tempat kering dengan ventilasi baik
""",

  3: """
⚠️ KONDISI KRITIS - Tindakan Darurat!

Penanganan Darurat:
• Segera pangkas dan musnahkan semua bagian tanaman yang terinfeksi
• Aplikasikan fungisida sistemik (metalaxyl + mancozeb) SEGERA
• Jika infeksi meluas, potong semua foliage dan tunggu 2 minggu sebelum panen
• Hindari menyimpan umbi yang terinfeksi (akan membusuk dan menyebar)
• Gunakan varietas tahan untuk musim berikutnya
• Penyakit ini sangat agresif - bertindak cepat dalam 24-48 jam!
""",

  6: """
Penanganan Segera:
• Buang daun bawah yang terinfeksi (bintik target konsentris)
• Aplikasikan fungisida chlorothalonil setiap 7-10 hari
• Gunakan mulsa untuk mencegah percikan tanah ke daun
• Siram di pangkal tanaman, bukan dari atas
• Pangkas cabang bawah untuk meningkatkan sirkulasi udara
• Berikan pupuk nitrogen cukup untuk menjaga vigor tanaman
• Pilih varietas resistant untuk musim depan
""",

  7: """
⚠️ KONDISI KRITIS - Tindakan Darurat!

Penanganan Darurat:
• Penyakit ini sangat agresif - bertindak dalam 24-48 jam!
• Buang dan musnahkan semua bagian yang terinfeksi SEGERA
• Aplikasikan fungisida berbasis copper atau chlorothalonil
• Jika kondisi sangat basah, pertimbangkan fungisida sistemik
• Jangan menyimpan buah dari tanaman terinfeksi
• Hancurkan sisa tanaman setelah panen
• Pilih varietas tahan untuk musim berikutnya
""",

  8: """
Penanganan Segera:
• Tingkatkan ventilasi dan kurangi kelembaban
• Buang daun yang terinfeksi (bercak kuning dengan spora abu-abu)
• Hindari penyiraman dari atas
• Aplikasikan fungisida berbasis chlorothalonil atau copper
• Jaga jarak tanam minimal 45-60 cm
• Gunakan varietas resistant jika tersedia
• Pertimbangkan penggunaan fan di greenhouse
""",

  9: """
Penanganan Segera:
• Buang daun bawah yang terinfeksi (bintik kecil abu-abu dengan tepi gelap)
• Aplikasikan fungisida chlorothalonil atau mancozeb setiap 7-10 hari
• Gunakan mulsa tebal untuk mencegah percikan tanah
• Siram di pangkal tanaman dengan sistem tetes
• Tingkatkan sirkulasi udara dengan pruning
• Rotasi tanaman minimal 2 tahun
• Bersihkan semua debris tanaman setelah panen
""",

  11: """
Penanganan Segera:
• Buang daun terinfeksi (bintik coklat dengan pola target)
• Aplikasikan fungisida berbasis azoxystrobin atau chlorothalonil
• Kurangi kelembaban dengan meningkatkan jarak tanam
• Hindari penyiraman sore/malam yang membuat daun basah lama
• Gunakan mulsa untuk mencegah percikan spora dari tanah
• Monitor intensif karena penyakit ini cepat menyebar
""",

  // === PEST DAMAGE ===
  10: """
Penanganan Segera:
• Semprotkan air bertekanan tinggi ke bawah daun untuk mengurangi populasi
• Aplikasikan insecticidal soap atau neem oil setiap 3-5 hari
• Tingkatkan kelembaban (tungau menyukai kondisi kering)
• Lepaskan predator alami: Phytoseiulus persimilis atau Amblyseius fallacis
• Hindari penggunaan insektisida broad-spectrum (membunuh predator alami)
• Buang daun yang sangat terinfeksi (bronzing/webbing)
• Pastikan irigasi cukup - tanaman stress lebih rentan
""",

  // === VIRAL INFECTIONS ===
  12: """
⚠️ SANGAT SERIUS - Tidak Ada Obat untuk Virus!

Penanganan Khusus:
• TIDAK ADA OBAT untuk virus - fokus pada pencegahan penyebaran
• Cabut dan musnahkan tanaman yang terinfeksi SEGERA (jangan dikompos!)
• Kendalikan vektor (whitefly) dengan:
  - Yellow sticky traps di sekitar tanaman
  - Insecticidal soap atau neem oil
  - Reflective mulch untuk mengusir whitefly
• Gunakan transplant sehat dari nursery bersertifikat
• Pilih varietas TYLCV-resistant untuk musim depan
• Virus ini menyebar cepat - tindakan cepat sangat krusial!
""",

  13: """
⚠️ SANGAT SERIUS - Tidak Ada Obat untuk Virus!

Penanganan Khusus:
• TIDAK ADA OBAT untuk virus - pencegahan adalah kunci
• Cabut dan musnahkan tanaman terinfeksi (mottle kuning/hijau pada daun)
• Disinfeksi alat berkebun dengan larutan bleach 10% setelah digunakan
• Cuci tangan dengan sabun setelah menyentuh tanaman
• Hindari merokok di sekitar tanaman (virus bertahan di tembakau)
• Kendalikan aphid yang menjadi vektor penyebaran
• Gunakan benih bersertifikat bebas virus
• Rotasi dengan tanaman non-Solanaceae
""",
};

// ============================================================================
// REKOMENDASI UMUM (LOW CONFIDENCE < 50%)
// ============================================================================

const Map<String, String> generalRecommendations = {
  "Unknown": """
Objek tidak terdeteksi sebagai tanaman.

Saran:
• Pastikan foto fokus pada daun dengan pencahayaan cukup
• Hindari background yang terlalu ramai
• Posisikan daun di tengah frame
• Coba ambil foto ulang dengan kondisi lebih baik
""",

  "Healthy": """
Tanaman terlihat sehat!

Perawatan Rutin:
• Pertahankan jadwal penyiraman yang konsisten
• Berikan pupuk seimbang secara berkala
• Monitor rutin untuk deteksi dini penyakit
• Jaga kebersihan area tanam

⚠️ Catatan: Tingkat keyakinan rendah. Lakukan pemeriksaan visual secara rutin.
""",

  "Bacterial Infection": """
Kemungkinan Infeksi Bakteri terdeteksi.

Penanganan Umum:
• Isolasi tanaman dari yang sehat
• Buang bagian yang terlihat terinfeksi
• Tingkatkan sirkulasi udara dan kurangi kelembaban
• Hindari penyiraman dari atas (overhead watering)
• Pertimbangkan aplikasi copper fungicide
• Jaga kebersihan alat berkebun

⚠️ Catatan: Tingkat keyakinan di bawah 50%. Konsultasikan dengan ahli pertanian untuk diagnosis yang lebih akurat.
""",

  "Fungal Infection": """
Kemungkinan Infeksi Jamur terdeteksi.

Penanganan Umum:
• Buang daun yang terlihat terinfeksi
• Tingkatkan sirkulasi udara dengan pruning
• Kurangi kelembaban - jangan siram sore/malam
• Aplikasikan fungisida berbasis copper atau chlorothalonil
• Gunakan mulsa untuk mencegah percikan tanah
• Bersihkan debris tanaman secara rutin

⚠️ Catatan: Tingkat keyakinan di bawah 50%. Untuk memastikan jenis jamur spesifik, konsultasikan dengan ahli.
""",

  "Viral Infection": """
Kemungkinan Infeksi Virus terdeteksi.

Penanganan Umum:
• PENTING: Tidak ada obat untuk virus tanaman
• Isolasi tanaman yang dicurigai terinfeksi
• Kendalikan serangga vektor (kutu daun, whitefly) dengan insecticidal soap
• Disinfeksi alat berkebun setelah digunakan
• Pertimbangkan mencabut tanaman jika infeksi parah
• Gunakan benih/bibit bersertifikat untuk penanaman baru

⚠️ Catatan: Tingkat keyakinan di bawah 50%. Segera konsultasikan dengan ahli untuk diagnosis akurat.
""",

  "Pest Damage": """
Kemungkinan Kerusakan Hama terdeteksi.

Penanganan Umum:
• Inspeksi bagian bawah daun untuk melihat hama
• Semprotkan air bertekanan untuk mengurangi populasi kecil
• Gunakan insecticidal soap atau neem oil
• Tingkatkan kelembaban (beberapa hama tidak suka lembab)
• Lepaskan predator alami jika tersedia
• Hindari insektisida broad-spectrum

⚠️ Catatan: Tingkat keyakinan di bawah 50%. Identifikasi hama spesifik untuk penanganan optimal.
""",
};

// ============================================================================
// FUNGSI HELPER
// ============================================================================

/// Mendapatkan detail lengkap untuk hasil diagnosis
Map<String, dynamic> getRecommendation(int classId, double confidence) {
  final fullName = classNames[classId] ?? "Unknown";
  final diseaseName = diseaseNames[classId] ?? "Unknown";
  final category = categoryMapping[classId] ?? "Unknown";
  final color = categoryColors[category] ?? 0xFF9E9E9E;

  String recommendation;

  // Logic: Jika confidence >= 50%, gunakan rekomendasi spesifik
  // Jika confidence < 50%, gunakan rekomendasi umum per kategori
  if (confidence >= 50.0) {
    recommendation = specificRecommendations[classId] ??
        generalRecommendations[category] ??
        "Tidak ada rekomendasi tersedia.";
  } else {
    recommendation = generalRecommendations[category] ??
        "Tidak ada rekomendasi tersedia.";
  }

  return {
    "fullName": fullName, // Nama lengkap dengan tanaman (untuk log/database)
    "diseaseName": diseaseName, // Nama penyakit saja (untuk display)
    "category": category, // Kategori kondisi (untuk card)
    "color": color, // Warna kategori
    "recommendation": recommendation, // Rekomendasi
    "confidence": confidence, // Pass confidence untuk UI
  };
}

// ============================================================================
// SUMBER REFERENSI UNTUK DOKUMENTASI (Untuk Disclaimer Page)
// ============================================================================

const List<Map<String, String>> references = [
  {
    "title": "Bacterial Spot Management",
    "sources": """
• University of Minnesota Extension - Bacterial spot management
  https://extension.umn.edu/disease-management/bacterial-spot-tomato-and-pepper

• West Virginia University Extension - Bacterial Leaf Spot of Pepper
  https://extension.wvu.edu/lawn-gardening-pests/plant-disease/fruit-vegetable-diseases/bacterial-leaf-spot-of-pepper

• MDPI Agriculture (2025) - Sustainable Management of Bacterial Leaf Spot
  https://www.mdpi.com/2077-0472/15/17/1859
"""
  },
  {
    "title": "Early Blight & Late Blight",
    "sources": """
• Bayer Crop Science - Understanding Early Blight in Potatoes
  https://www.cropscience.bayer.us/articles/cp/early-blight-potatoes

• University of Connecticut IPM - Early Blight and Late Blight
  https://ipm.cahnr.uconn.edu/early-blight-and-late-blight-of-potato/

• University of Minnesota Extension - Late Blight Management
  https://extension.umn.edu/disease-management/late-blight
"""
  },
  {
    "title": "Septoria Leaf Spot",
    "sources": """
• NC State Extension - Septoria Leaf Spot of Tomato
  https://content.ces.ncsu.edu/septoria-leaf-spot-of-tomato

• University of Wisconsin Horticulture - Septoria Leaf Spot
  https://hort.extension.wisc.edu/articles/septoria-leaf-spot/
"""
  },
  {
    "title": "Yellow Leaf Curl Virus",
    "sources": """
• NC State Extension - Tomato Yellow Leaf Curl Virus
  https://content.ces.ncsu.edu/tomato-yellow-leaf-curl-virus

• University of Florida IFAS - TYLCV Management
  https://ipm.ifas.ufl.edu/agricultural_ipm/tylcv_home_mgmt.shtml
"""
  },
];