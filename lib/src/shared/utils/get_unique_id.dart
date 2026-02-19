import 'package:uuid/uuid.dart';

String getUniqueId() {
  final uniqueId = const Uuid().v4();
  return uniqueId;
}
