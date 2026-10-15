
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raigon_art/features/customers/models/customer_model.dart';
import 'package:raigon_art/features/customers/service/customer_image_storage.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<void> upsert(Customer customer);
  Future<void> delete(String id);
}

class FirestoreCustomerRepository implements CustomerRepository {
  FirestoreCustomerRepository({
    FirebaseFirestore? firestore,
    CustomerImageStorage? imageStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _imageStorage = imageStorage ?? CustomerImageStorage();

  final FirebaseFirestore _firestore;
  final CustomerImageStorage _imageStorage;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _firestore.collection('customers');

  @override
  Future<List<Customer>> getAll() async {
    try {
      final snapshot = await _customers.get();
      final customers = <Customer>[];

      for (final doc in snapshot.docs) {
        final customer = Customer.fromJson({
          ...doc.data(),
          'id': doc.id,
        });

        customers.add(await _imageStorage.attach(customer));
      }

      debugPrint('[Customers] Loaded ${customers.length} records.');
      return customers;
    } catch (error) {
      debugPrint('[Customers] Load failed: $error');
      rethrow;
    }
  }

  @override
  Future<void> upsert(Customer customer) async {
    try {
      // Images stay in this browser's local storage.
      await _imageStorage.save(customer);

      final data = customer.toJson()
        ..remove('id')
        ..remove('photoBytes');

      // Image bytes and Storage URLs are not saved in Firestore.
      data['photoUrls'] = [];
      data['frames'] = [
        for (final frame in customer.frames)
          {
            ...frame.toJson(),
            'photoUrl': null,
          },
      ];

      await _customers.doc(customer.id).set(data);

      debugPrint('[Customers] Saved ${customer.id}.');
    } catch (error) {
      debugPrint('[Customers] Save failed (${customer.id}): $error');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _customers.doc(id).delete();
      await _imageStorage.delete(id);

      debugPrint('[Customers] Deleted $id.');
    } catch (error) {
      debugPrint('[Customers] Delete failed ($id): $error');
      rethrow;
    }
  }
}
