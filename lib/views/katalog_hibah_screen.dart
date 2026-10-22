import 'package:flutter/material.dart';
import '../models/social_grant.dart';
import '../viewmodels/grant_claim_viewmodel.dart';
import '../viewmodels/social_grant_viewmodel.dart';
import 'ajukan_klaim_screen.dart';
import 'daftar_detail_klaim_screen.dart';

class KatalogHibahScreen extends StatefulWidget {
  const KatalogHibahScreen({super.key});

  @override
  State<KatalogHibahScreen> createState() => _KatalogHibahScreenState();
}

class _KatalogHibahScreenState extends State<KatalogHibahScreen> {
  final SocialGrantViewModel _grantVm = SocialGrantViewModel();
  final GrantClaimViewModel _claimVm = GrantClaimViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _grantVm.addListener(_onChanged);
    _claimVm.addListener(_onChanged);
    _grantVm.loadGrants();
    _claimVm.syncClaims();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _grantVm.removeListener(_onChanged);
    _claimVm.removeListener(_onChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Hibah Unand'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Klaim Saya & Antrean Donatur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarDetailKlaimScreen(viewModel: _claimVm),
                ),
              ).then((_) => _grantVm.loadGrants());
            },
            icon: Badge(
              label: Text('${_claimVm.activeClaimCount}/3'),
              child: const Icon(Icons.assignment_turned_in_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _grantVm.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari buku, meja kos, jas lab hibah...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _grantVm.setSearchQuery('');
                              },
                              icon: const Icon(Icons.clear_rounded),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: SocialGrantViewModel.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = SocialGrantViewModel.categories[index];
                        final selected = _grantVm.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.18),
                          onSelected: (_) => _grantVm.setCategory(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF0FDFA),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kuota Klaim Aktif Anda: ${_claimVm.activeClaimCount} / 3 klaim (BR-28)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF115E59),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DaftarDetailKlaimScreen(viewModel: _claimVm),
                        ),
                      ).then((_) => _grantVm.loadGrants());
                    },
                    child: const Text('Lihat Klaim & Antrean →'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _grantVm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _grantVm.grants.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Barang hibah tidak ditemukan (AC-03).',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _grantVm.loadGrants(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _grantVm.grants.length,
                            itemBuilder: (context, index) {
                              final item = _grantVm.grants[index];
                              return _buildGrantCard(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrantCard(SocialGrant item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HIBAH • GRATIS (Rp0)',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Kondisi: ${item.condition}',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Donatur: ${item.ownerName} (${item.ownerReputation.toStringAsFixed(1)} ★)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _claimVm.hasReachedActiveLimit
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Batas klaim aktif tercapai (maksimal 3 klaim Pending/Approved sekaligus - BR-28).',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AjukanKlaimScreen(
                                grant: item,
                                viewModel: _claimVm,
                              ),
                            ),
                          );
                          _grantVm.loadGrants();
                        },
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
                  label: const Text('Ajukan Klaim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
