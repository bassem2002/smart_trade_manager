import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/firebase_database.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final db = FirebaseDatabaseService();
  bool isSaving = false;

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
    
    setState(() => isSaving = true);
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await db.addProduct(id, {
        "name": nameController.text,
        "price": priceController.text,
        "stock": stockController.text,
      });

      if (mounted) {
        nameController.clear();
        priceController.clear();
        stockController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
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
              const Text("Add New Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name", prefixIcon: Icon(Icons.shopping_bag))),
              const SizedBox(height: 12),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock Quantity", prefixIcon: Icon(Icons.inventory)), keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : _addProduct,
                child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Product"),
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
      appBar: AppBar(title: const Text("Products Management")),
      body: StreamBuilder(
        stream: db.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Connection Error: Check your Firebase Database URL\n\n${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No products found. Tap + to add."));
          }

          final children = snapshot.data!.snapshot.children.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final DataSnapshot productSnapshot = children[index];
              final item = productSnapshot.value as Map<dynamic, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.inventory_2, color: Colors.white)),
                  title: Text(item['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Stock: ${item['stock'] ?? 0}"),
                  trailing: Text("${item['price'] ?? 0} \$", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
