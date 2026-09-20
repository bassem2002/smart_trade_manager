import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/firebase_database.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final trackingController = TextEditingController();
  final destinationController = TextEditingController();
  String status = "Pending";
  final db = FirebaseDatabaseService();
  bool isSaving = false;

  Future<void> _addShipment() async {
    if (trackingController.text.isEmpty) return;
    
    setState(() => isSaving = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await db.addShipment(id, {
        "tracking": trackingController.text,
        "destination": destinationController.text,
        "status": status,
        "date": DateTime.now().toString().split(' ')[0],
      });

      if (mounted) {
        trackingController.clear();
        destinationController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shipment tracked successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("New Shipment Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: trackingController, decoration: const InputDecoration(labelText: "Tracking ID / QR Data", prefixIcon: Icon(Icons.qr_code))),
              const SizedBox(height: 12),
              TextField(controller: destinationController, decoration: const InputDecoration(labelText: "Destination", prefixIcon: Icon(Icons.location_on))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: "Current Status", prefixIcon: Icon(Icons.info)),
                items: ["Pending", "In Transit", "Delivered"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => status = val);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : _addShipment,
                child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Create Tracker"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logistics Tracker")),
      body: StreamBuilder(
        stream: db.getShipments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Connection Error: Check your Database URL\n\n${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No active shipments. Tap + to track."));
          }

          final children = snapshot.data!.snapshot.children.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final DataSnapshot shipmentSnapshot = children[index];
              final item = shipmentSnapshot.value as Map<dynamic, dynamic>;
              Color statusColor = item['status'] == 'Delivered' ? Colors.green : Colors.orange;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: statusColor.withOpacity(0.2), child: Icon(Icons.local_shipping, color: statusColor)),
                  title: Text(item['tracking'] ?? 'Unknown ID', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("To: ${item['destination'] ?? 'N/A'} • ${item['date']}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(item['status'] ?? 'Pending', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
