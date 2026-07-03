import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../widgets/image_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../utils/format.dart';

// DATA MODEL KARTU PERBANDINGAN
class CompareCardData {
  final nameController = TextEditingController();
  final discountController = TextEditingController();
  final priceController = TextEditingController();
  String imagePath = '';
  String imageUrl = '';
  String? selectedToko;

  void dispose() {
    nameController.dispose();
    discountController.dispose();
    priceController.dispose();
  }

  void clear() {
    nameController.clear();
    priceController.clear();
    discountController.clear();
    imagePath = '';
    imageUrl = '';
    selectedToko = null;
  }
}

// TAB BANDINGKAN
class BandinginTab extends StatefulWidget {
  const BandinginTab({super.key});

  static String? pendingStoreSelection;

  @override
  State<BandinginTab> createState() => BandinginTabState();
}

final GlobalKey<BandinginTabState> bandinginTabKey =
    GlobalKey<BandinginTabState>();

class BandinginTabState extends State<BandinginTab> {
  final List<CompareCardData> _cards = [CompareCardData(), CompareCardData()];
  List<String> _availableStores = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  void setStoreForFirstCard(String storeName) {
    if (_cards.isNotEmpty) {
      setState(() {
        _cards[0].selectedToko = storeName;
      });
    }
  }

