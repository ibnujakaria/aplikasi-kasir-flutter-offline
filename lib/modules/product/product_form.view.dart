import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'models/product.model.dart';
import 'models/product_image.model.dart';
import 'product.service.dart';

class ProductFormView extends StatefulWidget {
  final Product? product;
  const ProductFormView({super.key, this.product});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  late TextEditingController _urlController;

  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<ProductImage> _images = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers if editing, otherwise empty
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price != null
          ? widget.product!.price.toInt().toString()
          : '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock != null
          ? widget.product!.stock.toString()
          : '0',
    );
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _urlController = TextEditingController();

    _selectedCategoryId = widget.product?.categoryId;
    _images = List.from(widget.product?.images ?? []);
    _loadCategories();
  }

  void _loadCategories() async {
    final cats = await _service.getCategories();
    setState(() => _categories = cats);
  }

  // ... inside class ...

  Future<void> _pickLocalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final File pickedFile = File(result.files.single.path!);

      // Get App Document Directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();

      // Create a dedicated directory for products if not exists
      final Directory productDir = Directory(
        '${appDocDir.path}/product_images',
      );
      if (!await productDir.exists()) {
        await productDir.create(recursive: true);
      }

      // Generate unique name
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(pickedFile.path)}';
      final String savedPath = '${productDir.path}/$fileName';

      // Copy File
      await pickedFile.copy(savedPath);

      setState(() {
        _images.add(
          ProductImage(
            productId: widget.product?.id ?? 0,
            path: savedPath, // Use persistence path
            isThumbnail: _images.isEmpty,
          ),
        );
      });
    }
  }

  void _addUrlImage() {
    if (_urlController.text.isNotEmpty) {
      setState(() {
        _images.add(
          ProductImage(
            productId: widget.product?.id ?? 0,
            path: _urlController.text,
            isThumbnail: _images.isEmpty,
          ),
        );
        _urlController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. CATEGORY DROPDOWN
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat['id'] as int,
                      child: Text(cat['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              validator: (val) => val == null ? 'Pilih satu kategori' : null,
            ),
            const SizedBox(height: 16),

            // 2. PRODUCT NAME
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
                hintText: 'Contoh: Ayam Geprek Sambal Ijo',
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // PRICE FIELD
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Wajib' : null,
                  ),
                ),
                const SizedBox(width: 12),
                // STOCK FIELD (NEW)
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Wajib' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. DESCRIPTION
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Produk',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const Divider(height: 40, thickness: 2),
            const Text(
              "Manajemen Gambar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // 5. IMAGE ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickLocalFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text("Pilih File"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUrlDialog(),
                    icon: const Icon(Icons.link),
                    label: const Text("Input URL"),
                  ),
                ),
              ],
            ),

            // 6. IMAGE PREVIEW LIST
            const SizedBox(height: 16),
            ..._images.asMap().entries.map((entry) {
              int idx = entry.key;
              ProductImage img = entry.value;
              return Card(
                color: img.isThumbnail ? Colors.orange.shade50 : null,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: img.path.startsWith('http')
                        ? Image.network(
                            img.path,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(img.path),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/placeholder.png', // Fallback or handle asset if actually asset
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.broken_image),
                              );
                            },
                          ),
                  ),
                  title: Text(
                    img.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    img.isThumbnail ? "⭐ Thumbnail Utama" : "Gambar Tambahan",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _images.removeAt(idx)),
                  ),
                  onTap: () {
                    setState(() {
                      for (var i in _images) {
                        i.isThumbnail = false;
                      }
                      _images[idx].isThumbnail = true;
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: 32),

            // 7. SAVE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(55),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Step 1: Save the Product (Text data)
                  int pId = await _service.saveProduct(
                    Product(
                      id: widget.product?.id,
                      categoryId: _selectedCategoryId,
                      name: _nameController.text,
                      price: double.parse(_priceController.text),
                      stock: int.parse(_stockController.text),
                      description: _descController.text,
                    ),
                  );

                  // Step 2: Save the Image list linked to the ID
                  // (Using widget.product?.id for Edit, pId for New)
                  await _service.saveProductImages(
                    widget.product?.id ?? pId,
                    _images,
                  );

                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Simpan Produk'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("URL Gambar"),
        content: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: "https://example.com/image.jpg",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              _addUrlImage();
              Navigator.pop(c);
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }
}
