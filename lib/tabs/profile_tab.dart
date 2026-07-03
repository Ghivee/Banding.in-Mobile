import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/format.dart';
import '../constants/colors.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../widgets/image_helper.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: sm),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? btnRed : btnGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      margin: const EdgeInsets.all(md),
    ));
  }
// LOGOUT
void _showLogoutDialog() {
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
            const Icon(Icons.logout, color: btnRed, size: 40),
            const SizedBox(height: md),
            const Text('Keluar dari akun?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
            const SizedBox(height: sm),
            const Text('Anda perlu login kembali untuk mengakses data.',
                style: TextStyle(fontSize: 13, color: greyText), textAlign: TextAlign.center),
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
                      await AuthService.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnRed,
                      padding: const EdgeInsets.symmetric(vertical: md),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
                    ),
                    child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
// GANTI FOTO PROFIL
void _changePhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: sm),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: md),
            const Text('Ubah Foto Profil',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textDark)),
            const SizedBox(height: md),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: primaryBlue),
              title: const Text('Ambil dari Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image == null) return;
                final uid = AuthService.currentUid;
                if (uid == null) return;
                try {
                  _showSnack('Mengunggah foto...');
                  final url = await StorageService.uploadProfilePhoto(uid, image.path);
                  await FirestoreService.updateUserPhoto(uid, url);
                  _showSnack('Foto profil diperbarui!');
                } catch (e) {
                  _showSnack('Gagal mengunggah: $e', isError: true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: primaryBlue),
              title: const Text('Pilih Avatar'),
              onTap: () {
                Navigator.pop(ctx);
                _showAvatarDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link, color: primaryBlue),
              title: const Text('Masukkan URL'),
              onTap: () {
                Navigator.pop(ctx);
                _showUrlDialog();
              },
            ),
            const SizedBox(height: sm),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
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
            const Text(
              'Hapus produk ini?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: sm),
            const Text(
              'Produk ini akan dihapus secara permanen dari daftar tersimpan.',
              style: TextStyle(fontSize: 13, color: greyText),
              textAlign: TextAlign.center,
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
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteProduct(docId);
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

  void _showAvatarDialog() {
    final presets = [
      'assets/images/Preset Profil/Profil1.jpeg',
      'assets/images/Preset Profil/Profil2.jpeg',
      'assets/images/Preset Profil/Profil3.jpeg',
      'assets/images/Preset Profil/Profil4.jpeg',
    ];
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
            const Text('Pilih Avatar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textDark)),
            const SizedBox(height: md),
            Wrap(
              spacing: md,
              runSpacing: md,
              alignment: WrapAlignment.center,
              children: presets.map((url) => GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  final uid = AuthService.currentUid;
                  if (uid == null) return;
                  try {
                    await FirestoreService.updateUserPhoto(uid, url);
                  } catch (e) {
                    _showSnack('Gagal: $e', isError: true);
                  }
                },
                child: CircleAvatar(radius: 32, backgroundImage: url.startsWith('assets/') ? AssetImage(url) as ImageProvider : NetworkImage(url)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: lg, right: lg, top: lg, bottom: MediaQuery.of(ctx).viewInsets.bottom + lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('URL Foto Profil', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: textDark)),
            const SizedBox(height: md),
            TextField(
              controller: ctrl,
              style: const TextStyle(fontSize: 13, color: textDark),
              decoration: InputDecoration(
                filled: true, fillColor: bgDashed,
                hintText: 'https://example.com/foto.jpg',
                hintStyle: const TextStyle(color: greyText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: md),
            Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(color: btnGreen, borderRadius: BorderRadius.circular(radiusXl)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(radiusXl),
                  onTap: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final uid = AuthService.currentUid;
                    if (uid == null) return;
                    try {
                      await FirestoreService.updateUserPhoto(uid, ctrl.text.trim());
                    } catch (e) {
                      _showSnack('Gagal: $e', isError: true);
                    }
                  },
                  child: const Center(child: Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String docId) async {
    try {
      await FirestoreService.deleteProduk(docId);
      _showSnack('Produk dihapus.');
    } catch (e) {
      _showSnack('Gagal menghapus: $e', isError: true);
    }
  }
// BUILD UI
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
          // Header profil — data dari Firestore
          StreamBuilder<DocumentSnapshot>(
            stream: FirestoreService.streamUserData(uid),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final nama = data?['nama'] ?? 'Pengguna';
              final email = data?['email'] ?? AuthService.currentUser?.email ?? '-';
              final fotoUrl = data?['fotoProfilUrl'] ?? '';

              return Container(
                padding: const EdgeInsets.all(md),
                decoration: BoxDecoration(
                  color: cardWhite,
                  borderRadius: BorderRadius.circular(radiusLg),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _changePhoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: bgDashed,
                            backgroundImage: fotoUrl.isNotEmpty ? (fotoUrl.startsWith('assets/') ? AssetImage(fotoUrl) as ImageProvider : NetworkImage(fotoUrl)) : null,
                            child: fotoUrl.isEmpty ? const Icon(Icons.person, size: 35, color: primaryBlue) : null,
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark)),
                          const SizedBox(height: xs),
                          Text(email, style: const TextStyle(color: greyText, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: btnRed),
                      onPressed: _showLogoutDialog,
                      tooltip: 'Keluar',
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: lg),
          const Text('Produk Tersimpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark)),
          const SizedBox(height: md),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.streamProdukTersimpan(uid),
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
                        Icon(Icons.bookmark_border, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: md),
                        const Text('Belum ada produk tersimpan.', style: TextStyle(color: greyText, fontSize: 15)),
                        const SizedBox(height: xs),
                        const Text('Mulai bandingkan!', style: TextStyle(color: greyText, fontSize: 13)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: md, mainAxisSpacing: md, childAspectRatio: 0.52,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildSavedCard(docs[index].id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(String docId, Map<String, dynamic> data) {
    final nama = data['namaProduk'] ?? 'Produk';
    final toko = data['namaToko'] ?? '';
    final diskon = (data['diskon'] ?? 0).toInt();
    final harga = (data['harga'] ?? 0).toInt();
    final hargaAkhir = (data['hargaAkhir'] ?? 0).toInt();
    final gambarUrl = data['gambarUrl'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar — aspect ratio 1:1
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(radiusMd)),
            child: AspectRatio(
              aspectRatio: 1,
              child: gambarUrl.isNotEmpty
                  ? buildImageWidget(gambarUrl)
                  : Container(color: bgDashed, child: const Icon(Icons.shopping_bag_outlined, color: primaryBlue, size: 30)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (toko.isNotEmpty)
                    Text(toko, style: const TextStyle(color: greyText, fontSize: 11)),
                  const SizedBox(height: xs),
                  Text(nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: xs),
                  if (diskon > 0)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(formatRp(harga), style: const TextStyle(decoration: TextDecoration.lineThrough, color: greyText, fontSize: 10)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: xs, vertical: 1),
                          decoration: BoxDecoration(color: btnRed.withAlpha(25), borderRadius: BorderRadius.circular(xs)),
                          child: Text('-$diskon%', style: const TextStyle(color: btnRed, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  Text(formatRp(hargaAkhir), style: const TextStyle(color: primaryBlue, fontSize: 15, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: btnRed,
                        side: const BorderSide(color: btnRed),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _confirmDelete(docId),
                      child: const Text('Hapus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
