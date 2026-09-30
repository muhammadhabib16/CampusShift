import 'package:flutter/material.dart';

import '../models/item.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() =>
      _CatatanFormScreenState();
}

class _CatatanFormScreenState
    extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _catatanController =
      TextEditingController();

  Item? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Item) {
      _item = arguments;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpanCatatan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final catatan = _catatanController.text.trim();

    Navigator.pop(
      context,
      catatan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // BARANG
                // =========================
                if (_item != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Barang',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _item!.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _item!.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],

                // =========================
                // JUDUL
                // =========================
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // TEXT FIELD
                // =========================
                TextFormField(
                  controller: _catatanController,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        'Tulis catatan kamu...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color: Color(0xFF0D9488),
                        width: 2,
                      ),
                    ),
                    errorBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Catatan wajib diisi';
                    }

                    return null;
                  },
                ),

                const Spacer(),

                // =========================
                // SIMPAN
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _simpanCatatan,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Simpan Catatan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}