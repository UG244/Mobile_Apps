import 'package:flutter/material.dart';

import '../db/order_db.dart';
import '../models/checkout_address_model.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key, this.selectedAddressId});

  final int? selectedAddressId;

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();

  late Future<List<CheckoutAddressModel>> _addressesFuture;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _addressesFuture = OrderDb.instance.getCheckoutAddresses();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_showForm ? 'Tambah Alamat' : 'Alamat Pengiriman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_showForm) {
              setState(() => _showForm = false);
              return;
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _showForm ? _buildAddressForm() : _buildAddressList(),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 14,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _showForm
                  ? _saveAddress
                  : () => setState(() => _showForm = true),
              icon: Icon(
                _showForm
                    ? Icons.save_outlined
                    : Icons.add_location_alt_outlined,
              ),
              label: Text(
                _showForm ? 'Simpan dan Gunakan Alamat' : 'Tambah Alamat Baru',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return FutureBuilder<List<CheckoutAddressModel>>(
      future: _addressesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum Ada Alamat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tekan tombol di bawah untuk menambahkan alamat baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: addresses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = addresses[index];
            final selected = item.id == widget.selectedAddressId;

            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? const Color(0xFF1565C0) : Colors.black45,
                ),
                title: Text(
                  item.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${item.phone}\n${item.address}'),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pop(item),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AddressFormField(
                  controller: _name,
                  label: 'Nama Penerima',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama penerima wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                _AddressFormField(
                  controller: _phone,
                  label: 'Nomor HP',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nomor HP wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                _AddressFormField(
                  controller: _address,
                  label: 'Alamat Lengkap',
                  icon: Icons.location_on_outlined,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Alamat lengkap wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                _AddressFormField(
                  controller: _note,
                  label: 'Catatan',
                  icon: Icons.sticky_note_2_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final item = CheckoutAddressModel(
      recipientName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      note: _note.text.trim(),
      createdAt: DateTime.now(),
    );

    final id = await OrderDb.instance.insertCheckoutAddress(item);
    item.id = id;

    if (!mounted) return;
    Navigator.of(context).pop(item);
  }
}

class _AddressFormField extends StatelessWidget {
  const _AddressFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 56,
            minHeight: 56,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
