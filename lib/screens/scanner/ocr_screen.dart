import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibration/vibration.dart';
import '../../services/ml_service.dart';
import '../../services/settings_service.dart';
import '../../services/audio_service.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final ml = MLService();
  String resultText = "";
  String detectedLang = "";
  String translatedText = "";
  bool isProcessing = false;
  File? _image;
  String targetLang = "fr";

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

  Future<void> _retranslate() async {
    if (resultText.isEmpty) return;
    
    setState(() => isProcessing = true);
    try {
      final translation = await ml.translateText(resultText, targetLang);
      setState(() {
        translatedText = translation;
      });
      await _triggerFeedback();
    } catch (e) {
      setState(() => translatedText = "Translation error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> processImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
      isProcessing = true;
      resultText = "";
      detectedLang = "";
      translatedText = "";
    });

    try {
      final text = await ml.extractText(_image!);
      
      if (text.isNotEmpty) {
        final lang = await ml.detectLanguage(text);
        final translation = await ml.translateText(text, targetLang);

        setState(() {
          resultText = text;
          detectedLang = lang;
          translatedText = translation;
        });
        await _triggerFeedback();
      } else {
        setState(() => resultText = "No text found.");
      }
    } catch (e) {
      setState(() => resultText = "Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Document Scanner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 24),
            if (isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (resultText.isNotEmpty)
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.contain) : null,
      ),
      child: _image == null ? const Icon(Icons.description, size: 50, color: Colors.grey) : null,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => processImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => processImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resultCard("Detected Language", detectedLang.toUpperCase(), Colors.orange),
        const SizedBox(height: 12),
        _resultCard("Original Text (OCR)", resultText, Colors.blue),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Translate to:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: targetLang,
              items: const [
                DropdownMenuItem(value: "fr", child: Text("French")),
                DropdownMenuItem(value: "ar", child: Text("Arabic")),
                DropdownMenuItem(value: "en", child: Text("English")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => targetLang = val);
                  _retranslate();
                }
              },
            ),
          ],
        ),
        _resultCard("Translated Text", translatedText, Colors.green),
      ],
    );
  }

  Widget _resultCard(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          SelectableText(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
