import 'package:flutter/material.dart';
import '../../app/config/api_config.dart';
import '../../app/theme/app_colors.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ServerSettingsDialog(),
    );
  }

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _applyPreset(String presetUrl) {
    setState(() {
      _urlController.text = presetUrl;
    });
  }

  Future<void> _save() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      await ApiConfig.setBaseUrl(newUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend URL set to: ${ApiConfig.baseUrl}'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  bool _isDetecting = false;

  Future<void> _autoDetect() async {
    setState(() => _isDetecting = true);
    final detected = await ApiConfig.autoDetect();
    if (mounted) {
      setState(() {
        _isDetecting = false;
        if (detected != null) {
          _urlController.text = detected;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detected != null
              ? 'Found active server: $detected'
              : 'Could not auto-detect server. Please check host server.'),
          backgroundColor: detected != null ? AppColors.primary : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns, color: AppColors.primary),
          SizedBox(width: 10),
          Text('ML Backend Server URL', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the host IP address where your Flask ML server (py -3.12 app.py) is running:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'http://127.0.0.1:5000/api/v1',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDetecting ? null : _autoDetect,
                icon: _isDetecting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.radar, size: 18, color: AppColors.primary),
                label: Text(_isDetecting ? 'Auto-Detecting...' : 'Auto-Detect Active Server'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.laptop, size: 16),
                  label: const Text('ADB / Local (127.0.0.1)'),
                  onPressed: () => _applyPreset(ApiConfig.defaultLocalhostUrl),
                ),
                ActionChip(
                  avatar: const Icon(Icons.lan, size: 16),
                  label: const Text('Ethernet (10.83.121.162)'),
                  onPressed: () => _applyPreset(ApiConfig.defaultEthernetUrl),
                ),
                ActionChip(
                  avatar: const Icon(Icons.wifi, size: 16),
                  label: const Text('Wi-Fi (10.185.229.196)'),
                  onPressed: () => _applyPreset(ApiConfig.defaultWifiUrl),
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Emulator (10.0.2.2)'),
                  onPressed: () => _applyPreset(ApiConfig.defaultEmulatorUrl),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _save,
          child: const Text('Save & Connect'),
        ),
      ],
    );
  }
}
