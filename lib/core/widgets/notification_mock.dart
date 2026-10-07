enum NotificationType { completed, due }

class NotificationItem {
  const NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.meta,
    required this.tag,
  });

  final NotificationType type;
  final String title;
  final String message;
  final String meta;
  final String tag;
}

const List<NotificationItem> mockNotifications = [
  NotificationItem(
    type: NotificationType.completed,
    title: 'Work Completed: #RA-1002 🖼️',
    message: 'Framing job for Fathima (8 × 12 inch) is completed & ready!',
    meta: 'Status: Completed • Phone: 7902261255',
    tag: 'Ready',
  ),
  NotificationItem(
    type: NotificationType.completed,
    title: 'Work Completed: #RA-1004 🖼️',
    message: 'Framing job for Ananya Nair (20 × 30 inch) is completed & ready!',
    meta: 'Status: Completed • Phone: 7902261255',
    tag: 'Ready',
  ),
  NotificationItem(
    type: NotificationType.completed,
    title: 'Work Completed: #RA-0995 🖼️',
    message: 'Framing job for Suresh Nair (12 × 18 inch) is completed & ready!',
    meta: 'Status: Completed • Phone: 9847011223',
    tag: 'Ready',
  ),
  NotificationItem(
    type: NotificationType.completed,
    title: 'Work Completed: #RA-0988 🖼️',
    message: 'Framing job for Meera Das (10 × 14 inch) is completed & ready!',
    meta: 'Status: Completed • Phone: 9847055120',
    tag: 'Ready',
  ),
  NotificationItem(
    type: NotificationType.due,
    title: 'Payment Due: #RA-1003 ⚠️',
    message: 'Rahul Raj has a pending balance of ₹12,000 for the order.',
    meta: 'Status: Pending • Phone: 7902261255',
    tag: 'Due',
  ),
  NotificationItem(
    type: NotificationType.due,
    title: 'Payment Due: #RA-1001 ⚠️',
    message: 'Arun Kumar has a pending balance of ₹4,500 for the order.',
    meta: 'Status: In Progress • Phone: 7902261255',
    tag: 'Due',
  ),
  NotificationItem(
    type: NotificationType.due,
    title: 'Payment Due: #RA-0999 ⚠️',
    message: 'Joseph Mathew has a pending balance of ₹3,200 for the order.',
    meta: 'Status: Pending • Phone: 9847099001',
    tag: 'Due',
  ),
];
