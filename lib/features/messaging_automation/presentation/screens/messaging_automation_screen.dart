import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/features/messaging_automation/providers/messaging_automation_provider.dart';

class MessagingAutomationScreen extends StatelessWidget {
  const MessagingAutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Consumer<MessagingAutomationProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messaging Automation',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage customer conversations in one place.',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Connected channels',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 750 ? 2 : 1;
                  final cardWidth =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _ChannelCard(
                          title: 'Instagram',
                          subtitle: 'Direct messages and keyword replies',
                          icon: Icons.camera_alt_outlined,
                          color: const Color(0xFFE1306C),
                          connected: provider.instagramConnected,
                          onConnect: () =>
                              _showConnectionInfo(context, 'Instagram'),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _ChannelCard(
                          title: 'WhatsApp',
                          subtitle: 'Customer messages and order enquiries',
                          icon: Icons.chat_outlined,
                          color: const Color(0xFF168B55),
                          connected: provider.whatsappConnected,
                          onConnect: () =>
                              _showConnectionInfo(context, 'WhatsApp'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConnectionInfo(BuildContext context, String channel) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Connect $channel'),
        content: Text(
          'The $channel Meta API connection has not been configured yet. '
          'Complete the official Meta setup before enabling real messaging.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configure the $channel API to continue.'),
                ),
              );
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.connected,
    required this.onConnect,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool connected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: connected
                      ? Colors.green.withValues(alpha: 0.12)
                      : palette.pageBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  connected ? 'Connected' : 'Not connected',
                  style: TextStyle(
                    color: connected ? Colors.green : palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: palette.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onConnect,
            icon: Icon(
              connected ? Icons.settings_outlined : Icons.link,
              size: 17,
            ),
            label: Text(connected ? 'Manage connection' : 'Set up channel'),
          ),
        ],
      ),
    );
  }
}
