import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/presentation/explore/bloc/explore_bloc.dart';
import 'package:blog/presentation/explore/bloc/explore_event.dart';
import 'package:blog/presentation/explore/bloc/explore_state.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class ExplorePage extends StatelessWidget {
  final bool showAppBar;

  const ExplorePage({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreBloc()..add(const LoadExploreSignals()),
      child: ExplorePageContent(showAppBar: showAppBar),
    );
  }
}

class ExplorePageContent extends StatefulWidget {
  final bool showAppBar;

  const ExplorePageContent({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<ExplorePageContent> createState() => _ExplorePageContentState();
}

class _ExplorePageContentState extends State<ExplorePageContent> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ExploreBloc>().state;
      if (state is ExploreLoaded && !state.isLoadingMore && state.hasMore) {
        context.read<ExploreBloc>().add(LoadMoreExploreSignals(
              lastVisible: state.lastVisible,
              category: _selectedCategory == 'All' ? null : _selectedCategory,
              searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
      appBar: widget.showAppBar
          ? BasicAppBar(
              isLanding: false,
              customActionWidgetPrefix: _showSearchBar
                  ? Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.spaceGrotesk(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search signals...',
                          hintStyle: GoogleFonts.spaceGrotesk(
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _showSearchBar = false;
                              });
                              context.read<ExploreBloc>().add(
                                    LoadExploreSignals(
                                      category: _selectedCategory == 'All'
                                          ? null
                                          : _selectedCategory,
                                    ),
                                  );
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          context.read<ExploreBloc>().add(
                                LoadExploreSignals(
                                  category: _selectedCategory == 'All'
                                      ? null
                                      : _selectedCategory,
                                  searchQuery: value.isEmpty ? null : value,
                                ),
                              );
                        },
                        autofocus: true,
                      ),
                    )
                  : null,
              customActionWidgetSuffix: IconButton(
                icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
                tooltip: _showSearchBar ? 'Cancel search' : 'Search signals',
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                    if (!_showSearchBar) {
                      _searchQuery = '';
                      _searchController.clear();
                      context.read<ExploreBloc>().add(
                            LoadExploreSignals(
                              category: _selectedCategory == 'All'
                                  ? null
                                  : _selectedCategory,
                            ),
                          );
                    }
                  });
                },
              ),
            )
          : null,
      body: Column(
        children: [
          // Network Pulse Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? NexusColors.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NexusColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.explore,
                        color: NexusColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Explore Signals',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover trending topics and interesting signals across the network',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                if (state is ExploreInitial || state is ExploreLoading) {
                  return _buildLoadingState();
                } else if (state is ExploreLoaded) {
                  if (state.signals.isEmpty) {
                    return _buildEmptyState(isDark);
                  }
                  return _buildSignalsList(state, isDark);
                } else if (state is ExploreError) {
                  return _buildErrorState(state.message, isDark);
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/editor');
        },
        backgroundColor: NexusColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'New Signal',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: NexusColors.primaryBlue,
          ),
          const SizedBox(height: 20),
          Text(
            'Scanning network signals...',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: context.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: NexusColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.satellite_alt,
                size: 56,
                color: NexusColors.primaryBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No signals found',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No signals match your search criteria. Try with different keywords.'
                  : _selectedCategory != 'All'
                      ? 'No signals found in the ${_selectedCategory} category yet. Try a different category or be the first to post!'
                      : 'No signals have been broadcast to the network yet. Be the first to create a signal!',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchQuery.isNotEmpty || _selectedCategory != 'All') {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _selectedCategory = 'All';
                  });
                  context.read<ExploreBloc>().add(LoadExploreSignals());
                } else {
                  context.go('/editor');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                _searchQuery.isNotEmpty || _selectedCategory != 'All'
                    ? Icons.refresh
                    : Icons.edit,
                size: 18,
              ),
              label: Text(
                _searchQuery.isNotEmpty || _selectedCategory != 'All'
                    ? 'Reset Filters'
                    : 'Create Signal',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: isDark ? Colors.red[300] : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ExploreBloc>().add(LoadExploreSignals(
                      category:
                          _selectedCategory == 'All' ? null : _selectedCategory,
                      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalsList(ExploreLoaded state, bool isDark) {
    return ResponsiveLayout(
      mobileWidget: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.signals.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.signals.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    NexusColors.primaryBlue,
                  ),
                ),
              ),
            );
          }
          final signal = state.signals[index];
          return _buildSignalCard(signal, isDark, true);
        },
      ),
      desktopWidget: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.signals.length + (state.isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= state.signals.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    NexusColors.primaryBlue,
                  ),
                ),
              ),
            );
          }
          final signal = state.signals[index];
          return _buildSignalCard(signal, isDark, false);
        },
      ),
    );
  }

  Widget _buildSignalCard(BlogEntity signal, bool isDark, bool isMobile) {
    final date = DateTime.now();
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 0),
      decoration: BoxDecoration(
        color: isDark ? NexusColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go('/blog/@${signal.authors[0]}/${signal.uid}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with signal tag only (no category)
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .end, // Align to end since only one element
                children: [
                  // Signal tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NexusColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          size: 10,
                          color: NexusColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Signal',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: NexusColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                signal.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Preview text
              Expanded(
                child: Text(
                  _extractPreviewText(signal.content),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: isMobile ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Space to push metadata and actions to the bottom
              const Spacer(),

              const Divider(),

              // Footer with author and metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Author info
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              NexusColors.primaryBlue.withOpacity(0.2),
                          child: Text(
                            signal.authors.isNotEmpty
                                ? signal.authors[0][0].toUpperCase()
                                : '?',
                            style: GoogleFonts.spaceGrotesk(
                              color: NexusColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${signal.authors.isNotEmpty ? signal.authors[0] : "anonymous"}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formattedDate,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  color:
                                      isDark ? Colors.white60 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      // Share button
                      IconButton(
                        onPressed: () {
                          final url =
                              'https://nexus.rishia.in/#/blog/@${signal.authors[0]}/${signal.uid}';
                          Share.share(
                              '${signal.title}\n\nConnect with this signal on Nexus: $url');
                        },
                        icon: Icon(
                          Icons.share_outlined,
                          size: 16,
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                        tooltip: 'Share Signal',
                      ),

                      // Like count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 12,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${signal.likedBy.length}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractPreviewText(String content) {
    if (content.isEmpty) return '';

    String preview = content;

    // Remove markdown images
    preview = preview.replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '');

    // Handle markdown links
    preview = preview.replaceAllMapped(
        RegExp(r'\[(.*?)\]\(.*?\)'), (match) => match.group(1) ?? '');

    // Remove headings
    preview = preview.replaceAll(RegExp(r'#{1,6}\s'), '');

    // Fix bold formatting
    preview = preview.replaceAllMapped(
        RegExp(r'(\*\*|__)(.*?)(\1)'), (match) => match.group(2) ?? '');

    // Fix italic formatting
    preview = preview.replaceAllMapped(
        RegExp(r'(\*|_)(.*?)(\1)'), (match) => match.group(2) ?? '');

    // Remove code blocks
    preview = preview.replaceAll(RegExp(r'```.*?```'), '');

    // Fix inline code
    preview = preview.replaceAllMapped(
        RegExp(r'`(.*?)`'), (match) => match.group(1) ?? '');

    // Remove blockquotes
    preview = preview.replaceAll(RegExp(r'>\s'), '');

    // Clean up whitespace
    preview = preview.replaceAll(RegExp(r'\n{2,}'), ' ');
    preview = preview.replaceAll(RegExp(r'\s{2,}'), ' ');

    return preview.trim();
  }
}
