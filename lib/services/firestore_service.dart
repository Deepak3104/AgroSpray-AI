import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) => _firestore.collection(path);

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    return _firestore.collection(collectionPath).doc(documentId).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  Future<void> deleteDocument({required String collectionPath, required String documentId}) {
    return _firestore.collection(collectionPath).doc(documentId).delete();
  }
}
