import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/models/my_card_details.dart';
import '../../../data/services/qr_card_service.dart';

class MyCardQrSection extends StatelessWidget {
  final MyCardDetails details;
  final String? cardImageUrl;

  const MyCardQrSection({super.key, required this.details, this.cardImageUrl});

  Future<void> _shareQrImage(BuildContext context, String qrString, MyCardDetails details) async {
    try {
      final qrImage = await QrPainter(
        data: qrString,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF0A0A0A)),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF0A0A0A)),
      ).toImageData(600);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/my_card_qr.png');
      await file.writeAsBytes(qrImage!.buffer.asUint8List());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${details.name} — Scan to save my contact on Nebula',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share QR: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveQrToGallery(BuildContext context, String qrString) async {
    try {
      final qrImage = await QrPainter(
        data: qrString,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF0A0A0A)),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF0A0A0A)),
      ).toImageData(800);
      
      final result = await ImageGallerySaverPlus.saveImage(
        qrImage!.buffer.asUint8List(),
        name: 'nebula_qr_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code saved to gallery!'),
            backgroundColor: Color(0xFF12A664),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save to gallery: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFullscreenQr(BuildContext context, String qrString, MyCardDetails details) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Scan to connect", style: TextStyle(
                      fontFamily: 'PlusJakartaSans', fontSize: 20, 
                      fontWeight: FontWeight.w700, color: Color(0xFF0A0A0A),
                    )),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(
                          color: Color(0x1F6A3EEB), blurRadius: 32,
                        )],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: qrString,
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            size: 280,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.circle, color: Color(0xFF0A0A0A)),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle, 
                              color: Color(0xFF0A0A0A)),
                            embeddedImage: const AssetImage('assets/images/Icon.png'),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(56, 56),
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/Icon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(details.name, style: const TextStyle(
                      fontFamily: 'PlusJakartaSans', fontSize: 17,
                      fontWeight: FontWeight.w700, color: Color(0xFF0A0A0A))),
                    if (details.title != null)
                      Text(details.title!, style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: Color(0xFF6B6B6B))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3EEB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Done", style: TextStyle(
                    color: Colors.white, fontFamily: 'Inter', 
                    fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrString = QrCardService().generateSafeQrString(details, cardImageUrl);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header row (outside the card)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE8FC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.qrCode, 
                                color: Color(0xFF6A3EEB), size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Text("Your Digital Card QR",
                       style: TextStyle(
                         fontFamily: 'PlusJakartaSans',
                         fontSize: 16, fontWeight: FontWeight.w700,
                         color: Color(0xFF0A0A0A),
                       )),
                ],
              ),
              // Live indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF12A664),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text("Active", style: TextStyle(
                      color: Color(0xFF12A664), fontSize: 11, 
                      fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // The actual card container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // QR code container — framed like a premium scannable tile
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
                  ),
                  child: Column(
                    children: [
                      // The actual QR widget with branded styling
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: qrString,
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            size: 200,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.circle,         // rounded corner markers
                              color: Color(0xFF0A0A0A),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,  // dotted style modules
                              color: Color(0xFF0A0A0A),
                            ),
                            embeddedImage: const AssetImage('assets/images/Icon.png'),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(44, 44),
                            ),
                          ),
                          // White circular background container with shadowed icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  'assets/images/Icon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // Name under QR (like an ID badge)
                      Text(details.name,
                           style: const TextStyle(
                             fontFamily: 'PlusJakartaSans',
                             fontSize: 15, fontWeight: FontWeight.w700,
                             color: Color(0xFF0A0A0A),
                           )),
                      if (details.company != null && details.company!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(details.company!,
                               style: const TextStyle(
                                 fontFamily: 'Inter', fontSize: 12,
                                 color: Color(0xFF6B6B6B),
                               )),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Helper caption
                const Text(
                  "Anyone can scan this with Nebula to instantly save your details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12.5,
                    color: Color(0xFF6B6B6B), height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                // Action row: Share / Download / Fullscreen
                Row(
                  children: [
                    Expanded(
                      child: _QrActionButton(
                        icon: LucideIcons.share2,
                        label: "Share",
                        onTap: () => _shareQrImage(context, qrString, details),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QrActionButton(
                        icon: LucideIcons.download,
                        label: "Save",
                        onTap: () => _saveQrToGallery(context, qrString),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QrActionButton(
                        icon: LucideIcons.maximize2,
                        label: "Fullscreen",
                        onTap: () => _showFullscreenQr(context, qrString, details),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QrActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6A3EEB), size: 18),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11.5, 
              fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A),
            )),
          ],
        ),
      ),
    );
  }
}
