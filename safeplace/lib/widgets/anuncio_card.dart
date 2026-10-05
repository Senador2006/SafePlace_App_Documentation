import 'package:flutter/material.dart';
import 'package:safeplace/models/anuncio.dart';
import 'package:safeplace/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AnuncioCard extends StatelessWidget {
  const AnuncioCard({super.key, required this.anuncio});

  final Anuncio anuncio;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SafePlaceColors.panel,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _abrir(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(anuncio.icone, color: SafePlaceColors.safeBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patrocinado',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.6,
                        color: SafePlaceColors.alertPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anuncio.titulo,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: SafePlaceColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      anuncio.texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 1.35,
                        color: SafePlaceColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                size: 16,
                color: SafePlaceColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context) async {
    final uri = Uri.parse(anuncio.url);
    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu && context.mounted) {
        _avisar(context);
      }
    } catch (_) {
      if (context.mounted) _avisar(context);
    }
  }

  void _avisar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o link.')),
    );
  }
}
