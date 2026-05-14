import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makeCallPhone(String phoneNumber) async {
  final url = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    debugPrint('Could not launch $url');
  }
}
