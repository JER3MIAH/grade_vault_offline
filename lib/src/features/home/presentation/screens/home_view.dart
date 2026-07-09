import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:grade_vault_offline/src/core/navigation/app_routes.dart';
import 'package:grade_vault_offline/src/features/home/presentation/providers/providers.dart';
import 'package:grade_vault_offline/src/features/home/presentation/widgets/widgets.dart';
import 'package:grade_vault_offline/src/features/settings/data/datasources/user_local_datasource.dart';
import 'package:grade_vault_offline/src/shared/shared.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final datasource = ref.read(userLocalDatasourceProvider);
        final shouldShow = await datasource.checkAndIncrementForSupportPrompt();
        if (shouldShow && context.mounted) {
          context.showDialog(const SupportPromptDialog());
        }
      });
      return null;
    }, []);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'GradeVault',
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bars, color: KitColors.white),
            onPressed: () {
              context.showDialog(const BackupDataDialog());
            },
          ),
          const XGap(10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SavedLocallyDisplay(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText('All Classes'),
                      StyledText('Manage your classes and students'),
                    ],
                  ),
                  PrimaryButton(
                    title: 'Add Class',
                    icon: Icons.add,
                    iconOnly: context.isMobile,
                    onTap: () async {
                      context.showDialog(const CreateNewClassDialog());
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;

                  final columns = switch (maxWidth) {
                    >= 1200 => 4,
                    >= 800 => 3,
                    >= 600 => 2,
                    _ => 1,
                  };

                  final spacing = 12.0;
                  final itemWidth =
                      (maxWidth - (spacing * (columns - 1))) / columns;

                  // Display class cards from appState
                  final List<Widget> classCards =
                      appState.classSections.isNotEmpty
                      ? appState.classSections.map((classSection) {
                          final noOfStudents = appState.studentRecords
                              .where(
                                (record) => record.classId == classSection.id,
                              )
                              .length;
                          return SizedBox(
                            width: itemWidth,
                            child: ClassCard(
                              classSection: classSection,
                              noOfStudents: noOfStudents,
                              onTap: () {
                                notifier.selectClass(classSection.id);
                                context.pushNamed(AppRoutes.classView);
                              },
                            ),
                          );
                        }).toList()
                      : [];

                  return appState.classSections.isEmpty
                      ? const EmptyClassesWidget()
                      : Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          alignment: WrapAlignment.start,
                          spacing: spacing,
                          runSpacing: spacing,
                          children: classCards,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyClassesWidget extends StatelessWidget {
  const EmptyClassesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BorderedCard(
            padding: const EdgeInsets.all(40),
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.book,
                  size: 64,
                  color: KitColors.neutral400,
                ),
                const StyledText(
                  'No classes Yet',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                const StyledText(
                  'Get started by creating your first class',
                  fontSize: 14,
                  color: KitColors.neutral600,
                  textAlign: TextAlign.center,
                ),
                const YGap(8),
                PrimaryButton(
                  title: 'Create New Class',
                  icon: Icons.add,
                  onTap: () {
                    context.showDialog(const CreateNewClassDialog());
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
