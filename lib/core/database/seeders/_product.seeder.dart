import 'package:sqflite/sqflite.dart';
import '../scripts/product_table.dart';
import '../scripts/product_image_table.dart';

class ProductSeeder {
  static Future<void> seed(Database db) async {
    final List<Map<String, dynamic>> products = [
      // --- MAKANAN (Category 1) ---
      {
        'id': 1,
        'category_id': 1,
        'name': 'Nasi Goreng Special',
        'price': 25000.0,
        'stock': 15,
        'description': 'Nasi goreng dengan telur mata sapi dan ayam suwir.',
        'images': [
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500',
        ],
      },
      {
        'id': 2,
        'category_id': 1,
        'name': 'Ayam Geprek Biasa',
        'price': 15000.0,
        'stock': 24,
        'description':
            'Ayam goreng tepung digeprek dengan sambal korek level sedang.',
        'images': [
          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500',
        ],
      },
      {
        'id': 3, // OUT OF STOCK 1
        'category_id': 1,
        'name': 'Ayam Geprek Jumbo',
        'price': 22000.0,
        'stock': 0,
        'description':
            'Potongan ayam lebih besar dengan ekstra sambal dan nasi.',
        'images': [
          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500',
        ],
      },
      {
        'id': 4,
        'category_id': 1,
        'name': 'Ayam Geprek Keju',
        'price': 20000.0,
        'stock': 12,
        'description': 'Ayam geprek dengan topping lelehan keju mozarella.',
        'images': [
          'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500',
        ],
      },
      {
        'id': 5,
        'category_id': 1,
        'name': 'Mie Goreng Jawa',
        'price': 18000.0,
        'stock': 30,
        'description': 'Mie kuning masak bumbu tradisional dengan sayuran.',
        'images': [
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500',
        ],
      },
      {
        'id': 6, // OUT OF STOCK 2
        'category_id': 1,
        'name': 'Sate Ayam (10 Tusuk)',
        'price': 28000.0,
        'stock': 0,
        'description': 'Sate ayam bumbu kacang khas Madura.',
        'images': [
          'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=500',
        ],
      },
      {
        'id': 7,
        'category_id': 1,
        'name': 'Bakso Sapi Solo',
        'price': 20000.0,
        'stock': 8,
        'description': 'Bakso urat asli dengan kuah kaldu bening yang segar.',
        'images': [
          'https://images.unsplash.com/photo-1593001410780-010c2744241d?w=500',
        ],
      },

      // --- MINUMAN (Category 2) ---
      {
        'id': 8,
        'category_id': 2,
        'name': 'Es Teh Manis',
        'price': 5000.0,
        'stock': 50,
        'description': 'Teh manis dingin segar.',
        'images': [
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500',
        ],
      },
      {
        'id': 9, // OUT OF STOCK 3
        'category_id': 2,
        'name': 'Es Jeruk Peras',
        'price': 7000.0,
        'stock': 0,
        'description': 'Jeruk peras asli dengan gula murni.',
        'images': [
          'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=500',
        ],
      },
      {
        'id': 10,
        'category_id': 2,
        'name': 'Kopi Susu Gula Aren',
        'price': 15000.0,
        'stock': 20,
        'description': 'Espresso dengan susu segar and gula aren cair.',
        'images': [
          'https://images.unsplash.com/photo-1553909489-eb2175c4078a?w=500',
        ],
      },
      {
        'id': 11, // OUT OF STOCK 4
        'category_id': 2,
        'name': 'Jus Alpukat',
        'price': 12000.0,
        'stock': 0,
        'description': 'Jus alpukat kental dengan topping coklat.',
        'images': [
          'https://images.unsplash.com/photo-1589135304605-6147683649d8?w=500',
        ],
      },
      {
        'id': 12,
        'category_id': 2,
        'name': 'Es Campur',
        'price': 15000.0,
        'stock': 15,
        'description': 'Berbagai macam buah dan jelly dengan sirup merah.',
        'images': [
          'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=500',
        ],
      },
      {
        'id': 13,
        'category_id': 2,
        'name': 'Lemon Tea Hot',
        'price': 8000.0,
        'stock': 22,
        'description': 'Teh lemon hangat untuk meredakan tenggorokan.',
        'images': [
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500',
        ],
      },
      {
        'id': 14, // OUT OF STOCK 5
        'category_id': 2,
        'name': 'Air Mineral 600ml',
        'price': 4000.0,
        'stock': 0,
        'description': 'Air mineral kemasan botol dingin.',
        'images': [
          'https://images.unsplash.com/photo-1523362628744-0c14a39f9f8b?w=500',
        ],
      },
    ];

    for (var p in products) {
      await db.insert(ProductTable.tableName, {
        'id': p['id'],
        'category_id': p['category_id'],
        'name': p['name'],
        'price': p['price'],
        'stock': p['stock'], // Added stock column
        'description': p['description'],
      });

      for (var i = 0; i < p['images'].length; i++) {
        await db.insert(ProductImageTable.tableName, {
          'product_id': p['id'],
          'path': p['images'][i],
          'is_thumbnail': i == 0 ? 1 : 0,
        });
      }
    }
  }
}
