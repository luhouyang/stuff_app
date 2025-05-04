import 'package:flutter/material.dart';
import 'package:stuff_app/widgets/texts/snack_bar_text.dart';
import 'package:stuff_app/widgets/ui_color.dart';
import 'package:url_launcher/url_launcher.dart';

class SmallAboutPage extends StatelessWidget {
  const SmallAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> launchUrlAsync(String urlString) async {
      final Uri url = Uri.parse(urlString);

      if (!await launchUrl(url)) {
        if (context.mounted) {
          SnackBarText().showBanner(msg: 'Could not launch $url', context: context);
        }
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text('By: LU HOU YANG'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        launchUrlAsync("https://www.luhouyang.com/");
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 36, right: 36),
                        child: Text(
                          'WEBSITE',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium!.copyWith(color: UIColor().darkGray),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
