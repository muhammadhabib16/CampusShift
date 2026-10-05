import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/social_grant.dart';
import '../viewmodels/social_grant_viewmodel.dart';
import 'ajukan_klaim_screen.dart';

/// Layar "katalog-hibah" — FR-21 (telusuri katalog hibah aktif).
///
/// Catatan arsitektur: NavigationBar bawah (Beranda/Katalog/Barter/Profil)
/// yang muncul di semua frame Figma adalah chrome level APLIKASI (dipasang
/// sekali di shell/root, mis. lewat IndexedStack di main.dart), bukan
/// diulang di tiap screen modul — jadi sengaja tidak di-hardcode di sini.
class KatalogHibahScreen extends StatefulWidget {
  const KatalogHibahScreen({super.key, required this.currentUserNim});

  /// Dioper dari luar modul (hasil AuthViewModel milik Modul Pendukung),
  /// bukan diimpor langsung — menjaga low coupling antar modul.
  final String currentUserNim;

  @override
  State<KatalogHibahScreen> createState() => _KatalogHibahScreenState();
}

class _KatalogHibahScreenState extends State<KatalogHibahScreen> {
  static const _categories = ['Semua', 'Buku', 'Elektronik', 'Furnitur', 'Alat Kuliah'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialGrantViewModel>().loadGrants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SocialGrantViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Katalog Hibah',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadGrants(category: vm.selectedCategory),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HeroBanner()),
            SliverToBoxAdapter(child: _CategoryChips(categories: _categories)),
            if (vm.isLoading)
              const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
            else if (vm.errorMessage != null)
              SliverFillRemaining(child: Center(child: Text(vm.errorMessage!)))
            else if (vm.grants.isEmpty)
              const SliverFillRemaining(
                  child: Center(child: Text('Belum ada hibah di kategori ini.')))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _GrantCard(
                      grant: vm.grants[i],
                      currentUserNim: widget.currentUserNim,
                    ),
                    childCount: vm.grants.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0B7A70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Berbagi untuk Sesama Mahasiswa',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Dukung sirkularitas & keberlanjutan kampus demi mewujudkan tujuan global SDG 12.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
    // Catatan: ilustrasi kampus di background mockup Figma tidak ada asetnya
    // di sini, jadi dipakai gradient teal polos. Tinggal tambah
    // DecorationImage kalau asetnya sudah diekspor dari Figma.
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SocialGrantViewModel>();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = categories[i];
          final value = label == 'Semua' ? null : label;
          final selected = vm.selectedCategory == value;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => context.read<SocialGrantViewModel>().setCategory(value),
            selectedColor: const Color(0xFF0D9488),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            shape: StadiumBorder(
                side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade300)),
          );
        },
      ),
    );
  }
}

class _GrantCard extends StatelessWidget {
  const _GrantCard({required this.grant, required this.currentUserNim});
  final SocialGrant grant;
  final String currentUserNim;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AjukanKlaimScreen(grant: grant, currentUserNim: currentUserNim),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: grant.photoUrl.isEmpty
                  ? Container(color: Colors.grey.shade200)
                  : Image.network(grant.photoUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grant.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Donatur: ${grant.donorName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F5F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('GRATIS',
                            style: TextStyle(
                                color: Color(0xFF0D9488),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text(grant.academicCategory,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
