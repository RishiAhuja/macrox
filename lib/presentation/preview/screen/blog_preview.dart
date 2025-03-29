import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/presentation/preview/bloc/preview_bloc.dart';
import 'package:blog/presentation/preview/bloc/preview_event.dart';
import 'package:blog/presentation/preview/bloc/preview_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPreview extends StatelessWidget {
  const BlogPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = GoRouterState.of(context).pathParameters['uid'];
    return uid != null
        ? BlocProvider(
            create: (context) => PreviewBloc()..add(LoadBlogPreview(uid)),
            child: BlogPreviewContent(uid: uid),
          )
        : Scaffold(
            body: Center(
              child: Text(
                'Signal not found',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
  }
}

class BlogPreviewContent extends StatefulWidget {
  final String uid;
  const BlogPreviewContent({super.key, required this.uid});

  @override
  State<BlogPreviewContent> createState() => _BlogPreviewContentState();
}

int calculateReadTime(String content) {
  final cleanContent = content.replaceAll(RegExp(r'[^\w\s]'), '');
  final characterCount = cleanContent.replaceAll(' ', '').length;
  final wordCount = characterCount / 8;
  final readingTimeMinutes = wordCount / 120;
  return readingTimeMinutes.ceil() < 1 ? 1 : readingTimeMinutes.ceil();
}

class _BlogPreviewContentState extends State<BlogPreviewContent> {
  final ScrollController _scrollController = ScrollController();
  bool isLiked = false;
  bool showFloatingHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 250 && !showFloatingHeader) {
      setState(() {
        showFloatingHeader = true;
      });
    } else if (_scrollController.offset <= 250 && showFloatingHeader) {
      setState(() {
        showFloatingHeader = false;
      });
    }
  }

  void _shareSignal(String title, String uid) {
    final url = 'https://nexus.rishia.in/blog/$uid';
    Share.share('$title\n\nRead more on Nexus: $url');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
      body: BlocBuilder<PreviewBloc, PreviewState>(
        builder: (context, state) {
          if (state is PreviewLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: NexusColors.primaryBlue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading signal data...',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  )
                ],
              ),
            );
          }

          if (state is PreviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: isDark ? Colors.red[300] : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading signal",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<PreviewBloc>()
                          .add(LoadBlogPreview(widget.uid));
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Try Again',
                      style: GoogleFonts.spaceGrotesk(),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PreviewLoaded) {
            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.isMobile ? 20 : 0,
                          vertical: 40,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: context.isMobile
                                    ? double.infinity
                                    : MediaQuery.of(context).size.width * 0.65,
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  state.blogEntity.title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: context.isMobile ? 32 : 48,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                width: context.isMobile
                                    ? double.infinity
                                    : MediaQuery.of(context).size.width * 0.65,
                                margin: const EdgeInsets.only(bottom: 24),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: [
                                    _buildMetadataItem(
                                      icon: Icons.person_outline,
                                      text: '@${state.blogEntity.authors[0]}',
                                      isDark: isDark,
                                      onTap: () {
                                        context.go(
                                            '/profile/@${state.blogEntity.authors[0]}',
                                            extra: {
                                              'userUid':
                                                  state.blogEntity.authorUid[0],
                                              'username':
                                                  state.blogEntity.authors[0],
                                            });
                                      },
                                    ),
                                    _buildMetadataItem(
                                      icon: Icons.calendar_today_outlined,
                                      text: DateFormat.yMMMMd().format(
                                          (state.blogEntity.publishedTimestamp)
                                              .toDate()),
                                      isDark: isDark,
                                    ),
                                    _buildMetadataItem(
                                      icon: Icons.book_outlined,
                                      text:
                                          '${calculateReadTime(state.blogEntity.content)} min read',
                                      isDark: isDark,
                                    ),
                                    _buildMetadataItem(
                                      icon: isLiked
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      text:
                                          '${state.blogEntity.likes + (isLiked ? 1 : 0)}',
                                      isDark: isDark,
                                      highlighted: isLiked,
                                      onTap: () {
                                        if (!isLiked) {
                                          FirebaseFirestore.instance
                                              .collection('Blogs')
                                              .doc(state.blogEntity.blogUid)
                                              .update({
                                            'likes': FieldValue.increment(1)
                                          });
                                          setState(() {
                                            isLiked = true;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              _buildStreamlinedBeacon(context, state, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: context.isMobile ? 12 : 0,
                          right: context.isMobile ? 12 : 0,
                          bottom: 100,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: context.isMobile
                                  ? double.infinity
                                  : MediaQuery.of(context).size.width * 0.65,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? NexusColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(top: 32),
                            child: _buildMarkdownContent(
                              context,
                              isDark,
                              state.blogEntity.content,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showFloatingHeader)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? NexusColors.darkSurface.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.blogEntity.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  size: 20,
                                  color: isLiked
                                      ? NexusColors.primaryBlue
                                      : isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                                onPressed: () {
                                  if (!isLiked) {
                                    FirebaseFirestore.instance
                                        .collection('Blogs')
                                        .doc(state.blogEntity.blogUid)
                                        .update(
                                            {'likes': FieldValue.increment(1)});
                                    setState(() {
                                      isLiked = true;
                                    });
                                  }
                                },
                                tooltip: 'Like this signal',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                                onPressed: () => _shareBeacon(
                                  state.blogEntity.title,
                                  state.blogEntity.authors[0],
                                  state.blogEntity.blogUid,
                                ),
                                tooltip: 'Share this signal',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: BlocBuilder<PreviewBloc, PreviewState>(
        builder: (context, state) {
          if (state is PreviewLoaded) {
            return FloatingActionButton(
              backgroundColor: NexusColors.primaryBlue,
              foregroundColor: Colors.white,
              onPressed: () {
                if (_scrollController.offset > 500) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  if (state.blogEntity.authorUid.contains('current-user-id')) {
                    context.go('/edit/${state.blogEntity.blogUid}', extra: {
                      'title': state.blogEntity.title,
                      'content': state.blogEntity.content,
                      'htmlPreview': state.blogEntity.content,
                    });
                  } else {
                    _shareSignal(
                        state.blogEntity.title, state.blogEntity.blogUid);
                  }
                }
              },
              child: Icon(
                _scrollController.hasClients && _scrollController.offset > 500
                    ? Icons.arrow_upward
                    : state.blogEntity.authorUid.contains('current-user-id')
                        ? Icons.edit
                        : Icons.share,
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String text,
    required bool isDark,
    bool highlighted = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted
              ? NexusColors.primaryBlue.withOpacity(0.1)
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted
                ? NexusColors.primaryBlue.withOpacity(0.3)
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: highlighted
                  ? NexusColors.primaryBlue
                  : isDark
                      ? Colors.white70
                      : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: highlighted
                    ? NexusColors.primaryBlue
                    : isDark
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(
      BuildContext context, bool isDark, String content) {
    return Markdown(
      padding: const EdgeInsets.all(24),
      data: content,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.parse(href);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      imageBuilder: (Uri uri, String? title, String? alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 500,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Image.network(
                uri.toString(),
                fit: BoxFit.contain,
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        NexusColors.primaryBlue,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, error, __) => Container(
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image could not be loaded',
                        style: GoogleFonts.spaceGrotesk(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          height: 1.7,
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
        ),
        h1: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          height: 1.4,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        h2: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          height: 1.4,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        h3: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        h4: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          height: 1.4,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        code: GoogleFonts.firaCode(
          backgroundColor:
              isDark ? Colors.black.withOpacity(0.6) : Colors.grey[100],
          color: isDark ? Colors.greenAccent.shade200 : Colors.green.shade800,
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.white70 : Colors.black54,
          height: 1.6,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: NexusColors.primaryBlue.withOpacity(0.5),
              width: 4,
            ),
          ),
        ),
        blockquotePadding:
            const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 8),
        a: GoogleFonts.spaceGrotesk(
          color: NexusColors.primaryBlue,
          decoration: TextDecoration.underline,
          decorationColor: NexusColors.primaryBlue.withOpacity(0.4),
        ),
        tableHead: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        tableBody: GoogleFonts.spaceGrotesk(
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
        ),
        tableBorder: TableBorder.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey[300]!,
          width: 1,
        ),
        tableCellsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        listBullet: GoogleFonts.spaceGrotesk(
          color: isDark ? Colors.white : Colors.black87,
        ),
        listIndent: 24,
        em: GoogleFonts.spaceGrotesk(
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
        ),
        strong: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        checkbox: GoogleFonts.spaceGrotesk(
          color: NexusColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStreamlinedBeacon(
      BuildContext context, PreviewLoaded state, bool isDark) {
    final String beaconLink =
        'https://nexus.rishia.in/blog/@${state.blogEntity.authors[0]}/${state.blogEntity.blogUid}';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            context.isMobile ? 16 : MediaQuery.of(context).size.width * 0.175,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : NexusColors.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? NexusColors.primaryBlue.withOpacity(0.2)
              : NexusColors.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NexusColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: NexusColors.primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: NexusColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Beacon',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NexusColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildPulsingBeacon(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Signal your network',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share this signal beacon with your network to amplify your message and strengthen connections.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black87.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    beaconLink,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  color: NexusColors.primaryBlue,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: beaconLink))
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Beacon link copied to clipboard',
                                style: GoogleFonts.spaceGrotesk(),
                              ),
                            ],
                          ),
                          backgroundColor: NexusColors.primaryBlue,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildBeaconButton(
                icon: Icons.share_outlined,
                label: 'Share Beacon',
                onTap: () => _shareBeacon(
                  state.blogEntity.title,
                  state.blogEntity.authors[0],
                  state.blogEntity.blogUid,
                ),
                isDark: isDark,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingBeacon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - value).clamp(0.0, 0.7),
              child: Container(
                width: 18 + (value * 14),
                height: 18 + (value * 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NexusColors.primaryBlue.withOpacity(0.3),
                ),
              ),
            ),
            Opacity(
              opacity: (1 - value).clamp(0.2, 0.8),
              child: Container(
                width: 18 + (value * 8),
                height: 18 + (value * 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NexusColors.primaryBlue.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: NexusColors.primaryBlue,
              ),
            ),
          ],
        );
      },
      onEnd: () => _buildPulsingBeacon(),
    );
  }

  Widget _buildBeaconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor:
            isPrimary ? Colors.white : (isDark ? Colors.white : Colors.black87),
        backgroundColor: isPrimary
            ? NexusColors.primaryBlue
            : (isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isPrimary
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05)),
            width: 1,
          ),
        ),
      ),
      icon: Icon(
        icon,
        size: 18,
        color: isPrimary
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black54),
      ),
      label: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _shareBeacon(String title, String username, String uid) {
    final url = 'https://nexus.rishia.in/blog/@$username/$uid';
    Share.share('$title\n\nConnect with this beacon on Nexus: $url');
  }
}
