import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/models/qr_card_payload.dart';

class QrDetectedOverlay extends StatelessWidget {
  final QrCardPayload payload;

  const QrDetectedOverlay({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7EF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle2, 
                  color: Color(0xFF12A664), 
                  size: 32,
                ),
              ).animate()
               .scale(
                 begin: const Offset(0.5, 0.5), 
                 end: const Offset(1, 1), 
                 duration: 400.ms, 
                 curve: Curves.elasticOut,
               ),
              
              const SizedBox(height: 16),
              
              const Text(
                "Nebula QR Detected", 
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans', 
                  fontSize: 16,
                  fontWeight: FontWeight.w700, 
                  color: Color(0xFF0A0A0A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                payload.name, 
                style: const TextStyle(
                  fontFamily: 'Inter', 
                  fontSize: 14, 
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ).animate()
         .fadeIn(duration: 200.ms)
         .scale(
           begin: const Offset(0.9, 0.9), 
           end: const Offset(1, 1), 
           duration: 250.ms,
         ),
      ),
    );
  }
}
