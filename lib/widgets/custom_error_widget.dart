import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../core/app_export.dart';
import '../routes/app_routes.dart';

// custom_error_widget.dart

class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;

  const CustomErrorWidget({Key? key, this.errorDetails, this.errorMessage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Pastikan aset ini ada, atau ganti dengan Icon jika belum ada
                SvgPicture.asset(
                  'assets/images/sad_face.svg',
                  height: 42,
                  width: 42,
                  // Fallback jika SVG tidak ditemukan (optional)
                  placeholderBuilder: (BuildContext context) => Icon(
                    Icons.error_outline,
                    size: 42,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // ✅ TRANSLATE: Something went wrong
                  'error_widget_title'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF262626),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  child: Text(
                    // ✅ TRANSLATE: We encountered an unexpected error...
                    'error_widget_message'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF525252), // neutral-600
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    bool canBeBack = Navigator.canPop(context);
                    if (canBeBack) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.pushNamed(context, AppRoutes.initial);
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Colors.white,
                  ),
                  // ✅ TRANSLATE: Back
                  label: Text('error_widget_btn_back'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}