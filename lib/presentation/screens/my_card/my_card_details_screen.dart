import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/my_card_details.dart';
import '../../providers/my_card_provider.dart';

class MyCardDetailsScreen extends StatefulWidget {
  const MyCardDetailsScreen({super.key});

  @override
  State<MyCardDetailsScreen> createState() => _MyCardDetailsScreenState();
}

class _MyCardDetailsScreenState extends State<MyCardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MyCardProvider>();
    final details = provider.details;

    _nameController = TextEditingController(text: details?.name ?? '');
    _titleController = TextEditingController(text: details?.title ?? '');
    _companyController = TextEditingController(text: details?.company ?? '');
    _phoneController = TextEditingController(text: details?.phone ?? '');
    _emailController = TextEditingController(text: details?.email ?? '');
    _websiteController = TextEditingController(text: details?.website ?? '');
    _addressController = TextEditingController(text: details?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.selectionClick();
      final details = MyCardDetails(
        name: _nameController.text.trim(),
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      );

      final provider = context.read<MyCardProvider>();
      provider.updateDetails(details);
      
      Navigator.of(context, rootNavigator: true).pushNamed('/my-card/designer');
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      prefixIcon: Icon(icon, color: const Color(0xFF6A3EEB), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6A3EEB), width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF6B6B6B),
        fontSize: 13,
        fontFamily: 'Inter',
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF6A3EEB),
        fontSize: 13,
        fontFamily: 'Inter',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildStepPill(String label, bool isActive) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6A3EEB) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 68,
        leading: Center(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Details',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Step 1 of 2',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              // Progress indicator pill bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepPill('● Step 1: Details', true),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStepPill('○ Step 2: Design', false),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Form
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PERSONAL SECTION
                      Text(
                        'PERSONAL',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Full Name*', LucideIcons.user),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Job Title', LucideIcons.briefcase),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _companyController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Company', LucideIcons.building), // Lucide building2 falls back
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // CONTACT SECTION
                      Text(
                        'CONTACT',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Phone', LucideIcons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Email', LucideIcons.mail),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _websiteController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Website', LucideIcons.globe),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // LOCATION SECTION
                      Text(
                        'LOCATION',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        decoration: _buildInputDecoration('Address', LucideIcons.mapPin),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Bottom CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A3EEB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next: Choose Design',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
