
enum AutomationChannel { instagram, whatsapp }

enum AutomationStatus { active, draft, paused }

class AutomationModel {
  const AutomationModel({
    required this.id,
    required this.name,
    required this.channel,
    required this.trigger,
    required this.reply,
    required this.status,
  });

  final String id;
  final String name;
  final AutomationChannel channel;
  final String trigger;
  final String reply;
  final AutomationStatus status;

  AutomationModel copyWith({
    String? name,
    String? trigger,
    String? reply,
    AutomationStatus? status,
  }) {
    return AutomationModel(
      id: id,
      name: name ?? this.name,
      channel: channel,
      trigger: trigger ?? this.trigger,
      reply: reply ?? this.reply,
      status: status ?? this.status,
    );
  }
}
