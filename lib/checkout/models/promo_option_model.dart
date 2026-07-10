import 'package:flutter/material.dart';

class PromoOptionModel {
  const PromoOptionModel({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
}

const checkoutPromoOptions = [
  PromoOptionModel(
    code: 'ONGKIR0',
    title: 'Gratis Ongkir',
    subtitle: 'Ongkir jadi Rp 0',
    icon: Icons.local_shipping_outlined,
  ),
  PromoOptionModel(
    code: 'BLUEMART10',
    title: 'Potongan 10%',
    subtitle: 'Diskon 10% dari subtotal',
    icon: Icons.percent_rounded,
  ),
  PromoOptionModel(
    code: 'HEMAT50',
    title: 'Potongan Rp 50.000',
    subtitle: 'Hemat langsung untuk belanja besar',
    icon: Icons.discount_outlined,
  ),
];
