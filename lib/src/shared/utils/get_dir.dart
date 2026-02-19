import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory?> getDir() async {
  if (Platform.isWindows) {
    return await getDownloadsDirectory();
  } else if (Platform.isAndroid || Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  } else if (Platform.isLinux || Platform.isMacOS) {
    return await getApplicationDocumentsDirectory();
  } else {
    return null;
  }
}
