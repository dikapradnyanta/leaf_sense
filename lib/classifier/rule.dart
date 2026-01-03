const Map<int, String> classMapping = {
  -1: "Tidak Dikenali",
  0: "Healthy",
  1: "Penyakit ringan",
  2: "Penyakit menular",
  3: "Penyakit berat",
};

const Map<String, String> recommendationRules = {
  "Tidak Dikenali":
  "Objek tidak terdeteksi sebagai tanaman. Pastikan foto fokus pada daun dengan pencahayaan cukup.",
  "Healthy":
  "🌟 Tanaman Sehat!\n\n"
      "• Pertahankan jadwal penyiraman.\n"
      "• Pastikan sirkulasi udara baik.\n"
      "• Berikan pupuk organik secara berkala untuk menjaga nutrisi.",

  "Penyakit ringan":
  "⚠️ Gejala Awal Terdeteksi\n\n"
      "• Isolasi tanaman agar tidak menyebar.\n"
      "• Bersihkan bagian daun yang terkena dengan lap basah/alkohol 70%.\n"
      "• Kurangi kelembapan di sekitar tanaman.",

  "Penyakit menular":
  "🚫 Bahaya Penularan Tinggi\n\n"
      "• Pindahkan tanaman jauh dari tanaman lain (karantina).\n"
      "• Pangkas daun yang terinfeksi dan bakar/buang jauh.\n"
      "• Semprotkan fungisida alami atau kimia sesuai dosis.",

  "Penyakit berat":
  "🆘 Kondisi Kritis\n\n"
      "• Kerusakan sudah meluas, segera konsultasi dengan ahli tani.\n"
      "• Pertimbangkan untuk mengganti media tanam.\n"
      "• Jika tidak tertolong, musnahkan tanaman agar tidak menjadi sarang hama.",
};

Map<String, String> getRecommendation(int classId) {
  final label = classMapping[classId] ?? "Tidak Dikenali";
  final action = recommendationRules[label] ?? "Tidak ada rekomendasi";

  return {"label": label, "recommendation": action};
}