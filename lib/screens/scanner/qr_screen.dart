import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';
import '../../services/ml_service.dart';
import '../../services/settings_service.dart';
import '../../services/audio_service.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final ml = MLService();
  List<String> results = [];
  bool isScanning = false;
  File? _image;

  Future<void> _triggerFeedback() async {
    // 1. Vibration
    if (await SettingsService.getVibration()) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
    }
    // 2. Sound
    await AudioService.playSuccessSound();
  }

  Future<void> scanImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
      isScanning = true;
      results = [];
    });

    try {
      final data = await ml.scanQR(_image!);
      setState(() {
        results = data;
      });
      if (data.isNotEmpty) {
        await _triggerFeedback();
      }
    } catch (e) {
      debugPrint("QR Error: $e");
    } finally {
      setState(() => isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR & Barcode Scanner")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.contain) : null,
              ),
              child: _image == null ? const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey) : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => scanImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => scanImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Scan Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : results.isEmpty
                      ? const Center(child: Text("No QR codes or barcodes found.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.link, color: Colors.indigo),
                                title: SelectableText(results[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    // Implementation for copy to clipboard
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
