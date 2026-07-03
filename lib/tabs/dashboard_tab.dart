import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/image_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/main_screen.dart';
import 'bandingin_tab.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: sm),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? btnRed : btnGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      margin: const EdgeInsets.all(md),
    ));
  }

  void _addStore() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String? localImagePath;
    bool isUploading = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: cardWhite,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setStateSB) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: md),
                const Text(
                  'Tambah Toko Baru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
                ),
                const SizedBox(height: md),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 14, color: textDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgDashed,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    hintText: 'Nama Toko',
                    hintStyle: const TextStyle(fontSize: 12, color: greyText),
                    prefixIcon: const Icon(Icons.store_outlined, color: greyText, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: urlCtrl,
                        style: const TextStyle(fontSize: 14, color: textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: bgDashed,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          hintText: 'URL Logo (opsional)',
                          hintStyle: const TextStyle(fontSize: 12, color: greyText),
                          prefixIcon: const Icon(Icons.link, color: greyText, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: sm),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: md, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
                      ),
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (picked != null) {
                          setStateSB(() {
                            localImagePath = picked.path;
                            urlCtrl.text = 'Dari Galeri';
                          });
                        }
                      },
                      child: const Icon(Icons.image_search, color: primaryBlue, size: 20),
                    ),
                  ],
                ),
                if (localImagePath != null) ...[
                  const SizedBox(height: sm),
                  Text('Gambar dipilih: ...${localImagePath!.split('/').last}', style: const TextStyle(fontSize: 12, color: primaryBlue)),
                ],
                const SizedBox(height: md),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: premiumGradient,
                    borderRadius: BorderRadius.circular(radiusXl),
                    boxShadow: [
                      BoxShadow(color: primaryBlue.withAlpha(76), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radiusXl),
                      onTap: isUploading ? null : () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final uid = AuthService.currentUid;
                        if (uid == null) return;
                        setStateSB(() => isUploading = true);

                        final existingQuery = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('toko')
                            .get();
                        final newNameLower = nameCtrl.text.trim().toLowerCase();
                        for (var doc in existingQuery.docs) {
                          if ((doc['namaToko'] as String? ?? '').toLowerCase() == newNameLower) {
                            setStateSB(() => isUploading = false);
                            _showSnack('Toko dengan nama tersebut sudah ada!', isError: true);
                            return;
                          }
                        }

                        String finalUrl = urlCtrl.text.trim();
                        if (localImagePath != null) {
                          try {
                            finalUrl = await StorageService.uploadProductImage(uid, localImagePath!);
                          } catch (e) {
                            setStateSB(() => isUploading = false);
                            _showSnack('Gagal upload gambar: $e', isError: true);
                            return;
                          }
                        } else if (finalUrl == 'Dari Galeri') {
                          finalUrl = ''; // fallback
                        }

                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        try {
                          await FirestoreService.addToko(uid, nameCtrl.text.trim(), finalUrl);
                          _showSnack('Toko berhasil ditambahkan!');
                        } catch (e) {
                          _showSnack('Gagal: $e', isError: true);
                        }
                      },
                      child: Center(
                        child: isUploading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
                    ),
                  ),
                const _KeyboardBottomSpacer(),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  void _confirmDeleteStore(String docId, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: btnRed, size: 40),
            const SizedBox(height: md),
            Text(
              'Hapus toko "$name"?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: sm),
            const Text(
              'Toko ini akan dihapus secara permanen.',
              style: TextStyle(fontSize: 13, color: greyText),
            ),
            const SizedBox(height: lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: greyText,
                      side: const BorderSide(color: greyText),
                      padding: const EdgeInsets.symmetric(vertical: md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
                    ),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await FirestoreService.deleteToko(docId);
                      } catch (e) {
                        _showSnack('Gagal menghapus: $e', isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnRed,
                      padding: const EdgeInsets.symmetric(vertical: md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
                    ),
                    child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUid;
    if (uid == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: md),
          // Header sambutan
          StreamBuilder<DocumentSnapshot>(
            stream: FirestoreService.streamUserData(uid),
            builder: (context, snap) {
              final nama = (snap.data?.data() as Map<String, dynamic>?)?['nama'] ?? 'Pengguna';
              return Text(
                'Halo, $nama!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5),
              );
            },
          ),
          const SizedBox(height: xs),
          const Text('Tekan lama untuk menghapus toko', style: TextStyle(fontSize: 12, color: greyText)),
          const SizedBox(height: md),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.streamToko(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: greyText)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: md),
                        const Text('Belum ada toko.', style: TextStyle(color: greyText, fontSize: 15)),
                        const SizedBox(height: xs),
                        const Text('Tambahkan sekarang!', style: TextStyle(color: greyText, fontSize: 13)),
                        const SizedBox(height: lg),
                        _buildAddButton(),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: md,
                    mainAxisSpacing: md,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == docs.length) return _buildAddStoreCard();
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildStoreCard(docs[index].id, data['namaToko'] ?? '', data['logoUrl'] ?? '');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addStore,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: sm),
            Text('Tambah Toko', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(String docId, String name, String logoUrl) {
    return GestureDetector(
      onTap: () {
        bandinginTabKey.currentState?.setStoreForFirstCard(name);
        final mainState = context.findAncestorStateOfType<MainScreenState>();
        mainState?.switchToTab(1);
      },
      onLongPress: () => _confirmDeleteStore(docId, name),
      child: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(radiusMd),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: bgDashed,
              child: logoUrl.isNotEmpty
                  ? ClipOval(child: buildImageWidget(logoUrl, width: 60, height: 60))
                  : Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaryBlue),
                    ),
            ),
            const SizedBox(height: md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: sm),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textDark),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoreCard() {
    return GestureDetector(
      onTap: _addStore,
      child: Container(
        decoration: BoxDecoration(
          color: bgDashed,
          borderRadius: BorderRadius.circular(radiusMd),
          border: Border.all(color: primaryBlue.withAlpha(77), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: primaryBlue, size: 36),
            SizedBox(height: sm),
            Text('Tambah Toko', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: primaryBlue)),
          ],
        ),
      ),
    );
  }
}

class _KeyboardBottomSpacer extends StatelessWidget {
  const _KeyboardBottomSpacer();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SizedBox(height: bottomInset);
  }
}
