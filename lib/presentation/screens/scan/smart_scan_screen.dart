import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/card_detector_service.dart';
import 'scan_result_screen.dart';
import 'widgets/camera_preview_layer.dart';
import 'widgets/capture_animation.dart';
import 'widgets/detection_frame_overlay.dart';
import 'widgets/scan_guide_overlay.dart';
import 'widgets/scan_status_bar.dart';

class SmartScanScreen extends StatefulWidget {
  const SmartScanScreen({super.key});

  @override
  State<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends State<SmartScanScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isProcessingFrame = false;
  bool _isCapturing = false;
  bool _triggerFlashAnimation = false;

  // Services
  final CardDetectorService _detectorService = CardDetectorService();
  final ImagePicker _imagePicker = ImagePicker();

  // Detection and Stability State
  Rect? _detectedNormalizedRect;
  double _stabilityProgress = 0.0;
  String _statusText = 'Align card inside the frame';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _statusText = 'No cameras found');
        return;
      }

      // Select back camera
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startFrameStream(backCamera);
    } catch (e) {
      print('Camera initialization failed: $e');
      setState(() => _statusText = 'Failed to open camera');
    }
  }

  void _startFrameStream(CameraDescription camera) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((CameraImage image) async {
      if (_isProcessingFrame || _isCapturing || !mounted) return;
      _isProcessingFrame = true;

      try {
        final result = await _detectorService.detectCard(image, camera);

        if (!mounted || _isCapturing) return;

        if (result != null) {
          // Calculate rotated image dimensions for normalization
          final isRotated = camera.sensorOrientation == 90 || camera.sensorOrientation == 270;
          final double rotatedW = isRotated ? image.height.toDouble() : image.width.toDouble();
          final double rotatedH = isRotated ? image.width.toDouble() : image.height.toDouble();

          final normalized = Rect.fromLTRB(
            result.boundingRect.left / rotatedW,
            result.boundingRect.top / rotatedH,
            result.boundingRect.right / rotatedW,
            result.boundingRect.bottom / rotatedH,
          );

          setState(() {
            _detectedNormalizedRect = normalized;
            _statusText = 'Card detected. Tap shutter to capture.';
            _stabilityProgress = 0.0;
          });
        } else {
          // Reset detection state when no card is found
          setState(() {
            _detectedNormalizedRect = null;
            _stabilityProgress = 0.0;
            _statusText = 'Align card inside the frame';
          });
        }
      } catch (e) {
        print('Frame processing error: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final newMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Failed to set flash mode: $e');
    }
  }

  Future<void> _manualCapture() async {
    if (_isCapturing || _controller == null || !_controller!.value.isInitialized) return;
    _isCapturing = true;

    HapticFeedback.mediumImpact();
    setState(() {
      _triggerFlashAnimation = true;
      _statusText = 'Capturing...';
    });

    try {
      await _controller?.stopImageStream();
      final XFile rawImage = await _controller!.takePicture();

      // Always open manual cropper UI to let user adjust bounds and verify card before OCR
      final croppedFile = await _showManualCropper(rawImage.path);
      if (croppedFile != null) {
        _navigateToResultScreen(croppedFile, 'manual');
      } else {
        _resumeScanning();
      }
    } catch (e) {
      print('Manual capture failed: $e');
      _resumeScanning();
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      // Stop frame streaming while user interacts with cropper/result
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final croppedFile = await _showManualCropper(image.path);
      if (croppedFile != null) {
        _navigateToResultScreen(croppedFile, 'manual');
      } else {
        _resumeScanning();
      }
    } catch (e) {
      print('Gallery picker error: $e');
      _resumeScanning();
    }
  }

  Future<File?> _showManualCropper(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Business Card',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Business Card',
            doneButtonTitle: 'Crop',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      print('Manual cropper UI error: $e');
    }
    return null;
  }

  void _navigateToResultScreen(File croppedFile, String scanMethod) {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          croppedCardFile: croppedFile,
          scanMethod: scanMethod,
        ),
      ),
    ).then((_) => _resumeScanning());
  }

  void _resumeScanning() {
    if (!mounted) return;
    setState(() {
      _isCapturing = false;
      _triggerFlashAnimation = false;
      _detectedNormalizedRect = null;
      _stabilityProgress = 0.0;
      _statusText = 'Align card inside the frame';
    });

    if (_controller != null && _isCameraInitialized) {
      // Re-enable flash mode if it was previously set
      if (_isFlashOn) {
        _controller!.setFlashMode(FlashMode.torch);
      }
      
      // Select the back camera to restart stream
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      _startFrameStream(backCamera);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isCameraInitialized
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Stack(
              children: [
                // Fullscreen Camera Feed
                CameraPreviewLayer(controller: _controller!),

                // Dark overlay cutout guide
                if (_detectedNormalizedRect == null)
                  const ScanGuideOverlay(),

                // Active green detection frame with sweeps and stability progress
                DetectionFrameOverlay(
                  normalizedRect: _detectedNormalizedRect,
                  stabilityProgress: _stabilityProgress,
                ),

                // Top actions bar
                ScanStatusBar(
                  onBackPressed: () => Navigator.of(context).pop(),
                  isFlashOn: _isFlashOn,
                  onFlashToggle: _toggleFlash,
                  statusText: _statusText,
                ),

                // Shutter controls overlay
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Gallery Picker Button
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.image,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),

                          // Manual Shutter Button
                          GestureDetector(
                            onTap: _manualCapture,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                          // Transparent spacer to align shutter in center
                          const SizedBox(width: 52),
                        ],
                      ),
                    ),
                  ),
                ),

                // Flash Animation Screen Overlay
                CaptureAnimation(
                  isTriggered: _triggerFlashAnimation,
                  onAnimationComplete: () {
                    setState(() {
                      _triggerFlashAnimation = false;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
