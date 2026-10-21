import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/barter_deal.dart';
import '../../viewmodels/barter_view_model.dart';
import 'barter_confirmation_screen.dart';
import 'widgets/barter_visuals.dart';

class BarterListScreen extends StatelessWidget {
  const BarterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Barter Saya',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFF0D9488),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0D9488),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Dikirim'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BarterList(sent: true),
            _BarterList(sent: false),
          ],
        ),
      ),
    );
  }
}

class _BarterList extends StatelessWidget {
  final bool sent;
  const _BarterList({required this.sent});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarterViewModel>();
    final barters = sent ? viewModel.sentDeals : viewModel.receivedDeals;

    if (barters.isEmpty) {
      return const Center(
        child: Text('Belum ada tawaran', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: barters.length,
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final barter = barters[index];
        return _buildBarterItem(context, barter);
      },
    );
  }

  Widget _buildBarterItem(BuildContext context, BarterDeal data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (User & Status)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  data.partnerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              data.status,
              style: TextStyle(
                color: BarterVisuals.colorForDealStatus(data.status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Assets
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAssetIcon(data.myItem.name, BarterVisuals.iconForCategory(data.myItem.category)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.swap_horiz, color: Colors.grey.shade400, size: 20),
            ),
            _buildAssetIcon(
              data.partnerItem.name,
              BarterVisuals.iconForCategory(data.partnerItem.category),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Footer (Date & Detail Link)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.dateLabel,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BarterConfirmationScreen(dealId: data.id),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF0D9488)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetIcon(String label, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey.shade600, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
