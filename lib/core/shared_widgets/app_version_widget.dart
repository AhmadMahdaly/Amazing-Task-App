import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/services/launch_url.dart';

class AppVersionWidget extends StatelessWidget {
  const AppVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchURL(appGooglePlayUrl),
      child: Align(
        alignment: Alignment.center,
        child: FutureBuilder<String>(
          future: getAppVersion(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            } else if (snapshot.hasError) {
              return const Text('');
            } else {
              return Text(
                '${snapshot.data}',
                style: AppTextStyle.style12W600.copyWith(
                  color: AppColors.white.withAlpha(50),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    return '${info.version} (${info.buildNumber})';
  }
}
