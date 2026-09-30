import 'package:flutter/material.dart';

import '../models/item.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  Item? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

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

    Navigator.pop(
      context,
      _catatanController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _catatanController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan kamu...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Catatan wajib diisi';
                    }

                    return null;
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _simpanCatatan,
                    child: const Text('Simpan Catatan'),
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