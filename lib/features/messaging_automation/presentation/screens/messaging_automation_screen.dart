
import 'package:flutter/material.dart';

class MessagingAutomationScreen extends StatefulWidget {
  const MessagingAutomationScreen({super.key});

  @override
  State<MessagingAutomationScreen> createState() =>
      _MessagingAutomationScreenState();
}

class _MessagingAutomationScreenState
    extends State<MessagingAutomationScreen> {
  int _selectedChannel = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messaging Automation',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage Instagram and WhatsApp automation.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _channelButton(
                label: 'Instagram',
                icon: Icons.camera_alt_outlined,
                index: 0,
              ),
              _channelButton(
                label: 'WhatsApp',
                icon: Icons.chat_outlined,
                index: 1,
              ),
            ],
          ),

          const SizedBox(height: 32),

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedChannel == 0
                        ? Icons.camera_alt_outlined
                        : Icons.chat_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedChannel == 0
                        ? 'Connect Instagram'
                        : 'Connect WhatsApp',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect your Meta account to get started.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelButton({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final selected = _selectedChannel == index;

    return ChoiceChip(
      selected: selected,
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onSelected: (_) {
        setState(() => _selectedChannel = index);
      },
    );
  }
}
