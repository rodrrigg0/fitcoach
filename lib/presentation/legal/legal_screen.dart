import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class LegalScreen extends StatelessWidget {
  final String type;

  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTerms = type == 'terms';
    final title = isTerms ? l10n.legalTermsTitle : l10n.legalPrivacyTitle;
    final content = isTerms ? l10n.legalTermsContent : l10n.legalPrivacyContent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Text(
            content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ),
      ),
    );
  }
}
