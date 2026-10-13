import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<void> upsert(Customer customer);
  Future<void> delete(String id);
}

class FirestoreCustomerRepository implements CustomerRepository {
  FirestoreCustomerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _firestore.collection('customers');

  @override
  Future<List<Customer>> getAll() async {
    debugPrint('[CustomerRepository] Fetching customers from Firestore...');

    try {
      final snapshot = await _customers.get();

      debugPrint(
        '[CustomerRepository] Documents received: ${snapshot.docs.length}',
      );

      final customers = <Customer>[];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          debugPrint('[CustomerRepository] Parsing document: ${doc.id}');
          debugPrint('[CustomerRepository] Fields: ${data.keys.toList()}');

          final customer = Customer.fromJson({...data, 'id': doc.id});

          customers.add(customer);
          debugPrint(
            '[CustomerRepository] Parsed successfully: '
            '${customer.id} - ${customer.name}',
          );
        } catch (error, stackTrace) {
          debugPrint('[CustomerRepository] Failed to parse ${doc.id}: $error');
          debugPrintStack(stackTrace: stackTrace);
          rethrow;
        }
      }

      debugPrint(
        '[CustomerRepository] Successfully loaded ${customers.length} customers.',
      );

      return customers;
    } catch (error, stackTrace) {
      debugPrint('[CustomerRepository] Firestore load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> upsert(Customer customer) async {
    try {
      final data = customer.toJson()..remove('id');

      await _customers.doc(customer.id).set(data);
    } catch (error, stackTrace) {
      debugPrint('Failed to save customer ${customer.id}: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _customers.doc(id).delete();
    } catch (error, stackTrace) {
      debugPrint('Failed to delete customer $id: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
