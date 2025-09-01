import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalInfoDialog extends StatelessWidget {
  const AdditionalInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Дополнительная информация'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              final url = Uri.parse('https://danilmashina.github.io/Mysite/mobile-app.html');
              if (await launchUrl(url)) {
                // Launched successfully
              } else {
                // Handle error, e.g., show a SnackBar
              }
            },
            child: const Text('Официальный сайт'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close current dialog
              showDialog(
                context: context,
                builder: (context) => const TermsDialogContent(),
              );
            },
            child: const Text('Условия использования'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close current dialog
              showDialog(
                context: context,
                builder: (context) => const AboutDialogContent(),
              );
            },
            child: const Text('О приложении'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close current dialog
              showModalBottomSheet(
                context: context,
                builder: (context) => const HelpBottomSheetContent(),
              );
            },
            child: const Text('Описание функционала'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
