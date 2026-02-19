import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';
import 'package:grade_vault_offline/src/features/home/data/models/models.dart';

class ClassCard extends HookWidget {
  final ClassSection classSection;
  final int noOfStudents;
  final VoidCallback onTap;
  const ClassCard({
    super.key,
    required this.classSection,
    required this.noOfStudents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);

    final String className = classSection.name;
    final String teacherName = classSection.teacherName;
    final String session = classSection.session;
    final int noOfSubjects = classSection.subjectNames.length;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: BorderedCard(
          borderColor: isHovering.value
              ? AppColors.blue500
              : AppColors.neutral200,
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StyledText(
                    className,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  const Icon(Icons.chevron_right, size: 24),
                ],
              ),
              StyledText(teacherName),
              StyledText(session, fontSize: 12, color: AppColors.neutral600),
              const Divider(color: AppColors.neutral200, height: .5),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_2,
                    size: 16,
                    color: AppColors.neutral600,
                  ),
                  const XGap(4),
                  StyledText('$noOfStudents Students'),
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.book,
                    size: 16,
                    color: AppColors.neutral600,
                  ),
                  const XGap(4),
                  StyledText('$noOfSubjects Subjects'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