  void _loadStores() {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    FirestoreService.streamToko(uid).listen((snapshot) {
      if (mounted) {
        setState(() {
          _availableStores = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['namaToko'] ?? 'Unknown') as String;
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    for (var card in _cards) {
      card.dispose();
    }
    super.dispose();
  }

  // AKSI KARTU
  void _addCard() {
    if (_cards.length >= 5) {
      _showSnack('Maksimal 5 produk untuk dibandingkan!');
      return;
    }
    setState(() => _cards.add(CompareCardData()));
  }

  void _removeCard(int index) {
    if (_cards.length <= 2) {
      _showSnack('Minimal 2 produk untuk perbandingan!');
      return;
    }
    setState(() {
      _cards[index].dispose();
      _cards.removeAt(index);
    });
  }

  void _resetCard(int index) {
    setState(() => _cards[index].clear());
  }

  void _resetAll() {
    setState(() {
      for (var card in _cards) {
        card.clear();
      }
    });
    _showSnack('Semua kartu telah dibersihkan!');
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: sm),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? btnRed : btnGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
      ),
    );
  }

  // IMAGE PICKER
  void _pickProductImage(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Gambar Produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: primaryBlue,
              ),
              title: const Text('Ambil dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() => _cards[index].imageUrl = image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_outlined, color: primaryBlue),
              title: const Text('Pilih dari Preset'),
              onTap: () {
                Navigator.pop(context);
                _showPresetDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: primaryBlue),
              title: const Text('Masukkan URL Gambar'),
              onTap: () {
                Navigator.pop(context);
                _showCustomUrlDialog(index);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPresetDialog(int index) {
    final presets = [
      {
        'name': 'Sepatu',
        'url': 'assets/images/Preset Produk/Sepatu.jpeg',
      },
      {
        'name': 'Jaket',
        'url': 'assets/images/Preset Produk/Jaket.jpeg',
      },
      {
        'name': 'Jam',
        'url': 'assets/images/Preset Produk/Jam.jpeg',
      },
      {
        'name': 'Celana',
        'url': 'assets/images/Preset Produk/Celana.jpeg',
      },
      {
        'name': 'Tas',
        'url': 'assets/images/Preset Produk/Tas.jpeg',
      },
      {
        'name': 'Sendal',
        'url': 'assets/images/Preset Produk/Sendal.jpeg',
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pilih Preset Gambar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: 180,
          width: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: presets.length,
            itemBuilder: (_, idx) {
              final item = presets[idx];
              return GestureDetector(
                onTap: () {
                  setState(() => _cards[index].imageUrl = item['url']!);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: item['url']!.startsWith('assets/') ? AssetImage(item['url']!) as ImageProvider : NetworkImage(item['url']!),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: _cards[index].imageUrl == item['url']
                          ? primaryBlue
                          : Colors.black12,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCustomUrlDialog(int index) {
    final ctrl = TextEditingController(
      text: _cards[index].imageUrl.startsWith('http')
          ? _cards[index].imageUrl
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'URL Gambar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'URL Gambar',
            hintText: 'https://example.com/produk.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _cards[index].imageUrl = ctrl.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // SIMPAN PRODUK KE FIRESTORE
  Future<void> _saveProductToProfile(int index) async {
    final card = _cards[index];
    final price = double.tryParse(card.priceController.text) ?? 0.0;
    if (price <= 0) {
      _showSnack('Isi harga produk terlebih dahulu!');
      return;
    }

    final uid = AuthService.currentUid;
    if (uid == null) return;

    final name = card.nameController.text.trim().isEmpty
        ? 'Produk ${index + 1}'
        : card.nameController.text.trim();
    double priceVal =
        double.tryParse(
          card.priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    double discVal =
        double.tryParse(
          card.discountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    final finalPrice = priceVal * (1 - (discVal / 100));

    _showSnack('Menyimpan produk...');

    try {
      String imageUrl = card.imageUrl;
      // Upload ke Storage jika gambar dari file lokal
      if (imageUrl.isNotEmpty &&
          !imageUrl.startsWith('http://') &&
          !imageUrl.startsWith('https://')) {
        imageUrl = await StorageService.uploadProductImage(uid, imageUrl);
      }

      await FirestoreService.addProduk(
        uid: uid,
        namaProduk: name,
        namaToko: card.selectedToko ?? 'Tanpa Toko',
        diskon: discVal.toInt(),
        harga: priceVal.toInt(),
        hargaAkhir: finalPrice.toInt(),
        gambarUrl: imageUrl,
      );

      if (!mounted) return;
      _showSnack('Produk "$name" berhasil disimpan ke Profil!');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal menyimpan: $e');
    }
  }

  // LOGIKA PERBANDINGAN
  void _calculateComparison() {
    final validCards = <CompareCardData>[];
    for (var card in _cards) {
      final price =
          double.tryParse(
            card.priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0.0;
      if (price > 0) validCards.add(card);
    }

    if (validCards.length < 2) {
      _showSnack(
        'Masukkan minimal 2 produk untuk dibandingkan.',
        isError: true,
      );
      return;
    }

    List<Map<String, dynamic>> resultsList = [];
    double minPrice = double.infinity;
    double maxPrice = 0;
    CompareCardData? winner;
    String winnerName = '';

    for (var card in validCards) {
      final name = card.nameController.text.trim();
      final priceText = card.priceController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final discountText = card.discountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final originalPrice = double.tryParse(priceText) ?? 0;
      final discount = double.tryParse(discountText) ?? 0;

      final discountAmount = originalPrice * (discount / 100);
      final finalPrice = originalPrice - discountAmount;

      resultsList.add({
        'name': name,
        'originalPrice': originalPrice,
        'discount': discount,
        'finalPrice': finalPrice,
        'imageUrl': card.imageUrl,
      });

      if (finalPrice < minPrice) {
        minPrice = finalPrice;
        winner = card;
        winnerName = name;
      }
      if (finalPrice > maxPrice) {
        maxPrice = finalPrice;
      }
    }

    // Urutkan berdasarkan harga termurah
    resultsList.sort(
      (a, b) =>
          (a['finalPrice'] as double).compareTo(b['finalPrice'] as double),
    );

    double savingsAmount = maxPrice - minPrice;
    double savingsPercent = maxPrice > 0 ? (savingsAmount / maxPrice) * 100 : 0;

    _showResultDialog(
      resultsList: resultsList,
      winner: winner!,
      winnerName: winnerName,
      minPrice: minPrice,
      savingsAmount: savingsAmount,
      savingsPercent: savingsPercent,
    );
  }

  // DIALOG HASIL PERBANDINGAN
  void _showResultDialog({
    required List<Map<String, dynamic>> resultsList,
    required CompareCardData winner,
    required String winnerName,
    required double minPrice,
    required double savingsAmount,
    required double savingsPercent,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header gradien
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1063C4), Color(0xFF0D53A4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Hasil Analisis',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Konten
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Juara Hemat
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE8F6F3), Color(0xFFD1F2EB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: btnGreen, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: btnGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.emoji_events_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'JUARA HEMAT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (savingsAmount > 0)
                                  Text(
                                    'Hemat ${savingsPercent.toStringAsFixed(0)}%!',
                                    style: const TextStyle(
                                      color: btnGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: winner.imageUrl.isNotEmpty
                                        ? buildImageWidget(winner.imageUrl)
                                        : const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: primaryBlue,
                                            size: 30,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        winnerName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatRp(minPrice),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (savingsAmount > 0) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Colors.black12, height: 1),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  text: 'Anda menghemat hingga ',
                                  style: const TextStyle(
                                    color: textDark,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: formatRp(savingsAmount),
                                      style: const TextStyle(
                                        color: btnGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' dibanding produk termahal.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Peringkat Perbandingan:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Ranking list
                      ...resultsList.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final res = entry.value;
                        final isWinner = rank == 1;

                        Color rankBgColor;
                        Color rankTextColor;
                        if (rank == 1) {
                          rankBgColor = const Color(0xFFD4EFDF);
                          rankTextColor = const Color(0xFF196F3D);
                        } else if (rank == 2) {
                          rankBgColor = const Color(0xFFFDEBD0);
                          rankTextColor = const Color(0xFFB9770E);
                        } else {
                          rankBgColor = const Color(0xFFE5E7E9);
                          rankTextColor = const Color(0xFF5D6D7E);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isWinner
                                ? const Color(0xFFF4FBF7)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isWinner
                                  ? btnGreen.withAlpha(128)
                                  : Colors.black12,
                              width: isWinner ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: rankBgColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    color: rankTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (res['imageUrl'] as String).isNotEmpty
                                      ? buildImageWidget(res['imageUrl'])
                                      : const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      res['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isWinner ? btnGreen : textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          formatRp(res['originalPrice']),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        if ((res['discount'] as double) > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFADBD8),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '-${(res['discount'] as double).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  formatRp(res['finalPrice']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isWinner ? btnGreen : textDark,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Bandingkan Produk',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_cards.length} produk · Geser untuk melihat semua',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Kartu-kartu perbandingan
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _cards.asMap().entries.map((entry) {
                final idx = entry.key;
                return Container(
                  width: 210,
                  margin: const EdgeInsets.only(right: 14),
                  child: _buildCompareCard(idx),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _cards.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: primaryBlue.withAlpha(180),
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Tombol aksi
          Row(
            children: [
              // Reset
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: btnRed,
                    side: const BorderSide(color: btnRed),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _resetAll,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tambah Kartu
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _addCard,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: sm),
          // Tombol Bandingkan utama
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: premiumGradient,
              borderRadius: BorderRadius.circular(radiusXl),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withAlpha(76),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(radiusXl),
                onTap: _calculateComparison,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: sm),
                    Text(
                      'Bandingkan Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: lg),
          const _KeyboardBottomSpacer(),
        ],
      ),
    );
  }

  // WIDGET KARTU PERBANDINGAN
  Widget _buildCompareCard(int index) {
    final card = _cards[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header kartu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Produk ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reset kartu
                  InkWell(
                    onTap: () => _resetCard(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFADBD8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (_cards.length > 2) ...[
                    const SizedBox(width: 6),
                    // Hapus kartu
                    InkWell(
                      onTap: () => _removeCard(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Gambar produk
          GestureDetector(
            onTap: () => _pickProductImage(index),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgDashed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: card.imageUrl.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 32,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih Gambar',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildImageWidget(card.imageUrl),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Input fields
          _buildInput('Nama Produk', card.nameController),
          const SizedBox(height: 8),
          _buildInput(
            'Diskon',
            card.discountController,
            isNumber: true,
            isDiscount: true,
          ),
          const SizedBox(height: 8),
          _buildInput(
            'Harga',
            card.priceController,
            isNumber: true,
            isPrice: true,
          ),
          const SizedBox(height: 8),
          // Dropdown Toko Kustom
          GestureDetector(
            onTap: () {
              // Tampilkan bottom sheet untuk memilih toko
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pilih Toko Asal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_availableStores.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Belum ada toko. Tambahkan di Dashboard!',
                              style: TextStyle(color: greyText),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _availableStores.length,
                              itemBuilder: (context, idx) {
                                final store = _availableStores[idx];
                                final isSelected = card.selectedToko == store;
                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryBlue.withAlpha(20)
                                          : bgDashed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.store_outlined,
                                      color: isSelected
                                          ? primaryBlue
                                          : greyText,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    store,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? primaryBlue
                                          : textDark,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: primaryBlue,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() => card.selectedToko = store);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bgDashed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    color: card.selectedToko != null ? primaryBlue : greyText,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      card.selectedToko ?? 'Pilih Toko',
                      style: TextStyle(
                        fontSize: 13,
                        color: card.selectedToko != null ? textDark : greyText,
                        fontWeight: card.selectedToko != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: greyText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tombol simpan
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _saveProductToProfile(index),
              icon: const Icon(Icons.bookmark_add_rounded, size: 16),
              label: const Text(
                'Simpan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDiscount = false,
    bool isPrice = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? (isDiscount
                ? [DiscountInputFormatter()]
                : [CurrencyInputFormatter()])
          : null,
      style: const TextStyle(fontSize: 13, color: textDark),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: greyText),
        filled: true,
        fillColor: bgDashed,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixText: isDiscount ? '%' : (isPrice ? ',00' : null),
        suffixStyle: const TextStyle(
          fontSize: 13,
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KeyboardBottomSpacer extends StatelessWidget {
  const _KeyboardBottomSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox(height: 80 + bottomInset);
  }
}
