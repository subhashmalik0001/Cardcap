import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/business_card.dart';
import '../../../data/models/qr_card_payload.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/review/wallet_card_preview.dart';

class QrScanResultScreen extends StatelessWidget {
  final QrCardPayload payload;

  const QrScanResultScreen({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    final card = payload.toBusinessCard();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x14000000), 
                                              blurRadius: 12)],
                      ),
                      child: const Icon(LucideIcons.x, color: Color(0xFF0A0A0A), size: 18),
                    ),
                  ),
                  const Spacer(),
                  const Text("From QR Code", style: TextStyle(
                    fontFamily: 'PlusJakartaSans', fontSize: 18,
                    fontWeight: FontWeight.w700, color: Color(0xFF0A0A0A))),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            
            // Success badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.zap, color: Color(0xFF12A664), size: 14),
                  SizedBox(width: 6),
                  Text("Instantly read — no scanning needed", style: TextStyle(
                    color: Color(0xFF12A664), fontSize: 12, 
                    fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contact card preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    WalletCardPreview(card: card),
                    const SizedBox(height: 20),
                    _buildFieldsSummary(card),
                  ],
                ),
              ),
            ),
            
            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<CardsProvider>().addCard(card);
                    if (context.mounted) {
                      Navigator.popUntil(context, (r) => r.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${card.name} saved to contacts'),
                          backgroundColor: const Color(0xFF12A664)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3EEB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Save Contact", style: TextStyle(
                    color: Colors.white, fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsSummary(BusinessCard card) {
    final fields = <Widget>[];
    
    if (card.designation != null && card.designation!.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.briefcase, card.designation!));
    }
    if (card.company != null && card.company!.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.building2, card.company!));
    }
    if (card.phones.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.phone, card.phones.first));
    }
    if (card.email != null && card.email!.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.mail, card.email!));
    }
    if (card.website != null && card.website!.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.globe, card.website!));
    }
    if (card.address != null && card.address!.isNotEmpty) {
      fields.add(_summaryRow(LucideIcons.mapPin, card.address!));
    }

    if (fields.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16)],
      ),
      child: Column(
        children: fields,
      ),
    );
  }

  Widget _summaryRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A3EEB)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, color: Color(0xFF0A0A0A)))),
        ],
      ),
    );
  }
}
