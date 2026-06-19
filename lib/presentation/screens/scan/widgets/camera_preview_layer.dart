import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewLayer extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewLayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // Get camera preview size. The value returned is for landscape mode.
        final previewSize = controller.value.previewSize;
        if (previewSize == null) {
          return CameraPreview(controller);
        }

        // Camera is landscape, but our viewport is portrait.
        // We invert the aspect ratio to match the portrait orientation.
        final double previewAspect = previewSize.height / previewSize.width;
        final double viewportAspect = size.width / size.height;

        // Calculate scale to achieve BoxFit.cover behavior
        double scale = 1.0;
        if (viewportAspect > previewAspect) {
          scale = viewportAspect / previewAspect;
        } else {
          scale = previewAspect / viewportAspect;
        }

        return ClipRect(
          child: OverflowBox(
            maxWidth: size.width,
            maxHeight: size.height,
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}
