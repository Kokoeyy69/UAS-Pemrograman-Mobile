import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart'; // Pastikan import ini ada

/// Camera scanner widget for card scanning functionality
class CameraScannerWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final bool isFlashOn;
  final XFile? capturedImage;
  final VoidCallback onToggleFlash;
  final VoidCallback onCapturePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRetakePhoto;

  const CameraScannerWidget({
    Key? key,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.isFlashOn,
    required this.capturedImage,
    required this.onToggleFlash,
    required this.onCapturePhoto,
    required this.onPickFromGallery,
    required this.onRetakePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (capturedImage != null) {
      return _buildCapturedImageView(context, theme);
    }

    if (!isCameraInitialized || cameraController == null) {
      return _buildLoadingView(context, theme);
    }

    return _buildCameraView(context, theme);
  }

  /// Build camera preview with overlay
  Widget _buildCameraView(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(child: CameraPreview(cameraController!)),

        // Dark overlay
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        // Card outline guide
        Center(
          child: Container(
            width: 85.w,
            height: 25.h,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Instructions
        Positioned(
          top: 8.h,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'credit_card',
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 1.h),
                Text(
                  // ✅ TRANSLATE: Position card within frame
                  'camera_scanner_instructions_title'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  // ✅ TRANSLATE: Make sure details visible
                  'camera_scanner_instructions_subtitle'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Flash toggle (mobile only)
        if (!kIsWeb)
          Positioned(
            top: 4.h,
            right: 4.w,
            child: IconButton(
              onPressed: onToggleFlash,
              icon: CustomIconWidget(
                iconName: isFlashOn ? 'flash_on' : 'flash_off',
                color: Colors.white,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                padding: EdgeInsets.all(3.w),
              ),
            ),
          ),

        // Bottom controls
        Positioned(
          bottom: 4.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Capture button
              GestureDetector(
                onTap: onCapturePhoto,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Gallery button
              TextButton.icon(
                onPressed: onPickFromGallery,
                icon: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  // ✅ TRANSLATE: Choose from Gallery
                  'camera_scanner_btn_gallery'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build captured image view with retake option
  Widget _buildCapturedImageView(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        // Captured image preview
        Positioned.fill(
          child: kIsWeb
              ? CustomImageWidget(
                  imageUrl: capturedImage!.path,
                  fit: BoxFit.contain,
                  // ✅ TRANSLATE: Semantic Label
                  semanticLabel: 'camera_scanner_preview_semantic_label'.tr(),
                )
              : FutureBuilder<String>(
                  future: capturedImage!.readAsBytes().then(
                    (bytes) => capturedImage!.path,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CustomImageWidget(
                        imageUrl: snapshot.data!,
                        fit: BoxFit.contain,
                        // ✅ TRANSLATE: Semantic Label
                        semanticLabel: 'camera_scanner_preview_semantic_label'.tr(),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
        ),

        // Processing overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    SizedBox(height: 2.h),
                    Text(
                      // ✅ TRANSLATE: Processing card details...
                      'camera_scanner_processing_title'.tr(),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Retake button
        Positioned(
          bottom: 4.h,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: onRetakePhoto,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              // ✅ TRANSLATE: Retake Photo
              label: Text('camera_scanner_btn_retake'.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build loading view
  Widget _buildLoadingView(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: 2.h),
            // ✅ TRANSLATE: Initializing camera...
            Text('camera_scanner_loading_title'.tr(), style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            Text(
              // ✅ TRANSLATE: Please allow camera access...
              'camera_scanner_loading_subtitle'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}