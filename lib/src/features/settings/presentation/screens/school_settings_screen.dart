import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/core/constants/constants.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/app_state_provider.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SchoolSettingsScreen extends HookConsumerWidget {
  const SchoolSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolInfo = ref.watch(appStateProvider.select((s) => s.schoolInfo));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: context.pop,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Settings',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Manage your school details and grading',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SchoolInfoSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _ContactSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _BranchesSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _GradingSystemSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _SubjectsSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _CustomClassesSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 20),
                  _DisplayOptionsSection(schoolInfo: schoolInfo),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _sectionHeader(String title, {String? subtitle}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
      ],
    ),
  );
}

Widget _card({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF3F4F6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: School Info
// ─────────────────────────────────────────────────────────────────────────────

class _SchoolInfoSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _SchoolInfoSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController(text: schoolInfo.name);
    final motto = useTextEditingController(text: schoolInfo.motto);
    final address = useTextEditingController(text: schoolInfo.address);
    final website = useTextEditingController(text: schoolInfo.website);
    final year = useTextEditingController(text: schoolInfo.establishedYear);
    final isDirty = useState(false);
    final isSaving = useState(false);

    void markDirty() => isDirty.value = true;

    Future<void> save() async {
      isSaving.value = true;
      try {
        await ref
            .read(appStateProvider.notifier)
            .updateSchoolInfo(
              name: name.text.trim(),
              motto: motto.text.trim(),
              address: address.text.trim(),
              website: website.text.trim(),
              establishedYear: year.text.trim(),
            );
        isDirty.value = false;
        if (context.mounted) {
          context.showSuccessSnackBar('School info saved');
        }
      } finally {
        isSaving.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('School Information'),
        _card(
          children: [
            OutlinedTextField(
              labelText: 'School Name *',
              controller: name,
              hintText: 'e.g. Greenfield Academy',
              height: 50,
              prefixIcon: const Icon(
                Icons.school_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => markDirty(),
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Motto',
              controller: motto,
              hintText: 'e.g. Excellence in Learning',
              height: 50,
              prefixIcon: const Icon(
                Icons.format_quote_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => markDirty(),
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Address',
              controller: address,
              hintText: 'e.g. 12 School Road, Lagos',
              height: 50,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => markDirty(),
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Website',
              controller: website,
              hintText: 'e.g. www.myschool.com',
              height: 50,
              prefixIcon: const Icon(
                Icons.language_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => markDirty(),
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Established Year',
              controller: year,
              hintText: 'e.g. 1998',
              height: 50,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => markDirty(),
            ),
            if (isDirty.value) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSaving.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Contact Info
// ─────────────────────────────────────────────────────────────────────────────

class _ContactSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _ContactSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController(text: schoolInfo.contactInfo.email);
    final phone1 = useTextEditingController(
      text: schoolInfo.contactInfo.phone1,
    );
    final phone2 = useTextEditingController(
      text: schoolInfo.contactInfo.phone2,
    );
    final isDirty = useState(false);
    final isSaving = useState(false);

    Future<void> save() async {
      isSaving.value = true;
      try {
        await ref
            .read(appStateProvider.notifier)
            .updateSchoolInfo(
              contactInfo: ContactInfo(
                email: email.text.trim(),
                phone1: phone1.text.trim(),
                phone2: phone2.text.trim(),
              ),
            );
        isDirty.value = false;
        if (context.mounted) context.showSuccessSnackBar('Contact info saved');
      } finally {
        isSaving.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Contact Information'),
        _card(
          children: [
            OutlinedTextField(
              labelText: 'Email',
              controller: email,
              hintText: 'info@school.com',
              height: 50,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => isDirty.value = true,
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Phone 1',
              controller: phone1,
              hintText: '+234 800 000 0000',
              height: 50,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => isDirty.value = true,
            ),
            const SizedBox(height: 14),
            OutlinedTextField(
              labelText: 'Phone 2',
              controller: phone2,
              hintText: 'Optional second number',
              height: 50,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: KitColors.neutral500,
              ),
              onChanged: (_) => isDirty.value = true,
            ),
            if (isDirty.value) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving.value ? null : save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSaving.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Branches
// ─────────────────────────────────────────────────────────────────────────────

class _BranchesSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _BranchesSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = useState<List<String>>(List.from(schoolInfo.branches));

    Future<void> save(List<String> updated) async {
      await ref
          .read(appStateProvider.notifier)
          .updateSchoolInfo(branches: updated);
    }

    Future<void> addBranch() async {
      final result = await _showAddItemDialog(
        context,
        'Branch Name',
        'e.g. Main Campus',
      );
      if (result != null && result.isNotEmpty) {
        final updated = [...branches.value, result];
        branches.value = updated;
        await save(updated);
        if (context.mounted) context.showSuccessSnackBar('Branch added');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Branches',
          subtitle: 'School campuses or branches (optional)',
        ),
        _card(
          children: [
            if (branches.value.isEmpty)
              const Text(
                'No branches added. Tap + to add one.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              )
            else
              ...branches.value.asMap().entries.map(
                (entry) => _ItemRow(
                  label: entry.value,
                  onDelete: () async {
                    final updated = [...branches.value]..removeAt(entry.key);
                    branches.value = updated;
                    await save(updated);
                  },
                ),
              ),
            const SizedBox(height: 12),
            _AddButton(label: 'Add Branch', onTap: addBranch),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Grading System
// ─────────────────────────────────────────────────────────────────────────────

class _GradingSystemSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _GradingSystemSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranges = useState<List<GradeRange>>(
      List.from(schoolInfo.gradingSystem.ranges),
    );

    Future<void> saveRanges(List<GradeRange> updated) async {
      await ref
          .read(appStateProvider.notifier)
          .updateSchoolInfo(gradingSystem: GradingSystem(ranges: updated));
    }

    Future<void> editRange(GradeRange? existing, int? index) async {
      final result = await showDialog<GradeRange>(
        context: context,
        builder: (ctx) => _GradeRangeDialog(existing: existing),
      );
      if (result == null) return;
      List<GradeRange> updated;
      if (index == null) {
        updated = [...ranges.value, result];
      } else {
        updated = [...ranges.value];
        updated[index] = result;
      }
      ranges.value = updated;
      await saveRanges(updated);
      if (context.mounted) {
        context.showSuccessSnackBar(
          index == null ? 'Grade range added' : 'Grade range updated',
        );
      }
    }

    Future<void> deleteRange(int index) async {
      final updated = [...ranges.value]..removeAt(index);
      ranges.value = updated;
      await saveRanges(updated);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Grading System',
          subtitle: 'Define score ranges, grades, and remarks',
        ),
        _card(
          children: [
            if (ranges.value.isEmpty)
              const Text(
                'No grade ranges defined. Tap + to add one.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              )
            else
              ...ranges.value.asMap().entries.map(
                (entry) => _GradeRangeRow(
                  range: entry.value,
                  onEdit: () => editRange(entry.value, entry.key),
                  onDelete: () => deleteRange(entry.key),
                ),
              ),
            const SizedBox(height: 12),
            _AddButton(
              label: 'Add Grade Range',
              onTap: () => editRange(null, null),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradeRangeRow extends StatelessWidget {
  final GradeRange range;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _GradeRangeRow({
    required this.range,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(range.color);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              range.grade,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${range.min} – ${range.max}  •  ${range.remark}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  range.teacherRemark,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: const Color(0xFF6B7280),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _GradeRangeDialog extends HookWidget {
  final GradeRange? existing;
  const _GradeRangeDialog({this.existing});

  @override
  Widget build(BuildContext context) {
    final grade = useTextEditingController(text: existing?.grade ?? '');
    final min = useTextEditingController(
      text: existing != null ? existing!.min.toString() : '',
    );
    final max = useTextEditingController(
      text: existing != null ? existing!.max.toString() : '',
    );
    final remark = useTextEditingController(text: existing?.remark ?? '');
    final teacherRemark = useTextEditingController(
      text: existing?.teacherRemark ?? '',
    );
    final principalRemark = useTextEditingController(
      text: existing?.principalRemark ?? '',
    );
    final color = useState(existing?.color ?? '#4CAF50');
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return AlertDialog(
      title: Text(existing == null ? 'Add Grade Range' : 'Edit Grade Range'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: grade,
                      decoration: const InputDecoration(
                        labelText: 'Grade *',
                        hintText: 'A',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _ColorPickerField(
                      color: color.value,
                      onChanged: (c) => color.value = c,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: min,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v.trim()) == null) return 'Number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: max,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v.trim()) == null) return 'Number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: remark,
                decoration: const InputDecoration(
                  labelText: 'Remark',
                  hintText: 'e.g. Excellent',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: teacherRemark,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Teacher Remark',
                  hintText: 'e.g. Outstanding work! Keep it up.',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: principalRemark,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Principal's Remark",
                  hintText: 'e.g. This is an outstanding performance.',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(
              context,
              GradeRange(
                grade: grade.text.trim().toUpperCase(),
                min: int.parse(min.text.trim()),
                max: int.parse(max.text.trim()),
                color: color.value,
                remark: remark.text.trim(),
                teacherRemark: teacherRemark.text.trim(),
                principalRemark: principalRemark.text.trim(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: Text(existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

class _ColorPickerField extends HookWidget {
  final String color;
  final ValueChanged<String> onChanged;
  const _ColorPickerField({required this.color, required this.onChanged});

  static const _palette = [
    '#4CAF50',
    '#8BC34A',
    '#FFC107',
    '#FF9800',
    '#FF5722',
    '#2196F3',
    '#9C27B0',
    '#F44336',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('Pick a colour'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _palette.map((hex) {
                    final c = _hexColor(hex);
                    return GestureDetector(
                      onTap: () => Navigator.pop(ctx, hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hex == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _hexColor(color),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Colour', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Custom Subjects
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectsSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _SubjectsSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = useState<List<String>>(List.from(schoolInfo.customSubjects));

    Future<void> save(List<String> updated) async {
      await ref
          .read(appStateProvider.notifier)
          .updateSchoolInfo(customSubjects: updated);
    }

    Future<void> add() async {
      final result = await _showAddItemDialog(
        context,
        'Subject Name',
        'e.g. Computer Science',
      );
      if (result != null && result.isNotEmpty) {
        final all = [...SUBJECT_LIST, ...custom.value];
        if (all.contains(result)) {
          if (context.mounted) {
            context.showErrorSnackBar('Subject already exists in the list');
          }
          return;
        }
        final updated = [...custom.value, result];
        custom.value = updated;
        await save(updated);
        if (context.mounted) context.showSuccessSnackBar('Subject added');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Custom Subjects',
          subtitle: 'Add subjects beyond the built-in list',
        ),
        _card(
          children: [
            Text(
              '${SUBJECT_LIST.length} built-in subjects available.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            if (custom.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Your custom subjects:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              ...custom.value.asMap().entries.map(
                (entry) => _ItemRow(
                  label: entry.value,
                  onDelete: () async {
                    final updated = [...custom.value]..removeAt(entry.key);
                    custom.value = updated;
                    await save(updated);
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            _AddButton(label: 'Add Custom Subject', onTap: add),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Custom Classes
// ─────────────────────────────────────────────────────────────────────────────

class _CustomClassesSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _CustomClassesSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = useState<List<String>>(List.from(schoolInfo.customClasses));

    Future<void> save(List<String> updated) async {
      await ref
          .read(appStateProvider.notifier)
          .updateSchoolInfo(customClasses: updated);
    }

    Future<void> add() async {
      final result = await _showAddItemDialog(
        context,
        'Class Name',
        'e.g. Primary 1A',
      );
      if (result != null && result.isNotEmpty) {
        final updated = [...custom.value, result];
        custom.value = updated;
        await save(updated);
        if (context.mounted) context.showSuccessSnackBar('Class added');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Custom Class Names',
          subtitle: 'Add class name templates for quick selection',
        ),
        _card(
          children: [
            const Text(
              'Class names are free-form when creating a class. Add templates here for convenience.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            if (custom.value.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...custom.value.asMap().entries.map(
                (entry) => _ItemRow(
                  label: entry.value,
                  onDelete: () async {
                    final updated = [...custom.value]..removeAt(entry.key);
                    custom.value = updated;
                    await save(updated);
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            _AddButton(label: 'Add Class Template', onTap: add),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section: Display Options
// ─────────────────────────────────────────────────────────────────────────────

class _DisplayOptionsSection extends HookConsumerWidget {
  final SchoolInfo schoolInfo;
  const _DisplayOptionsSection({required this.schoolInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Display Options'),
        _card(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show Final Position',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Display class ranking on result sheets and broad sheets',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: schoolInfo.showFinalPosition,
                  activeTrackColor: const Color(0xFF2563EB),
                  onChanged: (val) async {
                    await ref
                        .read(appStateProvider.notifier)
                        .updateSchoolInfo(showFinalPosition: val);
                    if (context.mounted) {
                      context.showSuccessSnackBar(
                        val
                            ? 'Final position enabled'
                            : 'Final position hidden',
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _ItemRow({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFF2563EB)),
            SizedBox(width: 6),
            Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _hexColor(String hex) {
  final h = hex.toUpperCase().replaceAll('#', '');
  return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
}

Future<String?> _showAddItemDialog(
  BuildContext context,
  String label,
  String hint,
) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Add $label'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
