const Map<int, String> classMapping = {
  0: "Healthy",
  1: "Penyakit ringan",
  2: "Penyakit menular",
  3: "Penyakit berat",
};

const Map<String, String> recommendationRules = {
  "Healthy": "Tanaman dalam kondisi normal",
  "Penyakit ringan": "Pantau dan lakukan isolasi ringan",
  "Penyakit menular": "Pisahkan dari tanaman lain",
  "Penyakit berat": "Disarankan konsultasi dengan ahli",
};

Map<String, String> getRecommendation(int classId) {
  final label = classMapping[classId] ?? "Unknown";
  final action = recommendationRules[label] ?? "Tidak ada rekomendasi";

  return {"label": label, "recommendation": action};
}
