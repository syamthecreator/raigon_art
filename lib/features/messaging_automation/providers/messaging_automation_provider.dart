
import 'package:flutter/foundation.dart';
import '../models/automation_model.dart';

class MessagingAutomationProvider extends ChangeNotifier {
  bool _instagramConnected = false;
  bool _whatsappConnected = false;

  bool get instagramConnected => _instagramConnected;
  bool get whatsappConnected => _whatsappConnected;

  final List<AutomationModel> _automations = [
    const AutomationModel(
      id: '1',
      name: 'Welcome Message',
      channel: AutomationChannel.instagram,
      trigger: 'First direct message',
      reply: 'Hi! Welcome to Raigon Art.',
      status: AutomationStatus.draft,
    ),
    const AutomationModel(
      id: '2',
      name: 'Frame Price Enquiry',
      channel: AutomationChannel.whatsapp,
      trigger: 'Keyword: price',
      reply: 'Thanks for your interest! Contact us for frame pricing.',
      status: AutomationStatus.draft,
    ),
  ];

  List<AutomationModel> get automations =>
      List.unmodifiable(_automations);

  void setConnected(AutomationChannel channel, bool connected) {
    if (channel == AutomationChannel.instagram) {
      _instagramConnected = connected;
    } else {
      _whatsappConnected = connected;
    }
    notifyListeners();
  }

  void addAutomation(AutomationModel automation) {
    _automations.insert(0, automation);
    notifyListeners();
  }

  void toggleStatus(String id) {
    final index = _automations.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = _automations[index];

    _automations[index] = item.copyWith(
      status: item.status == AutomationStatus.active
          ? AutomationStatus.paused
          : AutomationStatus.active,
    );

    notifyListeners();
  }

  void deleteAutomation(String id) {
    _automations.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
