import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<BlogEntity> signals;
  final bool hasMore;
  final bool isLoadingMore;
  final DocumentSnapshot? lastVisible;
  final String? category;
  final String? searchQuery;

  const ExploreLoaded({
    required this.signals,
    required this.hasMore,
    this.isLoadingMore = false,
    this.lastVisible,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        signals,
        hasMore,
        isLoadingMore,
        lastVisible,
        category,
        searchQuery,
      ];

  ExploreLoaded copyWith({
    List<BlogEntity>? signals,
    bool? hasMore,
    bool? isLoadingMore,
    DocumentSnapshot? lastVisible,
    String? category,
    String? searchQuery,
  }) {
    return ExploreLoaded(
      signals: signals ?? this.signals,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      lastVisible: lastVisible ?? this.lastVisible,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object> get props => [message];
}
