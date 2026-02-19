// import 'package:flutter/material.dart';
// import 'package:grade_vault_offline/src/shared/shared.dart';

// class DashboardCard extends StatelessWidget {
//   final String subtitle;
//   final String title;
//   final VoidCallback? onEdit;

//   const DashboardCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.onEdit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: Stack(
//         alignment: Alignment.topRight,
//         children: [
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: colorScheme.surface,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     StyledText('$title:', fontSize: 14),
//                     StyledText(
//                       subtitle,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (onEdit != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Tooltip(
//                 message: 'Edit $title',
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                   child: AppIconButton(
//                     icon: Icons.edit,
//                     onTap: onEdit,
//                     iconColor: context.colors.primary,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
