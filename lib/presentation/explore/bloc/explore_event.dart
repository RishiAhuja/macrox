import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadExploreSignals extends ExploreEvent {
  final String? category;
  final String? searchQuery;

  const LoadExploreSignals({this.category, this.searchQuery});

  @override
  List<Object?> get props => [category, searchQuery];
}

class LoadMoreExploreSignals extends ExploreEvent {
  final DocumentSnapshot? lastVisible;
  final String? category;
  final String? searchQuery;

  const LoadMoreExploreSignals({
    this.lastVisible,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [lastVisible, category, searchQuery];
}
