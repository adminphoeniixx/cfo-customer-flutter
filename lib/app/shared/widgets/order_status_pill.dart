import 'package:flutter/material.dart';
import 'pill_badge.dart';

/// Maps an order's `status` to a tone consistent with the prototype
/// (green delivered, pink processing, red cancelled, amber pending refund…).
class OrderStatusPill extends StatelessWidget {
  final String status;
  final String label;

  const OrderStatusPill({super.key, required this.status, required this.label});

  PillTone get _tone {
    switch (status) {
      case 'delivered':
      case 'completed':
        return PillTone.ok;
      case 'cancelled':
      case 'rejected':
        return PillTone.critical;
      case 'shipped':
      case 'out_for_delivery':
      case 'processing':
        return PillTone.info;
      case 'pending':
      case 'withdrawn':
        return PillTone.warn;
      default:
        return PillTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) => PillBadge(label: label, tone: _tone);
}
