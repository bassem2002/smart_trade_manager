import 'package:flutter/material.dart';
import '../../services/ml_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final text = TextEditingController();
  final ml = MLService();

  String result = "";

  void translate(String lang) async {
    final res = await ml.translateText(text.text, lang);

    setState(() {
      result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Translate")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: text,
              decoration: const InputDecoration(labelText: "Enter text"),
            ),

            Row(
              children: [

                ElevatedButton(
                  onPressed: () => translate("fr"),
                  child: const Text("FR"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () => translate("ar"),
                  child: const Text("AR"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () => translate("en"),
                  child: const Text("EN"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(result),
          ],
        ),
      ),
    );
  }
}