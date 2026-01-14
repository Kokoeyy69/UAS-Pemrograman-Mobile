import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart'; // Pastikan import ini ada

/// Card preview widget showing visual representation of the card
class CardPreviewWidget extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiry;
  final String cardType;

  const CardPreviewWidget({
    Key? key,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
    required this.cardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _getCardGradient(),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(painter: _CardPatternPainter()),
            ),
          ),

          // Card content
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card type logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIconWidget(
                      iconName: 'credit_card',
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 32,
                    ),
                    if (cardType != 'unknown') _buildCardTypeLogo(),
                  ],
                ),

                const Spacer(),

                // Card number
                Text(
                  cardNumber.isEmpty
                      // ✅ TRANSLATE: Placeholder Number
                      ? 'card_preview_placeholder_number'.tr()
                      : _formatCardNumber(cardNumber),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: 2.h),

                // Cardholder and expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cardholder name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // ✅ TRANSLATE: CARDHOLDER Label
                            'card_preview_label_cardholder'.tr(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            cardHolder.isEmpty
                                // ✅ TRANSLATE: YOUR NAME Placeholder
                                ? 'card_preview_placeholder_name'.tr()
                                : cardHolder.toUpperCase(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 4.w),

                    // Expiry date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          // ✅ TRANSLATE: EXPIRES Label
                          'card_preview_label_expires'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          expiry.isEmpty 
                              // ✅ TRANSLATE: MM/YY Placeholder
                              ? 'card_preview_placeholder_expiry'.tr() 
                              : expiry,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  /// Get card gradient based on card type
  LinearGradient _getCardGradient() {
    switch (cardType) {
      case 'visa':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F71), Color(0xFF2E5984)],
        );
      case 'mastercard':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEB001B), Color(0xFFF79E1B)],
        );
      case 'amex':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006FCF), Color(0xFF00A3E0)],
        );
      case 'discover':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6000), Color(0xFFFFB700)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B365D), Color(0xFF2E5984)],
        );
    }
  }

  /// Build card type logo
  Widget _buildCardTypeLogo() {
    switch (cardType) {
      case 'visa':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg',
          width: 50,
          height: 30,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic Label
          semanticLabel: 'card_preview_visa_semantic_label'.tr(),
        );
      case 'mastercard':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg',
          width: 50,
          height: 30,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic Label
          semanticLabel: 'card_preview_mastercard_semantic_label'.tr(),
        );
      case 'amex':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/3/30/American_Express_logo.svg',
          width: 50,
          height: 30,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic Label
          semanticLabel: 'card_preview_amex_semantic_label'.tr(),
        );
      case 'discover':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/5/57/Discover_Card_logo.svg',
          width: 50,
          height: 30,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic Label
          semanticLabel: 'card_preview_discover_semantic_label'.tr(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Format card number with spaces
  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    // ✅ TRANSLATE: Placeholder inside logic (optional safety)
    if (cleaned.isEmpty) return 'card_preview_placeholder_number'.tr();

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }

    // Fill remaining with dots
    final remaining = 16 - cleaned.length;
    if (remaining > 0) {
      for (int i = 0; i < remaining; i++) {
        if ((cleaned.length + i) % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write('•');
      }
    }

    return buffer.toString();
  }
}

/// Custom painter for card background pattern
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.3,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      size.width * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}