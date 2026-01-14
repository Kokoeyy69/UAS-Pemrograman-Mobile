import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. Import Wajib

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget for selecting transfer recipient
/// Supports contact search, recent transfers, and manual entry
class RecipientSelectionWidget extends StatefulWidget {
  final TextEditingController searchController;
  final Map<String, dynamic>? selectedRecipient;
  final Function(Map<String, dynamic>) onRecipientSelected;
  final List<Map<String, dynamic>> recentTransfers;

  const RecipientSelectionWidget({
    Key? key,
    required this.searchController,
    required this.selectedRecipient,
    required this.onRecipientSelected,
    required this.recentTransfers,
  }) : super(key: key);

  @override
  State<RecipientSelectionWidget> createState() =>
      _RecipientSelectionWidgetState();
}

class _RecipientSelectionWidgetState extends State<RecipientSelectionWidget> {
  bool _showManualEntry = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleManualEntry() {
    if (_nameController.text.isEmpty) {
      // ✅ TRANSLATE: Error Name
      _showError('recipient_selection_err_name'.tr());
      return;
    }

    if (_emailController.text.isEmpty && _phoneController.text.isEmpty) {
      // ✅ TRANSLATE: Error Contact Info
      _showError('recipient_selection_err_contact'.tr());
      return;
    }

    final recipient = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text,
      'email': _emailController.text.isNotEmpty ? _emailController.text : null,
      'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
      'avatar':
          'https://ui-avatars.com/api/?name=${_nameController.text}&background=1B365D&color=fff',
      'semanticLabel': 'Generated avatar for ${_nameController.text}',
      'isManual': true,
    };

    widget.onRecipientSelected(recipient);
    setState(() {
      _showManualEntry = false;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
    });
    HapticFeedback.mediumImpact();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ TRANSLATE: Select Recipient
                Text('recipient_selection_title'.tr(), style: theme.textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showManualEntry = !_showManualEntry;
                    });
                    HapticFeedback.lightImpact();
                  },
                  icon: CustomIconWidget(
                    iconName: _showManualEntry ? 'close' : 'person_add',
                    size: 5.w,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    // ✅ TRANSLATE: Cancel / Add New
                    _showManualEntry 
                      ? 'recipient_selection_btn_cancel'.tr() 
                      : 'recipient_selection_btn_add_new'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.selectedRecipient != null) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CustomImageWidget(
                      imageUrl: widget.selectedRecipient!['avatar'] as String,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                      semanticLabel:
                          widget.selectedRecipient!['semanticLabel'] as String,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedRecipient!['name'] as String,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.selectedRecipient!['email'] != null)
                          Text(
                            widget.selectedRecipient!['email'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Passing null to indicate deselection, handle null safety in parent
                      widget.onRecipientSelected(null as dynamic); 
                      // Atau jika parent expect map kosong: widget.onRecipientSelected({});
                      HapticFeedback.lightImpact();
                    },
                    icon: CustomIconWidget(
                      iconName: 'close',
                      size: 5.w,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ] else if (_showManualEntry) ...[
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      // ✅ TRANSLATE: Recipient Name
                      labelText: 'recipient_selection_label_name'.tr(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      // ✅ TRANSLATE: Email
                      labelText: 'recipient_selection_label_email'.tr(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      // ✅ TRANSLATE: Phone Number
                      labelText: 'recipient_selection_label_phone'.tr(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleManualEntry,
                      // ✅ TRANSLATE: Add Recipient
                      child: Text('recipient_selection_btn_add_recipient'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  // ✅ TRANSLATE: Search contacts...
                  hintText: 'recipient_selection_hint_search'.tr(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: widget.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            widget.searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          if (!_showManualEntry && widget.selectedRecipient == null)
            Container(
              height: 25.h,
              child: widget.searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'contacts',
                            size: 15.w,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            // ✅ TRANSLATE: Search or add a recipient
                            'recipient_selection_empty_state'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: widget.recentTransfers.length,
                      itemBuilder: (context, index) {
                        final contact = widget.recentTransfers[index];
                        final name = contact['name'] as String;

                        if (!name.toLowerCase().contains(
                          widget.searchController.text.toLowerCase(),
                        )) {
                          return SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CustomImageWidget(
                              imageUrl: contact['avatar'] as String,
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                              semanticLabel: contact['semanticLabel'] as String,
                            ),
                          ),
                          title: Text(name, style: theme.textTheme.titleSmall),
                          subtitle: Text(
                            contact['email'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: CustomIconWidget(
                            iconName: 'arrow_forward_ios',
                            size: 4.w,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            widget.onRecipientSelected(contact);
                            HapticFeedback.lightImpact();
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}