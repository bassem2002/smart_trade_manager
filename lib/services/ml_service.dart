import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MLService {
  // OCR
  Future<String> extractText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    try {
      final result = await textRecognizer.processImage(inputImage);
      return result.text;
    } finally {
      textRecognizer.close();
    }
  }

  // QR SCAN
  Future<List<String>> scanQR(File image) async {
    final inputImage = InputImage.fromFile(image);
    final scanner = BarcodeScanner();
    try {
      final result = await scanner.processImage(inputImage);
      return result.map((e) => e.rawValue ?? "").toList();
    } finally {
      scanner.close();
    }
  }

  // LANGUAGE DETECTION
  Future<String> detectLanguage(String text) async {
    final langId = LanguageIdentifier(confidenceThreshold: 0.5);
    try {
      return await langId.identifyLanguage(text);
    } finally {
      langId.close();
    }
  }

  // TRANSLATION
  Future<String> translateText(String text, String targetLangCode) async {
    final sourceLang = await _identifySourceLanguage(text);
    
    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: _mapLang(targetLangCode),
    );

    try {
      return await translator.translateText(text);
    } finally {
      translator.close();
    }
  }

  Future<TranslateLanguage> _identifySourceLanguage(String text) async {
    final langId = LanguageIdentifier(confidenceThreshold: 0.5);
    try {
      final code = await langId.identifyLanguage(text);
      return _mapLang(code);
    } catch (_) {
      return TranslateLanguage.english;
    } finally {
      langId.close();
    }
  }

  TranslateLanguage _mapLang(String lang) {
    switch (lang) {
      case "fr":
        return TranslateLanguage.french;
      case "ar":
        return TranslateLanguage.arabic;
      case "en":
        return TranslateLanguage.english;
      default:
        return TranslateLanguage.english;
    }
  }
}
