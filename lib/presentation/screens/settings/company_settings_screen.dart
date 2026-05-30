// =============================================================================
// شاشة إعدادات الشركة - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() =>
      _CompanySettingsScreenState();
}

class _CompanySettingsScreenState
    extends ConsumerState<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _branchCtrl;
  late TextEditingController _phonesCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _licenseCtrl;
  late TextEditingController _crCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nameCtrl = TextEditingController(text: s.companyName);
    _nameEnCtrl = TextEditingController(text: s.companyNameEn);
    _branchCtrl = TextEditingController(text: s.branchName);
    _phonesCtrl = TextEditingController(text: s.companyPhones);
    _addressCtrl = TextEditingController(text: s.companyAddress);
    _emailCtrl = TextEditingController(text: s.companyEmail);
    _websiteCtrl = TextEditingController(text: s.companyWebsite);
    _licenseCtrl = TextEditingController(text: s.companyLicenseNumber);
    _crCtrl = TextEditingController(text: s.companyCRNumber);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameEnCtrl.dispose();
    _branchCtrl.dispose();
    _phonesCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _licenseCtrl.dispose();
    _crCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(settingsProvider.notifier).updateCompanyInfo(
      companyName: _nameCtrl.text.trim(),
      companyNameEn: _nameEnCtrl.text.trim(),
      branchName: _branchCtrl.text.trim(),
      companyPhones: _phonesCtrl.text.trim(),
      companyAddress: _addressCtrl.text.trim(),
      companyEmail: _emailCtrl.text.trim(),
      companyWebsite: _websiteCtrl.text.trim(),
      companyLicenseNumber: _licenseCtrl.text.trim(),
      companyCRNumber: _crCtrl.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات الشركة بنجاح ✓'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بيانات الشركة'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('حفظ'),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── رأس القسم ──────────────────────────
              GradientCard(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.12),
                    scheme.primaryContainer.withValues(alpha: 0.25),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      color: scheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بيانات الشركة والفرع',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'هذه البيانات تظهر على جميع سندات الحوالات والتقارير',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── حقول الشركة ────────────────────────
              _buildField(
                controller: _nameCtrl,
                label: 'اسم الشركة (عربي)',
                icon: Icons.business_rounded,
                required: true,
                hint: 'مثال: العكابي للصرافة والتحويلات',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _nameEnCtrl,
                label: 'اسم الشركة (إنجليزي)',
                icon: Icons.business_rounded,
                textDirection: TextDirection.ltr,
                hint: 'e.g. Al-Akabi Exchange',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _branchCtrl,
                label: 'اسم الفرع',
                icon: Icons.location_on_rounded,
                required: true,
                hint: 'مثال: الفرع الرئيسي - تعز',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _addressCtrl,
                label: 'العنوان التفصيلي',
                icon: Icons.map_rounded,
                hint: 'مثال: بير باشا - أمام محطة الحزام',
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _phonesCtrl,
                label: 'أرقام الهاتف',
                icon: Icons.phone_rounded,
                required: true,
                hint: 'مثال: 777245365 - 734166329',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _emailCtrl,
                label: 'البريد الإلكتروني',
                icon: Icons.email_rounded,
                hint: 'info@company.com',
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _websiteCtrl,
                label: 'الموقع الإلكتروني',
                icon: Icons.language_rounded,
                hint: 'www.company.com',
                textDirection: TextDirection.ltr,
              ),
              const Divider(height: 32),
              const SectionHeader(
                title: 'البيانات القانونية',
                icon: Icons.gavel_rounded,
                padding: EdgeInsets.only(bottom: 12),
              ),
              _buildField(
                controller: _licenseCtrl,
                label: 'رقم الرخصة',
                icon: Icons.assignment_rounded,
                hint: 'رقم الترخيص التجاري',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _crCtrl,
                label: 'رقم السجل التجاري',
                icon: Icons.article_rounded,
                hint: 'رقم السجل التجاري',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextDirection? textDirection,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: required
            ? const Icon(Icons.star, size: 8, color: Colors.red)
            : null,
      ),
    );
  }
}
