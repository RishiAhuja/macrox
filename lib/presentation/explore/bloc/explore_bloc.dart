import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/presentation/explore/bloc/explore_event.dart';
import 'package:blog/presentation/explore/bloc/explore_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 12;

  ExploreBloc() : super(ExploreInitial()) {
    on<LoadExploreSignals>(_onLoadExploreSignals);
    on<LoadMoreExploreSignals>(_onLoadMoreExploreSignals);
  }

  Future<void> _onLoadExploreSignals(
    LoadExploreSignals event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      emit(ExploreLoading());

      // Simplify the query to avoid index issues
      Query query = _firestore.collection('Blogs');

      // Filter by published status only - avoid compound queries that need indices
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        // For search, use a simple query on title without composite indexes
        query = _firestore
            .collection('Blogs')
            .where('status', isEqualTo: "up")
            .orderBy('title')
            .startAt([event.searchQuery]).endAt(
                ['${event.searchQuery}\uf8ff']).limit(_pageSize);
      } else {
        // Basic query without ordering for now
        query = _firestore
            .collection('Blogs')
            .where('status', isEqualTo: "up")
            .limit(_pageSize);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        emit(const ExploreLoaded(
          signals: [],
          hasMore: false,
        ));
        return;
      }

      final signals = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Safe extraction with type checking
        List<String> extractStringList(dynamic field) {
          List<String> result = [];

          if (field == null) return result;

          if (field is List) {
            // Process each item to ensure they are strings
            for (var item in field) {
              if (item is String) {
                result.add(item);
              } else if (item != null) {
                // Convert non-null items to string
                result.add(item.toString());
              }
            }
          } else if (field is Map) {
            // For maps, use keys as the list items (Firebase sometimes stores like this)
            field.keys.forEach((key) {
              if (key is String) {
                result.add(key);
              } else if (key != null) {
                result.add(key.toString());
              }
            });
          } else if (field is String) {
            // Single string
            result.add(field);
          }

          return result;
        }

        // Extract authors and likedBy using the safe function
        List<String> authors = extractStringList(data['authors']);
        List<String> likedBy = extractStringList(data['likedBy']);

        // Safe access for all fields with fallbacks
        return BlogEntity(
          uid: doc.id,
          content: data['content'] is String ? data['content'] : '',
          htmlPreview: data['htmlPreview'] is String ? data['htmlPreview'] : '',
          title: data['title'] is String ? data['title'] : '',
          userUid: data['userUid'] is String ? data['userUid'] : '',
          authorUid: data['authorUid'] is String ? data['authorUid'] : '',
          authors: authors,
          likedBy: likedBy,
          publishedTimestamp:
              data['status'] == 'up', // Convert status to boolean
        );
      }).toList();

      emit(ExploreLoaded(
        signals: signals,
        hasMore: querySnapshot.docs.length >= _pageSize,
        lastVisible:
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
      ));
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }

  Future<void> _onLoadMoreExploreSignals(
    LoadMoreExploreSignals event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;

        emit(currentState.copyWith(isLoadingMore: true));

        // Simplify the query to avoid index issues
        Query query;

        if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
          // Search query with pagination
          query = _firestore
              .collection('Blogs')
              .where('status', isEqualTo: "up")
              .orderBy('title')
              .startAt([event.searchQuery]);

          // Add startAfter only if we have a last document
          if (event.lastVisible != null) {
            // For search queries, we need to start after in the ordered field
            final lastDocData =
                event.lastVisible!.data() as Map<String, dynamic>?;
            if (lastDocData != null && lastDocData.containsKey('title')) {
              String lastTitle =
                  lastDocData['title'] is String ? lastDocData['title'] : '';
              query = query.startAfter([lastTitle]);
            }
          }

          query = query.endAt(['${event.searchQuery}\uf8ff']).limit(_pageSize);
        } else {
          // Basic query with pagination
          query = _firestore
              .collection(
                  'Blogs') // Make sure this matches the collection name above
              .where('status',
                  isEqualTo: "up"); // Use the same field name as above

          // Add startAfter only if we have a last document
          if (event.lastVisible != null) {
            query = query.startAfterDocument(event.lastVisible!);
          }

          query = query.limit(_pageSize);
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {
          emit(currentState.copyWith(
            hasMore: false,
            isLoadingMore: false,
          ));
          return;
        }

        final newSignals = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Safe extraction with type checking
          List<String> extractStringList(dynamic field) {
            List<String> result = [];

            if (field == null) return result;

            if (field is List) {
              // Process each item to ensure they are strings
              for (var item in field) {
                if (item is String) {
                  result.add(item);
                } else if (item != null) {
                  // Convert non-null items to string
                  result.add(item.toString());
                }
              }
            } else if (field is Map) {
              // For maps, use keys as the list items (Firebase sometimes stores like this)
              field.keys.forEach((key) {
                if (key is String) {
                  result.add(key);
                } else if (key != null) {
                  result.add(key.toString());
                }
              });
            } else if (field is String) {
              // Single string
              result.add(field);
            }

            return result;
          }

          // Extract authors and likedBy using the safe function
          List<String> authors = extractStringList(data['authors']);
          List<String> likedBy = extractStringList(data['likedBy']);

          // Safe access for all fields with fallbacks
          return BlogEntity(
            uid: doc.id,
            content: data['content'] is String ? data['content'] : '',
            htmlPreview:
                data['htmlPreview'] is String ? data['htmlPreview'] : '',
            title: data['title'] is String ? data['title'] : '',
            userUid: data['userUid'] is String ? data['userUid'] : '',
            authorUid: data['authorUid'] is String ? data['authorUid'] : '',
            authors: authors,
            likedBy: likedBy,
            publishedTimestamp:
                data['status'] == 'up', // Convert status to boolean
          );
        }).toList();

        emit(currentState.copyWith(
          signals: [...currentState.signals, ...newSignals],
          hasMore: querySnapshot.docs.length >= _pageSize,
          isLoadingMore: false,
          lastVisible: querySnapshot.docs.isNotEmpty
              ? querySnapshot.docs.last
              : currentState.lastVisible,
        ));
      }
    } catch (e) {
      if (state is ExploreLoaded) {
        emit((state as ExploreLoaded).copyWith(isLoadingMore: false));
      } else {
        emit(ExploreError(e.toString()));
      }
    }
  }
}
