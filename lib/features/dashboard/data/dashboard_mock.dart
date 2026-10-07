enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class FrameOrder {
  const FrameOrder({
    required this.id,
    required this.name,
    required this.city,
    required this.phone,
    required this.frameSize,
    required this.frameType,
    required this.qty,
    required this.total,
    required this.status,
  });

  final String id;
  final String name;
  final String city;
  final String phone;
  final String frameSize;
  final String frameType;
  final int qty;
  final String total;
  final OrderStatus status;
}

const String mockTotalOrders = '7';
const String mockInProgress = '1';
const String mockCompleted = '4';
const String mockPending = '1';
const String mockRevenue = '₹38,500';

const List<FrameOrder> mockRecentOrders = [
  FrameOrder(
    id: 'RA-1001',
    name: 'Arun Kumar',
    city: 'Trivandrum',
    phone: '7902261255',
    frameSize: '12 × 18 inch',
    frameType: 'Wooden Frame',
    qty: 2,
    total: '₹4,500',
    status: OrderStatus.inProgress,
  ),
  FrameOrder(
    id: 'RA-1002',
    name: 'Fathima',
    city: 'Kochi',
    phone: '7902261255',
    frameSize: '8 × 12 inch',
    frameType: 'Premium Frame',
    qty: 1,
    total: '₹2,200',
    status: OrderStatus.completed,
  ),
  FrameOrder(
    id: 'RA-1003',
    name: 'Rahul Raj',
    city: 'Kollam',
    phone: '7902261255',
    frameSize: '16 × 20 inch',
    frameType: 'Classic Frame',
    qty: 4,
    total: '₹12,000',
    status: OrderStatus.pending,
  ),
  FrameOrder(
    id: 'RA-1004',
    name: 'Ananya Nair',
    city: 'Kozhikode',
    phone: '7902261255',
    frameSize: '20 × 30 inch',
    frameType: 'Canvas Float',
    qty: 1,
    total: '₹6,800',
    status: OrderStatus.completed,
  ),
  FrameOrder(
    id: 'RA-1005',
    name: 'Deepak Varma',
    city: 'Kottayam',
    phone: '7902261255',
    frameSize: '8 × 10 inch',
    frameType: 'Box Frame',
    qty: 3,
    total: '₹3,600',
    status: OrderStatus.cancelled,
  ),
];
