import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../add_subscription.dart';

/// Widget for camera-based subscription scanning
class CameraScannerWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onScanComplete;
  final VoidCallback onCancel;

  const CameraScannerWidget({
    super.key,
    required this.onScanComplete,
    required this.onCancel,
  });

  @override
  State<CameraScannerWidget> createState() => _CameraScannerWidgetState();
}

class _CameraScannerWidgetState extends State<CameraScannerWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _scanStatus = 'Position email or card in frame';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize camera with platform detection
  Future<void> _initializeCamera() async {
    try {
      // Step 1: Request camera permission
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          setState(() {
            _scanStatus = 'Camera permission denied';
          });
          return;
        }
      }

      // Step 2: Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _scanStatus = 'No camera available';
        });
        return;
      }

      // Step 3: Select appropriate camera based on platform
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      // Step 4: Initialize camera controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Step 5: Apply platform-specific settings
      if (!kIsWeb) {
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Ignore unsupported features
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanStatus = 'Camera initialization failed';
        });
      }
    }
  }

  /// Capture and process photo
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _scanStatus = 'Processing image...';
    });

    try {
      // Capture photo
      final XFile photo = await _cameraController!.takePicture();

      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock extracted data
      final extractedData = {
        'serviceName': 'Netflix',
        'cost': 15.99,
        'billingCycle': BillingCycle.monthly,
      };

      widget.onScanComplete(extractedData);
    } catch (e) {
      setState(() {
        _scanStatus = 'Failed to process image';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Camera preview or status
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _isInitialized && _cameraController != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(_cameraController!),
                          // Overlay guide
                          CustomPaint(
                            painter: _ScanOverlayPainter(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          // Status text
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _scanStatus,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'camera_alt',
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _scanStatus,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isInitialized && !_isProcessing
                      ? _capturePhoto
                      : null,
                  child: _isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Capture'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for scan overlay guide
class _ScanOverlayPainter extends CustomPainter {
  final Color color;

  _ScanOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Draw corner brackets
    final cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(0, cornerLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(0, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(0, -cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(0, -cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
