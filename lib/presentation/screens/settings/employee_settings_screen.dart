// =============================================================================
// شاشة إعدادات الموظف - تطبيق العكابي
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/settings_providers.dart';
import '../../../presentation/widgets/common/shared_widgets.dart';

class EmployeeSettingsScreen extends ConsumerStatefulWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  ConsumerState<EmployeeSettingsScreen> createState() =>
      _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState
    extends ConsumerState<EmployeeSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _signCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _posCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _nameCtrl = TextEditingController(text: s.defaultEmployeeName);
    _idCtrl = TextEditingController(text: s.defaultEmployeeId);
    _signCtrl = TextEditingController(text: s.defaultEmployeeSignature);
    _phoneCtrl = TextEditingController(text: s.defaultEmployeePhone);
    _posCtrl = TextEditingController(text: s.defaultEmployeePosition);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _signCtrl.dispose();
    _phoneCtrl.dispose();
    _posCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(settingsProvider.notifier).updateEmployeeInfo(
      name: _nameCtrl.text.trim(),
      employeeId: _idCtrl.text.trim(),
      signature: _signCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      position: _posCtrl.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات الموظف بنجاح ✓'),
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
          title: const Text('بيانات الموظف'),
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
              GradientCard(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withValues(alpha: 0.1),
                    Colors.teal.withValues(alpha: 0.2),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.badge_rounded,
                        color: Colors.teal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بيانات الموظف الافتراضية',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تظهر هذه البيانات في كل سند حوالة جديد ويمكن تغييرها عند الحاجة',
                            style: TextStyle(
                              fontSize: 11,
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
              _buildField(
                controller: _nameCtrl,
                label: 'اسم الموظف',
                icon: Icons.person_rounded,
                required: true,
                hint: 'الاسم الكامل للموظف',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _posCtrl,
                label: 'المسمى الوظيفي',
                icon: Icons.work_rounded,
                hint: 'مثال: موظف حوالات',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _idCtrl,
                label: 'رقم الموظف / الهوية',
                icon: Icons.numbers_rounded,
                hint: 'الرقم الوظيفي أو رقم الهوية',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _phoneCtrl,
                label: 'رقم هاتف الموظف',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                hint: '07xxxxxxxx',
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _signCtrl,
                label: 'توقيع / ختم الموظف',
                icon: Icons.draw_rounded,
                hint: 'النص الذي يظهر في خانة التوقيع على السند',
                maxLines: 2,
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
