import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/router/app_router.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/domain/usecases/hive/add_usecase.dart';
import 'package:blog/domain/usecases/hive/get_all_usecase.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/home/widgets/appbar_popup.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:blog/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum SidebarItem { allSignals, drafts, published }

class Home extends StatefulWidget {
  const Home({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SidebarItem _activeSidebarItem = SidebarItem.allSignals;

  Map<String, BlogEntity> localBlogs = {};
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  bool _showOnlyPublished = false;
  bool _showOnlyDrafts = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadBlogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadBlogs() async {
    try {
      setState(() {
        isLoading = true;
      });

      final res = await sl<GetAllUsecase>()();

      setState(() {
        localBlogs = res;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading blogs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Filter blogs based on current filters
  List<BlogEntity> _filterLocalBlogs() {
    return localBlogs.values.where((blog) {
      // Apply publication filter
      if (_showOnlyPublished && !blog.publishedTimestamp) return false;
      if (_showOnlyDrafts && blog.publishedTimestamp) return false;

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return blog.title.toLowerCase().contains(query) ||
            blog.content.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  // Create a new blog
  void _createNewBlog(String userUid) {
    Uuid uuid = const Uuid();
    final blogUid = uuid.v4();
    sl<AddUsecase>()(
        params: BlogEntity(
            uid: blogUid,
            content: '',
            htmlPreview: '',
            title: '',
            userUid: userUid,
            publishedTimestamp: false));
    context.go(
      '${AppRouterConstants.newblog}/$blogUid',
      extra: {
        'userUid': userUid,
        'title': '',
        'content': '',
        'htmlPreview': '',
        'published': false
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isMobile = context.isMobile;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return const Landing();
        }

        return Scaffold(
          backgroundColor:
              isDark ? NexusColors.darkBackground : NexusColors.lightBackground,
          appBar: widget.showAppBar
              ? BasicAppBar(
                  isLanding: false,
                  customActionWidgetPrefix: appBarInfoPopup(
                      isDark,
                      state.userEntity.name,
                      state.userEntity.username,
                      state.userEntity.email,
                      state.userEntity.id))
              : null,
          drawer: isMobile
              ? _buildMobileDrawer(isDark, context, state.userEntity.id)
              : null,
          body: ResponsiveLayout(
            mobileWidget:
                _buildMobileLayout(isDark, isMobile, state.userEntity.id),
            desktopWidget:
                _buildDesktopLayout(isDark, isMobile, state.userEntity.id),
          ),
          floatingActionButton:
              _buildFloatingActionButton(isDark, state.userEntity.id),
        );
      },
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(bool isDark, bool isMobile, String userUid) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(isDark, isMobile, userUid),
          const SizedBox(height: 16),
          _buildSearchAndFilters(isDark, isMobile),
          const SizedBox(height: 16),
          _buildMobileBlogsList(isDark, isMobile, userUid),
        ],
      ),
    );
  }

  // Mobile Blogs List
  Widget _buildMobileBlogsList(bool isDark, bool isMobile, String userUid) {
    final localFilteredBlogs = _filterLocalBlogs();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Signals',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Local Blogs
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (localFilteredBlogs.isEmpty)
            _buildEmptyState(isDark, userUid)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: localFilteredBlogs.length,
              itemBuilder: (context, index) {
                final blog = localFilteredBlogs[index];
                return _buildBlogCard(
                  blogUid: blog.uid,
                  title: blog.title,
                  content: blog.content,
                  published: blog.publishedTimestamp,
                  isLocal: true,
                  isDark: isDark,
                  isMobile: isMobile,
                  onTap: () {
                    final extraData = {
                      'title': blog.title,
                      'content': blog.content,
                      'htmlPreview': blog.htmlPreview,
                      'userUid': blog.userUid,
                      'published': blog.publishedTimestamp
                    };
                    context.go(
                      '${AppRouterConstants.newblog}/${blog.uid}',
                      extra: extraData,
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 24),

          // Remote Blogs Section Title
          Text(
            'Network Signals',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Remote Blogs with fixed height for better mobile UX
          SizedBox(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userUid)
                  .collection('Blogs')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(isDark, snapshot.error.toString());
                }

                final docs = snapshot.data?.docs ?? [];
                final remoteDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Skip if already in local blogs
                  if (localBlogs.keys.toList().contains(data['uid'])) {
                    return false;
                  }

                  // Apply filters
                  if (_showOnlyPublished && !(data['published'] ?? false)) {
                    return false;
                  }
                  if (_showOnlyDrafts && (data['published'] ?? false)) {
                    return false;
                  }

                  // Apply search
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    return (data['title'] ?? '')
                            .toLowerCase()
                            .contains(query) ||
                        (data['content'] ?? '').toLowerCase().contains(query);
                  }

                  return true;
                }).toList();

                if (remoteDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No network signals found',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: remoteDocs.length,
                  itemBuilder: (context, index) {
                    final blog =
                        remoteDocs[index].data() as Map<String, dynamic>;
                    return _buildBlogCard(
                      blogUid: blog['uid'],
                      title: blog['title'] ?? '',
                      content: blog['content'] ?? '',
                      published: blog['published'] ?? false,
                      isLocal: false,
                      isDark: isDark,
                      isMobile: isMobile,
                      onTap: () {
                        final extraData = {
                          'title': blog['title'] ?? '',
                          'content': blog['content'] ?? '',
                          'htmlPreview': blog['htmlPreview'] ?? "",
                          'userUid': userUid,
                          'published': blog['published'] ?? false
                        };
                        context.go(
                          '${AppRouterConstants.newblog}/${blog['uid']}',
                          extra: extraData,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout(bool isDark, bool isMobile, String userUid) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side panel - Enhanced sidebar
        _buildEnhancedSidebar(isDark, userUid, screenWidth * 0.25),

        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilters(isDark, isMobile),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildDesktopBlogsList(isDark, isMobile, userUid),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Desktop Blogs List
  Widget _buildDesktopBlogsList(bool isDark, bool isMobile, String userUid) {
    final localFilteredBlogs = _filterLocalBlogs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Signals',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Local Blogs
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (localFilteredBlogs.isEmpty)
          _buildEmptyState(isDark, userUid)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: localFilteredBlogs.length,
            itemBuilder: (context, index) {
              final blog = localFilteredBlogs[index];
              return _buildBlogCard(
                blogUid: blog.uid,
                title: blog.title,
                content: blog.content,
                published: blog.publishedTimestamp,
                isLocal: true,
                isDark: isDark,
                isMobile: isMobile,
                onTap: () {
                  final extraData = {
                    'title': blog.title,
                    'content': blog.content,
                    'htmlPreview': blog.htmlPreview,
                    'userUid': blog.userUid,
                    'published': blog.publishedTimestamp
                  };
                  context.go(
                    '${AppRouterConstants.newblog}/${blog.uid}',
                    extra: extraData,
                  );
                },
              );
            },
          ),

        const SizedBox(height: 24),

        // Remote Blogs
        Text(
          'Network Signals',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .collection('Blogs')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(isDark, snapshot.error.toString());
            }

            final docs = snapshot.data?.docs ?? [];
            final remoteDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Skip if already in local blogs
              if (localBlogs.keys.toList().contains(data['uid'])) {
                return false;
              }

              // Apply filters
              if (_showOnlyPublished && !(data['published'] ?? false)) {
                return false;
              }
              if (_showOnlyDrafts && (data['published'] ?? false)) {
                return false;
              }

              // Apply search
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                return (data['title'] ?? '').toLowerCase().contains(query) ||
                    (data['content'] ?? '').toLowerCase().contains(query);
              }

              return true;
            }).toList();

            if (remoteDocs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No network signals found',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: remoteDocs.length,
              itemBuilder: (context, index) {
                final blog = remoteDocs[index].data() as Map<String, dynamic>;
                return _buildBlogCard(
                  blogUid: blog['uid'],
                  title: blog['title'] ?? '',
                  content: blog['content'] ?? '',
                  published: blog['published'] ?? false,
                  isLocal: false,
                  isDark: isDark,
                  isMobile: isMobile,
                  onTap: () {
                    final extraData = {
                      'title': blog['title'] ?? '',
                      'content': blog['content'] ?? '',
                      'htmlPreview': blog['htmlPreview'] ?? "",
                      'userUid': userUid,
                      'published': blog['published'] ?? false
                    };
                    context.go(
                      '${AppRouterConstants.newblog}/${blog['uid']}',
                      extra: extraData,
                    );
                  },
                );
              },
            );
          },
        ),

        // Add bottom padding for better scrolling experience
        const SizedBox(height: 80),
      ],
    );
  }

  // Welcome Header
  Widget _buildWelcomeHeader(bool isDark, bool isMobile, String userUid) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 0, vertical: isMobile ? 24 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Nexus',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Connection Sphere',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isMobile ? 16 : 18,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Search and filters widget
  Widget _buildSearchAndFilters(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? NexusColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : NexusColors.signalGray.withOpacity(0.2),
                  width: 1),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search your signals...',
                hintStyle: GoogleFonts.spaceGrotesk(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? NexusColors.primaryBlue.withOpacity(0.7)
                      : NexusColors.primaryBlue.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All Signals',
                  _activeSidebarItem == SidebarItem.allSignals, isDark, () {
                setState(() {
                  _activeSidebarItem = SidebarItem.allSignals;
                  _showOnlyPublished = false;
                  _showOnlyDrafts = false;
                });
              }),
              _buildFilterChip('Published',
                  _activeSidebarItem == SidebarItem.published, isDark, () {
                setState(() {
                  _activeSidebarItem = SidebarItem.published;
                  _showOnlyPublished = true;
                  _showOnlyDrafts = false;
                });
              }),
              _buildFilterChip(
                  'Drafts', _activeSidebarItem == SidebarItem.drafts, isDark,
                  () {
                setState(() {
                  _activeSidebarItem = SidebarItem.drafts;
                  _showOnlyDrafts = true;
                  _showOnlyPublished = false;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Blog Card Widget
  Widget _buildBlogCard({
    required String title,
    required String content,
    required bool published,
    required bool isLocal,
    required bool isDark,
    required bool isMobile,
    required String blogUid,
    required VoidCallback onTap,
  }) {
    final formattedDate = DateFormat('MMM d, yyyy').format(DateTime.now());
    final displayTitle = title.isEmpty ? "Untitled Signal" : title;
    final displayContent = content.isEmpty ? "No content" : content;

    final authState = context.read<AuthBloc>().state;
    final username =
        authState is AuthSuccess ? authState.userEntity.username : '';

    // Function to open the blog preview
    void openPreview(String blogUid) {
      if (published && username.isNotEmpty) {
        context.go('/blog/@$username/$blogUid');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? NexusColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: NexusColors.primaryBlue.withOpacity(0.1),
          highlightColor: NexusColors.primaryBlue.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                        published ? 'Published' : 'Draft', published, isDark),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  displayContent,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isLocal
                              ? Icons.storage_outlined
                              : Icons.cloud_outlined,
                          size: 14,
                          color: isDark
                              ? NexusColors.primaryBlue.withOpacity(0.7)
                              : NexusColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLocal ? 'Local' : 'Network',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDark
                                ? NexusColors.primaryBlue.withOpacity(0.7)
                                : NexusColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    if (published)
                      OutlinedButton.icon(
                        onPressed: () => openPreview(blogUid),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NexusColors.primaryBlue,
                          side: BorderSide(
                            color: NexusColors.primaryBlue.withOpacity(0.5),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        label: Text(
                          'Preview',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, bool isPublished, bool isDark) {
    final color =
        isPublished ? NexusColors.signalGreen : NexusColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isActive, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? NexusColors.primaryBlue.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? NexusColors.primaryBlue.withOpacity(0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            color: isActive
                ? NexusColors.primaryBlue
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String userUid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? NexusColors.primaryBlue.withOpacity(0.1)
                    : NexusColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note_outlined,
                size: 40,
                color: NexusColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Signals Found',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start creating content and broadcasting your ideas',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _createNewBlog(userUid),
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create First Signal',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: NexusColors.dataOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to fetch signals: $errorMessage',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: loadBlogs,
              child: Text(
                'Retry Connection',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: NexusColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, bool isDark, VoidCallback onTap,
      {bool isActive = false, bool highlight = false}) {
    final isHighlighted = highlight && !isActive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? NexusColors.primaryBlue.withOpacity(0.2)
                    : NexusColors.primaryBlue.withOpacity(0.1))
                : isHighlighted
                    ? (isDark
                        ? NexusColors.primaryPurple.withOpacity(0.15)
                        : NexusColors.primaryPurple.withOpacity(0.08))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: NexusColors.primaryBlue.withOpacity(0.5),
                    width: 1,
                  )
                : isHighlighted
                    ? Border.all(
                        color: NexusColors.primaryPurple.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? NexusColors.primaryBlue
                    : isHighlighted
                        ? NexusColors.primaryPurple
                        : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: isActive || isHighlighted
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isActive
                      ? NexusColors.primaryBlue
                      : isHighlighted
                          ? NexusColors.primaryPurple
                          : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : NexusColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Stats',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow('Signals Created', '${localBlogs.length}', isDark),
          const SizedBox(height: 8),
          _buildStatRow(
              'Published',
              '${localBlogs.values.where((blog) => blog.publishedTimestamp).length}',
              isDark),
          const SizedBox(height: 8),
          _buildStatRow(
              'Drafts',
              '${localBlogs.values.where((blog) => !blog.publishedTimestamp).length}',
              isDark),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDark, String userUid) {
    return FloatingActionButton.extended(
      onPressed: () => _createNewBlog(userUid),
      backgroundColor: NexusColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'New Signal',
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEnhancedSidebar(bool isDark, String userUid, double width) {
    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? NexusColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label for workspace
          Text(
            'WORKSPACE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),

          _buildActionButton('My Signals', Icons.hub_outlined, isDark, () {
            setState(() {
              _activeSidebarItem = SidebarItem.allSignals;
              _showOnlyDrafts = false;
              _showOnlyPublished = false;
            });
          }, isActive: _activeSidebarItem == SidebarItem.allSignals),
          const SizedBox(height: 12),
          _buildActionButton('Drafts', Icons.edit_note_outlined, isDark, () {
            setState(() {
              _activeSidebarItem = SidebarItem.drafts;
              _showOnlyDrafts = true;
              _showOnlyPublished = false;
            });
          }, isActive: _activeSidebarItem == SidebarItem.drafts),
          const SizedBox(height: 12),
          _buildActionButton('Published', Icons.public_outlined, isDark, () {
            setState(() {
              _activeSidebarItem = SidebarItem.published;
              _showOnlyPublished = true;
              _showOnlyDrafts = false;
            });
          }, isActive: _activeSidebarItem == SidebarItem.published),

          // Rest of the sidebar remains the same
          const SizedBox(height: 32),
          Text(
            'CREATE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'New Signal',
            Icons.add_circle_outline,
            isDark,
            () => _createNewBlog(userUid),
            highlight: true,
          ),

          const Spacer(),
          _buildNetworkStats(isDark),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(bool isDark, BuildContext context, String userUid) {
    return Drawer(
      backgroundColor: isDark ? NexusColors.darkBackground : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is! AuthSuccess) {
                  return const Landing();
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: NexusColors.primaryBlue,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.userEntity.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '@${state.userEntity.username}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Navigation items with updated active state
            ListTile(
              leading: Icon(
                Icons.hub_outlined,
                color: _activeSidebarItem == SidebarItem.allSignals
                    ? NexusColors.primaryBlue
                    : null,
              ),
              title: Text(
                'My Signals',
                style: GoogleFonts.spaceGrotesk(
                  color: _activeSidebarItem == SidebarItem.allSignals
                      ? NexusColors.primaryBlue
                      : null,
                  fontWeight: _activeSidebarItem == SidebarItem.allSignals
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              selected: _activeSidebarItem == SidebarItem.allSignals,
              selectedColor: NexusColors.primaryBlue,
              selectedTileColor: NexusColors.primaryBlue.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _activeSidebarItem = SidebarItem.allSignals;
                  _showOnlyDrafts = false;
                  _showOnlyPublished = false;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(
                Icons.edit_note_outlined,
                color: _activeSidebarItem == SidebarItem.drafts
                    ? NexusColors.primaryBlue
                    : null,
              ),
              title: Text(
                'Drafts',
                style: GoogleFonts.spaceGrotesk(
                  color: _activeSidebarItem == SidebarItem.drafts
                      ? NexusColors.primaryBlue
                      : null,
                  fontWeight: _activeSidebarItem == SidebarItem.drafts
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              selected: _activeSidebarItem == SidebarItem.drafts,
              selectedColor: NexusColors.primaryBlue,
              selectedTileColor: NexusColors.primaryBlue.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _activeSidebarItem = SidebarItem.drafts;
                  _showOnlyDrafts = true;
                  _showOnlyPublished = false;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(
                Icons.public_outlined,
                color: _activeSidebarItem == SidebarItem.published
                    ? NexusColors.primaryBlue
                    : null,
              ),
              title: Text(
                'Published',
                style: GoogleFonts.spaceGrotesk(
                  color: _activeSidebarItem == SidebarItem.published
                      ? NexusColors.primaryBlue
                      : null,
                  fontWeight: _activeSidebarItem == SidebarItem.published
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              selected: _activeSidebarItem == SidebarItem.published,
              selectedColor: NexusColors.primaryBlue,
              selectedTileColor: NexusColors.primaryBlue.withOpacity(0.1),
              onTap: () {
                setState(() {
                  _activeSidebarItem = SidebarItem.published;
                  _showOnlyPublished = true;
                  _showOnlyDrafts = false;
                });
                Navigator.pop(context);
              },
            ),

            // Rest of the drawer remains the same
            const Divider(),

            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(
                'New Signal',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  color: NexusColors.primaryPurple,
                ),
              ),
              tileColor: NexusColors.primaryPurple.withOpacity(0.1),
              onTap: () {
                _createNewBlog(userUid);
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // Network stats in a compact form
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : NexusColors.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Signals',
                        style: GoogleFonts.spaceGrotesk(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      Text(
                        '${localBlogs.length}',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
