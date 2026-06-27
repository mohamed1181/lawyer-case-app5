import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/legal_case.dart';
import '../providers/case_provider.dart';
import '../theme/app_theme.dart';

/// شاشة "إضافة سريعة" - فورم واحد لإدخال قضية جديدة في أقل وقت ممكن
/// مصممة لتقليل عدد اللمسات (Taps) إلى أدنى حد للمحامي المنشغل
class QuickAddScreen extends StatefulWidget {
  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _caseNumberCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _partiesCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _caseType = 'مدني';
  DateTime? _nextSession;
  CaseStatus _status = CaseStatus.active;

  static const List<String> caseTypes = [
    'جنائي',
    'مدني',
    'أحوال شخصية',
    'تجاري',
    'عمالي',
    'إداري',
  ];

  Future<void> _pickSessionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _nextSession = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newCase = LegalCase(
      caseNumber: _caseNumberCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      caseType: _caseType,
      parties: _partiesCtrl.text.trim(),
      court: _courtCtrl.text.trim(),
      nextSessionDate: _nextSession,
      status: _status,
      notes: _notesCtrl.text.trim(),
    );

    context.read<CaseProvider>().addCase(newCase);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ القضية ${newCase.displayId} بنجاح')),
    );
  }

  InputDecoration _decoration(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.gold) : null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة قضية جديدة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _caseNumberCtrl,
                    decoration: _decoration('رقم القضية *', icon: Icons.numbers),
                    keyboardType: TextInputType.text,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
                    decoration: _decoration('السنة *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'مطلوب';
                      if (int.tryParse(v.trim()) == null) return 'سنة غير صحيحة';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _caseType,
              decoration: _decoration('نوع القضية *', icon: Icons.category),
              dropdownColor: AppColors.charcoal,
              items: caseTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _caseType = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _partiesCtrl,
              decoration: _decoration('أسماء الخصوم والموكلين *', icon: Icons.people),
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _courtCtrl,
              decoration: _decoration('المحكمة المختصة / الدائرة *', icon: Icons.account_balance),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickSessionDate,
              child: InputDecorator(
                decoration: _decoration('تاريخ الجلسة القادمة', icon: Icons.event),
                child: Text(
                  _nextSession == null
                      ? 'اضغط لاختيار التاريخ (اختياري)'
                      : '${_nextSession!.year}/${_nextSession!.month}/${_nextSession!.day}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<CaseStatus>(
              value: _status,
              decoration: _decoration('الموقف القانوني الحالي', icon: Icons.flag),
              dropdownColor: AppColors.charcoal,
              items: CaseStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.arabicLabel)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesCtrl,
              decoration: _decoration('ملاحظات', icon: Icons.note_alt),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ القضية'),
            ),
          ],
        ),
      ),
    );
  }
}
