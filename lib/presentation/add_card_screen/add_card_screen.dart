import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/camera_scanner_widget.dart';
import './widgets/card_preview_widget.dart';
import './widgets/manual_entry_form_widget.dart';

/// Add Card Screen - Enables users to add payment cards via camera scan or manual entry
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller for switching between scan and manual entry
  late TabController _tabController;

  // Current bottom navigation index
  int _currentBottomNavIndex = 3; // Add Card tab

  // Card entry mode
  bool _isScanning = true;

  // Form data
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Card type detection
  String _cardType = 'unknown';
  bool _isProcessing = false;
  bool _setAsDefault = false;

  // Camera related
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  XFile? _capturedImage;

  // Flag pengaman (Class Level) agar bisa dibaca dari mana saja
  bool _isComputingFrame = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // LOGIKA TAB CONTROLLER YANG SUDAH DIPERBAIKI
    _tabController.addListener(() {
      setState(() {
        _isScanning = _tabController.index == 0;
      });

      if (_cameraController != null && _cameraController!.value.isInitialized) {
        if (_tabController.index == 1) {
          // Jika pindah ke Tab Manual: STOP STREAM (Hemat Baterai & Memori)
          if (_cameraController!.value.isStreamingImages) {
            _cameraController!.stopImageStream();
          }
        } else {
          // Jika kembali ke Tab Scan: NYALAKAN STREAM LAGI
          if (!_cameraController!.value.isStreamingImages) {
            // Kita panggil fungsi _processCameraImage yang sudah dipisah
            _cameraController!.startImageStream(_processCameraImage);
          }
        }
      }
    });

    _initializeCamera();
  }

  // FUNGSI BARU: Logika Pemrosesan Gambar dipisah di sini
  // Agar bisa dipanggil saat init maupun saat ganti tab
  void _processCameraImage(CameraImage image) async {
    // 1. Cek Busy Flag (Pengaman Buffer Overflow)
    if (_isComputingFrame) return; 
    
    // 2. Kunci Pintu
    _isComputingFrame = true; 

    try {
       // ---------------------------------------------------------
       // TEMPAT MENARUH KODE ML KIT / GOOGLE ML VISION ANDA NANTI
       // Contoh: await cardScanner.scan(image);
       // ---------------------------------------------------------
    } catch (e) {
      print("Error scanning frame: $e");
    } finally {
      // 3. Buka Kunci Pintu
      _isComputingFrame = false; 
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize camera for card scanning
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Camera permission is required for scanning cards',
                ),
              ),
            );
          }
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera available on this device')),
          );
        }
        return;
      }

      // Select appropriate camera
      final camera = kIsWeb
          ? _cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first,
            )
          : _cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first,
            );

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        // Gunakan LOW agar aman dari crash di Xiaomi/Redmi
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      // Panggil fungsi yang sudah kita pisah di atas
      _cameraController!.startImageStream(_processCameraImage);

      // Apply camera settings (skip unsupported features on web)
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Focus mode not supported
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.off);
        } catch (e) {
          // Flash not supported
        }
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera')),
        );
      }
    }
  }

  /// Toggle camera flash
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized || kIsWeb) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      HapticFeedback.lightImpact();
    } catch (e) {
      // Flash not supported
    }
  }

  /// Capture photo from camera
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      HapticFeedback.mediumImpact();
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });

      // Simulate card detection with haptic feedback
      await Future.delayed(const Duration(milliseconds: 500));
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card detected! Processing...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Switch to manual entry tab with pre-filled data
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    }
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _capturedImage = image;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected! Processing...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Switch to manual entry tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  /// Retake photo
  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
    HapticFeedback.lightImpact();
  }

  /// Detect card type from card number
  void _detectCardType(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');

    if (cleanNumber.isEmpty) {
      setState(() => _cardType = 'unknown');
      return;
    }

    // Visa
    if (cleanNumber.startsWith('4')) {
      setState(() => _cardType = 'visa');
    }
    // Mastercard
    else if (cleanNumber.startsWith(RegExp(r'5[1-5]')) ||
        cleanNumber.startsWith(RegExp(r'2[2-7]'))) {
      setState(() => _cardType = 'mastercard');
    }
    // American Express
    else if (cleanNumber.startsWith(RegExp(r'3[47]'))) {
      setState(() => _cardType = 'amex');
    }
    // Discover
    else if (cleanNumber.startsWith('6011') ||
        cleanNumber.startsWith(RegExp(r'65'))) {
      setState(() => _cardType = 'discover');
    } else {
      setState(() => _cardType = 'unknown');
    }
  }

  /// Format card number with spaces
  String _formatCardNumber(String value) {
    final cleanValue = value.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }

    return buffer.toString();
  }

  /// Validate and save card
  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Simulate card verification with banking network
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Text('Card Added Successfully'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your card ending in ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)} has been added to your wallet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_setAsDefault) ...[
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Theme.of(context).colorScheme.secondary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Set as default payment method',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/wallet-dashboard');
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Add Card',
        variant: CustomAppBarVariant.withBack,
        actions: [
          if (_tabController.index == 1)
            TextButton(
              onPressed: _isProcessing ? null : _saveCard,
              child: Text(
                'Save',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isProcessing
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Scan Card'),
                Tab(text: 'Manual Entry'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Camera scanner tab
                CameraScannerWidget(
                  cameraController: _cameraController,
                  isCameraInitialized: _isCameraInitialized,
                  isFlashOn: _isFlashOn,
                  capturedImage: _capturedImage,
                  onToggleFlash: _toggleFlash,
                  onCapturePhoto: _capturePhoto,
                  onPickFromGallery: _pickFromGallery,
                  onRetakePhoto: _retakePhoto,
                ),

                // Manual entry tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card preview
                      CardPreviewWidget(
                        cardNumber: _cardNumberController.text,
                        cardHolder: _cardHolderController.text,
                        expiry: _expiryController.text,
                        cardType: _cardType,
                      ),

                      SizedBox(height: 3.h),

                      // Manual entry form
                      ManualEntryFormWidget(
                        formKey: _formKey,
                        cardNumberController: _cardNumberController,
                        cardHolderController: _cardHolderController,
                        expiryController: _expiryController,
                        cvvController: _cvvController,
                        cardType: _cardType,
                        setAsDefault: _setAsDefault,
                        isProcessing: _isProcessing,
                        onCardNumberChanged: (value) {
                          final formatted = _formatCardNumber(value);
                          _cardNumberController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                          _detectCardType(formatted);
                        },
                        onSetAsDefaultChanged: (value) {
                          setState(() => _setAsDefault = value ?? false);
                        },
                        onSave: _saveCard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}