import 'package:flutter/material.dart';

import '../models/item.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan semua catatan yang sudah dibuat
  final List<String> _catatanList = [];

  @override
  Widget build(BuildContext context) {
    final item =
        ModalRoute.of(context)?.settings.arguments as Item?;

    // ==========================================
    // DATA TIDAK DITEMUKAN
    // ==========================================

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Barang'),
        ),
        body: const Center(
          child: Text(
            'Data barang tidak ditemukan.',
          ),
        ),
      );
    }

    // ==========================================
    // DETAIL BARANG
    // ==========================================

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),

      appBar: AppBar(
        title: const Text(
          'Detail Barang',
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==========================================
              // GAMBAR BARANG
              // ==========================================

              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 80,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // NAMA BARANG
              // ==========================================

              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ==========================================
              // KATEGORI
              // ==========================================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE0F2F1),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // DESKRIPSI
              // ==========================================

              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 28),

              // ==========================================
              // JUDUL CATATAN
              // ==========================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_catatanList.isNotEmpty)
                    Text(
                      '${_catatanList.length} catatan',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ==========================================
              // JIKA BELUM ADA CATATAN
              // ==========================================

              if (_catatanList.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        color: Colors.black38,
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Belum ada catatan.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              // ==========================================
              // JIKA SUDAH ADA CATATAN
              // ==========================================

              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      _catatanList.length,

                  separatorBuilder:
                      (context, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },

                  itemBuilder:
                      (context, index) {
                    return Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 8,
                            offset:
                                const Offset(
                              0,
                              2,
                            ),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ICON CATATAN
                          Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFE0F2F1,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),
                            child: const Icon(
                              Icons.notes_rounded,
                              color:
                                  Color(
                                0xFF0D9488,
                              ),
                              size: 20,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          // ISI CATATAN
                          Expanded(
                            child: Text(
                              _catatanList[index],
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color:
                                    Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // ==========================================
              // TOMBOL TAMBAH CATATAN
              // ==========================================

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Simpan ScaffoldMessenger
                    // sebelum async gap.
                    final scaffoldMessenger =
                        ScaffoldMessenger.of(
                      context,
                    );

                    final result =
                        await Navigator.pushNamed(
                      context,
                      '/catatan',
                      arguments: item,
                    );

                    // Pastikan State masih aktif.
                    if (!mounted) return;

                    // ==========================================
                    // HASIL CATATAN
                    // ==========================================

                    if (result is String &&
                        result.trim().isNotEmpty) {
                      setState(() {
                        _catatanList.add(
                          result.trim(),
                        );
                      });

                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Catatan berhasil disimpan.',
                          ),
                        ),
                      );
                    }
                  },

                  icon: const Icon(
                    Icons.add_comment_outlined,
                  ),

                  label: const Text(
                    'Tambah Catatan',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}