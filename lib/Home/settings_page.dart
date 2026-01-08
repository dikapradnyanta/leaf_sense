import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../Home/disclaimer_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State dari SharedPreferences
  bool _enableHaptic = true;
  bool _saveHistory = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final haptic = await SettingsService.instance.getHapticFeedback();
    final history = await SettingsService.instance.getSaveHistory();

    if (mounted) {
      setState(() {
        _enableHaptic = haptic;
        _saveHistory = history;
      });
    }
  }

  Future<void> _updateHaptic(bool value) async {
    await SettingsService.instance.setHapticFeedback(value);
    setState(() => _enableHaptic = value);
  }

  Future<void> _updateSaveHistory(bool value) async {
    await SettingsService.instance.setSaveHistory(value);
    setState(() => _saveHistory = value);
  }

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
                value: false,
                onChanged: (val) {
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
                title: "Getaran Feedback",
                subtitle: "Getaran saat diagnosis berhasil",
                value: _enableHaptic,
                onChanged: _updateHaptic,
              ),
              _buildSwitchTile(
                icon: Icons.history,
                color: Colors.blue,
                title: "Simpan Riwayat Otomatis",
                subtitle: "Simpan hasil diagnosis secara lokal",
                value: _saveHistory,
                onChanged: _updateSaveHistory,
              ),
              _buildSwitchTile(
                icon: Icons.hd_outlined,
                color: Colors.green,
                title: "Kualitas Tinggi",
                subtitle: "Gunakan resolusi maksimal (lebih lambat)",
                value: false,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur akan segera hadir!")),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Bagian 3: Informasi
              _buildSectionHeader("Informasi"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
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
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      ),
                      title: const Text("Disclaimer & Sumber"),
                      subtitle: const Text("Keterbatasan AI & referensi ilmiah"),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DisclaimerPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  "Leaf Sense © 2024",
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.5),
                    fontSize: 12,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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