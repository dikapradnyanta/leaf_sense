import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State dummy (simulasi)
  bool _isDarkMode = false;
  bool _enableVibration = true;
  bool _saveHistory = true;
  bool _highQuality = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian 1: Tampilan
              _buildSectionHeader("Tampilan"),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                color: Colors.purple,
                title: "Mode Gelap",
                subtitle: "Gunakan tema gelap untuk kenyamanan mata",
                value: _isDarkMode,
                onChanged: (val) {
                  setState(() => _isDarkMode = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur tema akan segera hadir!")),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Bagian 2: Preferensi Pemindaian
              _buildSectionHeader("Pemindaian AI"),
              _buildSwitchTile(
                icon: Icons.vibration,
                color: Colors.orange,
                title: "Getaran Haptic",
                subtitle: "Getar saat scan berhasil",
                value: _enableVibration,
                onChanged: (val) => setState(() => _enableVibration = val),
              ),
              _buildSwitchTile(
                icon: Icons.history,
                color: Colors.blue,
                title: "Simpan Riwayat",
                subtitle: "Simpan hasil diagnosis secara lokal",
                value: _saveHistory,
                onChanged: (val) => setState(() => _saveHistory = val),
              ),
              _buildSwitchTile(
                icon: Icons.hd_outlined,
                color: Colors.green,
                title: "Kualitas Tinggi",
                subtitle: "Gunakan resolusi maksimal (lebih lambat)",
                value: _highQuality,
                onChanged: (val) => setState(() => _highQuality = val),
              ),

              const SizedBox(height: 24),

              // Bagian 3: Tentang
              _buildSectionHeader("Tentang Aplikasi"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // FIX: boxShadow ada di dalam BoxDecoration
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05), // FIX: withValues
                      spreadRadius: 1,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline, color: Colors.grey),
                      ),
                      title: const Text("Versi Aplikasi"),
                      trailing: const Text(
                        "v1.0.0",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                      ),
                      title: const Text("Kebijakan Privasi"),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  "Leaf Sense © 2024",
                  style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5), // FIX: withValues
                      fontSize: 12
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // FIX: boxShadow ada di dalam BoxDecoration
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05), // FIX: withValues
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), // FIX: withValues
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: value,
        activeColor: const Color(0xFF4CAF50),
        onChanged: onChanged,
      ),
    );
  }
}