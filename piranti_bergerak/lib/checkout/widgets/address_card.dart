import 'package:flutter/material.dart';

import '../models/checkout_address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.selectedAddress,
    required this.isLoading,
    required this.onManageAddress,
  });

  final CheckoutAddressModel? selectedAddress;
  final bool isLoading;
  final VoidCallback onManageAddress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAddress = selectedAddress != null;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onManageAddress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Alamat Pengiriman',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isLoading)
                      const Text(
                        'Memuat daftar alamat...',
                        style: TextStyle(color: Colors.black54),
                      )
                    else if (!hasAddress)
                      const _EmptyAddressText()
                    else
                      _SelectedAddressText(address: selectedAddress!),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasAddress ? 'Ubah' : 'Pilih',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF1565C0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAddressText extends StatelessWidget {
  const _EmptyAddressText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pilih alamat tersimpan atau tambah alamat baru.',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.black54, height: 1.35),
    );
  }
}

class _SelectedAddressText extends StatelessWidget {
  const _SelectedAddressText({required this.address});

  final CheckoutAddressModel address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${address.recipientName} - ${address.phone}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          address.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, height: 1.35),
        ),
        if (address.note.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            address.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black45),
          ),
        ],
      ],
    );
  }
}
