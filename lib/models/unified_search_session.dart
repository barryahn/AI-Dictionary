import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnifiedSearchSession {
  final dynamic id; // int (로컬) 또는 String (Firestore)
  final String sessionName;
  final DateTime createdAt;
  final List<UnifiedSearchCard> cards;
  final bool isFromFirestore;

  UnifiedSearchSession({
    required this.id,
    required this.sessionName,
    required this.createdAt,
    required this.cards,
    required this.isFromFirestore,
  });

  // 로컬 SearchSession에서 변환
  factory UnifiedSearchSession.fromLocalSearchSession(SearchSession session) {
    return UnifiedSearchSession(
      id: session.id,
      sessionName: session.sessionName,
      createdAt: session.createdAt,
      cards: session.cards
          .map((card) => UnifiedSearchCard.fromLocalSearchCard(card))
          .toList(),
      isFromFirestore: false,
    );
  }

  // Firestore 데이터에서 변환
  factory UnifiedSearchSession.fromFirestoreData(Map<String, dynamic> data) {
    final cards = (data['cards'] as List<dynamic>? ?? []).map((cardData) {
      return UnifiedSearchCard.fromFirestoreData(cardData);
    }).toList();

    return UnifiedSearchSession(
      id: data['id'],
      sessionName: data['sessionName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cards: cards,
      isFromFirestore: true,
    );
  }
}

class UnifiedSearchCard {
  final dynamic id; // int (로컬) 또는 String (Firestore)
  final String query;
  final String result;
  final bool isLoading;
  final DateTime createdAt;
  final bool isFromFirestore;

  UnifiedSearchCard({
    required this.id,
    required this.query,
    required this.result,
    required this.isLoading,
    required this.createdAt,
    required this.isFromFirestore,
  });

  // 로컬 SearchCard에서 변환
  factory UnifiedSearchCard.fromLocalSearchCard(SearchCard card) {
    return UnifiedSearchCard(
      id: card.id,
      query: card.query,
      result: card.result,
      isLoading: card.isLoading,
      createdAt: card.createdAt,
      isFromFirestore: false,
    );
  }

  // Firestore 데이터에서 변환
  factory UnifiedSearchCard.fromFirestoreData(Map<String, dynamic> data) {
    return UnifiedSearchCard(
      id: data['id'],
      query: data['query'] ?? '',
      result: data['result'] ?? '',
      isLoading: data['isLoading'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFromFirestore: true,
    );
  }
}
