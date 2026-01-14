import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart'; // Pastikan import ini ada

/// Manual card entry form widget
class ManualEntryFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final String cardType;
  final bool setAsDefault;
  final bool isProcessing;
  final Function(String) onCardNumberChanged;
  final Function(bool?) onSetAsDefaultChanged;
  final VoidCallback onSave;

  const ManualEntryFormWidget({
    Key? key,
    required this.formKey,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.expiryController,
    required this.cvvController,
    required this.cardType,
    required this.setAsDefault,
    required this.isProcessing,
    required this.onCardNumberChanged,
    required this.onSetAsDefaultChanged,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card number field
          // ✅ TRANSLATE: Label
          Text(
            'manual_entry_card_number_label'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            decoration: InputDecoration(
              // ✅ TRANSLATE: Hint
              hintText: 'manual_entry_card_number_hint'.tr(),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: _buildCardTypeIcon(theme),
              ),
              counterText: '',
            ),
            onChanged: onCardNumberChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                // ✅ TRANSLATE: Empty Error
                return 'manual_entry_card_number_empty_error'.tr();
              }
              final cleanValue = value.replaceAll(' ', '');
              if (cleanValue.length < 13 || cleanValue.length > 16) {
                // ✅ TRANSLATE: Invalid Error
                return 'manual_entry_card_number_invalid_error'.tr();
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Cardholder name field
          // ✅ TRANSLATE: Label
          Text(
            'manual_entry_cardholder_label'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: cardHolderController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              // ✅ TRANSLATE: Hint
              hintText: 'manual_entry_cardholder_hint'.tr(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                // ✅ TRANSLATE: Empty Error
                return 'manual_entry_cardholder_empty_error'.tr();
              }
              if (value.length < 3) {
                // ✅ TRANSLATE: Short Error
                return 'manual_entry_cardholder_short_error'.tr();
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Expiry and CVV row
          Row(
            children: [
              // Expiry date field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ TRANSLATE: Label
                    Text(
                      'manual_entry_expiry_label'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      decoration: InputDecoration(
                        // ✅ TRANSLATE: Hint
                        hintText: 'manual_entry_expiry_hint'.tr(),
                        prefixIcon: Icon(Icons.calendar_today),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          // ✅ TRANSLATE: Empty
                          return 'manual_entry_expiry_empty_error'.tr();
                        }
                        if (value.length != 5) {
                          // ✅ TRANSLATE: Invalid
                          return 'manual_entry_expiry_invalid_error'.tr();
                        }
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        if (month == null || month < 1 || month > 12) {
                          // ✅ TRANSLATE: Month Error
                          return 'manual_entry_expiry_month_error'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),

              // CVV field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ TRANSLATE: Label
                    Text(
                      'manual_entry_cvv_label'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      maxLength: cardType == 'amex' ? 4 : 3,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          cardType == 'amex' ? 4 : 3,
                        ),
                      ],
                      decoration: InputDecoration(
                        // ✅ TRANSLATE: Hint
                        hintText: 'manual_entry_cvv_hint'.tr(),
                        prefixIcon: Icon(Icons.lock_outline),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          // ✅ TRANSLATE: Empty
                          return 'manual_entry_cvv_empty_error'.tr();
                        }
                        final expectedLength = cardType == 'amex' ? 4 : 3;
                        if (value.length != expectedLength) {
                          // ✅ TRANSLATE: Invalid
                          return 'manual_entry_cvv_invalid_error'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Set as default checkbox
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: CheckboxListTile(
              value: setAsDefault,
              onChanged: onSetAsDefaultChanged,
              // ✅ TRANSLATE: Set Default Title
              title: Text(
                'manual_entry_default_title'.tr(),
                style: theme.textTheme.bodyMedium,
              ),
              // ✅ TRANSLATE: Subtitle
              subtitle: Text(
                'manual_entry_default_subtitle'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
            ),
          ),

          SizedBox(height: 3.h),

          // Security notice
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    // ✅ TRANSLATE: Security Notice
                    'manual_entry_security_notice'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onSave,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      // ✅ TRANSLATE: Button Label
                      'manual_entry_btn_add_card'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build card type icon
  Widget _buildCardTypeIcon(ThemeData theme) {
    switch (cardType) {
      case 'visa':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic
          semanticLabel: 'manual_entry_visa_label'.tr(),
        );
      case 'mastercard':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic
          semanticLabel: 'manual_entry_mastercard_label'.tr(),
        );
      case 'amex':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/3/30/American_Express_logo.svg',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic
          semanticLabel: 'manual_entry_amex_label'.tr(),
        );
      case 'discover':
        return CustomImageWidget(
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/5/57/Discover_Card_logo.svg',
          width: 40,
          height: 25,
          fit: BoxFit.contain,
          // ✅ TRANSLATE: Semantic
          semanticLabel: 'manual_entry_discover_label'.tr(),
        );
      default:
        return CustomIconWidget(
          iconName: 'credit_card',
          color: theme.colorScheme.onSurfaceVariant,
          size: 24,
        );
    }
  }
}

/// Text input formatter for expiry date (MM/YY format)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 4) {
      return oldValue;
    }

    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      final formatted = year.isEmpty ? month : '$month/$year';

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue;
  }
}