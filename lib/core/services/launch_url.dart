import 'package:url_launcher/url_launcher.dart';

import '/../core/functions/debug_print_extension.dart';

Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    'Error opening $url'.dPrint();
  }
}
