import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/translation_data.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_card.dart';
import '../products/products_screen.dart';
import '../suppliers/suppliers_screen.dart';
import '../shipments/shipments_screen.dart';
import '../scanner/ocr_screen.dart';
import '../scanner/qr_screen.dart';
import '../../main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void logout(BuildContext context) async {
    await AuthService().logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? null : Colors.grey[50],
          appBar: AppBar(
            title: Text(
              TranslationData.translate('app_title', lang),
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => logout(context),
              )
            ],
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationData.translate('welcome', lang),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blue[200] : const Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    TranslationData.translate('subtitle', lang),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    TranslationData.translate('management', lang),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _MiniCard(
                        icon: Icons.inventory_2_rounded,
                        title: TranslationData.translate('products', lang),
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
                      ),
                      _MiniCard(
                        icon: Icons.people_alt_rounded,
                        title: TranslationData.translate('suppliers', lang),
                        color: Colors.teal,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen())),
                      ),
                      _MiniCard(
                        icon: Icons.local_shipping_rounded,
                        title: TranslationData.translate('shipments', lang),
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentsScreen())),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    TranslationData.translate('smart_scan', lang),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          icon: Icons.document_scanner_rounded,
                          title: TranslationData.translate('ocr', lang),
                          color: Colors.indigo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OCRScreen())),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          icon: Icons.qr_code_scanner_rounded,
                          title: TranslationData.translate('qr', lang),
                          color: Colors.purple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScreen())),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildAboutSection(lang, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(String lang, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
              const SizedBox(width: 8),
              Text(
                TranslationData.translate('about', lang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            TranslationData.translate('about_desc', lang),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Divider(),
          Text(
            TranslationData.translate('version', lang),
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MiniCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
