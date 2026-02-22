import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';

void launchPhoneNumber(String phoneNumber) async {
  if (phoneNumber.replaceAll('-', '').trim().isEmpty) return;
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);
  try {
    await launchUrl(url);
  } catch (e) {
    log('Could not launch $url');
  }
}

void launchEmail(String email) async {
  if (email.trim().isEmpty) return;
  final Uri url = Uri(scheme: 'mailto', path: email);
  try {
    await launchUrl(url);
  } catch (e) {
    log('Could not launch $url');
  }
}

void kLaunchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

void kLaunchUrlInAppBrowser(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } else {
    throw 'Could not launch $uri';
  }
}

void kLaunchUrlExternalApplication(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}
