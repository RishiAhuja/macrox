import 'dart:convert';

import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/router/app_router.dart';
import 'package:blog/common/widgets/animated_popup/animated_popup.dart';
import 'package:blog/common/widgets/appbar/blog_editor_appbar.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/data/models/firestore/blog_publish_model.dart';
import 'package:blog/domain/entities/blog/blog_entity.dart';
import 'package:blog/domain/usecases/hive/get_all_usecase.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/blog_editor/bloc/blog/blog_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/blog/blog_event.dart';
import 'package:blog/presentation/blog_editor/bloc/blog/blog_state.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_event.dart';
import 'package:blog/presentation/blog_editor/bloc/image/image_state.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_event.dart';
import 'package:blog/presentation/blog_editor/bloc/publish/publish_state.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_bloc.dart';
import 'package:blog/presentation/blog_editor/screen/upload_dialog.dart';
import 'package:blog/presentation/home/widgets/appbar_popup.dart';
import 'package:blog/responsive/responsive_layout.dart';
import 'package:blog/service_locator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogEditor extends StatelessWidget {
  final String uid;
  final String? title;
  final String? content;
  final String? htmlPreview;
  final String userUid;
  final bool published;
  const BlogEditor(
      {super.key,
      required this.uid,
      this.title,
      this.content,
      this.htmlPreview,
      required this.userUid,
      required this.published});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<BlogBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<ImageBloc>(),
        ),
        BlocProvider(create: (context) => sl<PublishBloc>())
      ],
      child: ScreenContent(
        uid: uid,
        title: title,
        content: content,
        htmlPreview: htmlPreview,
        userUid: userUid,
        published: published,
      ),
    );
  }
}

class ScreenContent extends StatefulWidget {
  final String uid;
  final String? title;
  final String? content;
  final String? htmlPreview;
  final String userUid;
  final bool published;
  const ScreenContent(
      {super.key,
      required this.uid,
      this.title,
      this.content,
      this.htmlPreview,
      required this.userUid,
      required this.published});

  @override
  State<ScreenContent> createState() => _ScreenContentState();
}

class _ScreenContentState extends State<ScreenContent> {
  late Future<QuerySnapshot> _blogsFuture;
  late ConfettiController _controllerCenter;
  Map<String, BlogEntity> localBlogs = {};
  bool isLoading = true;
  int currentIndex = 1;
  bool isHovering = false;
  bool isHoveringFutureBuilder = false;

  String? selectedValue;
  bool isFullscreenEdit = false;
  bool _sidebarVisible = true; // New state variable to track sidebar visibility

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    context.read<BlogBloc>().add(ContentChanged(
          title: widget.title ?? '',
          content: widget.content ?? '',
        ));
    loadBlogs();

    _blogsFuture = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userUid)
        .collection('Blogs')
        .get();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  Future<void> loadBlogs() async {
    try {
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

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    customAnimatedSnackbar(
        context, 'Copied to clipboard', Colors.green, Icons.check_circle);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: isFullscreenEdit
              ? null
              : BlogEditorAppbar(
                  mobileDropdown: context.isMobile
                      ? PopupMenuButton(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'CRM',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy_outlined,
                                    size: 18,
                                    color: isDark
                                        ? NexusColors.primaryBlue
                                            .withOpacity(0.8)
                                        : NexusColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Copy Markdown',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'publish',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.send_outlined,
                                    size: 18,
                                    color: isDark
                                        ? NexusColors.primaryBlue
                                            .withOpacity(0.8)
                                        : NexusColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Publish Signal',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'CRM':
                                copyToClipboard((context.read<BlogBloc>().state
                                        as BlogEditing)
                                    .content);
                                break;
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.more_horiz),
                          ),
                        )
                      : null,
                  onPressedDraft: () {
                    final blogState = context.read<BlogBloc>().state;
                    if (blogState is BlogEditing) {
                      context.read<BlogBloc>().add(SaveDraft(
                          uid: widget.uid,
                          title: blogState.title,
                          content: blogState.content,
                          htmlPreview: blogState.htmlPreview,
                          userUid: authState.userEntity.id,
                          published: false));
                    }
                  },
                  isMobile: context.isMobile,
                  draftReplacement: BlocBuilder<BlogBloc, BlogState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: state is BlogSaving
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : NexusColors.primaryBlue
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? Colors.white
                                          : NexusColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : NexusColors.primaryBlue
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : NexusColors.primaryBlue
                                            .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.save_outlined,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white
                                          : NexusColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save Draft',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: isDark
                                            ? Colors.white
                                            : NexusColors.primaryBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  customActionWidget: appBarInfoPopup(
                    isDark,
                    authState.userEntity.name,
                    authState.userEntity.username,
                    authState.userEntity.email,
                    authState.userEntity.id,
                  ),
                  publishRepacement: BlocBuilder<PublishBloc, PublishState>(
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: state is PublishLoading
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: NexusColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: NexusColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.published
                                          ? Icons.update
                                          : Icons.send_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.published ? 'Update' : 'Publish',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  onPressedPublish: () {
                    final authState =
                        context.read<AuthBloc>().state as AuthSuccess;
                    final blogState =
                        context.read<BlogBloc>().state as BlogEditing;
                    final String blogUid =
                        GoRouterState.of(context).pathParameters['uid'] ?? '';

                    final publishModel = BlogPublishModel(
                      userUid: widget.userUid,
                      blogUid: blogUid,
                      content: blogState.content,
                      title: blogState.title,
                      authors: [authState.userEntity.username],
                      authorUid: [authState.userEntity.id],
                      likedBy: [],
                      likes: 0,
                      status: 'up',
                      publishedTimestamp: FieldValue.serverTimestamp(),
                    );
                    context.read<PublishBloc>().add(
                        InitiatePublishRequest(requestModel: publishModel));
                  },
                ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<BlogBloc, BlogState>(
                listener: (context, state) {
                  if (state is BlogSavedSuccess) {
                    customAnimatedSnackbar(context, 'Draft saved successfully',
                        Colors.green, Icons.check_circle);
                  }
                  if (state is BlogSavedFailed) {
                    customAnimatedSnackbar(context, 'Failed to save draft',
                        Colors.red, Icons.error);
                  }
                },
              ),
              BlocListener<PublishBloc, PublishState>(
                listener: (context, state) {
                  if (state is PublishSuccess) {
                    _controllerCenter.play();

                    // Get the current auth state safely
                    final currentAuthState = context.read<AuthBloc>().state;
                    if (currentAuthState is AuthSuccess) {
                      context.go(
                        '/blog/@${currentAuthState.userEntity.username}/${widget.uid}',
                      );

                      // Show success message
                      customAnimatedSnackbar(
                        context,
                        'Signal published successfully!',
                        Colors.green,
                        Icons.check_circle,
                      );
                    }
                  }
                  if (state is PublishFailed) {
                    customAnimatedSnackbar(
                      context,
                      'Failed to publish: ${state.errorMessage}',
                      Colors.red,
                      Icons.error,
                    );
                  }
                },
              ),
            ],
            child: Stack(
              children: [
                BlocBuilder<BlogBloc, BlogState>(
                  builder: (context, blogState) {
                    return ResponsiveLayout(
                      mobileWidget: Center(
                        child: Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 8.0, vertical: 4.0),
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(
                            //         currentIndex == 0
                            //             ? 'Library'
                            //             : currentIndex == 1
                            //                 ? 'Editor'
                            //                 : 'Preview',
                            //         style: GoogleFonts.spaceGrotesk(
                            //           color: isDark
                            //               ? Colors.white70
                            //               : Colors.black54,
                            //           fontSize: 12,
                            //         ),
                            //       ),
                            //       Row(
                            //         children: [
                            //           Icon(
                            //             Icons.swipe,
                            //             size: 14,
                            //             color: isDark
                            //                 ? Colors.white70
                            //                 : Colors.black54,
                            //           ),
                            //           const SizedBox(width: 4),
                            //           Text(
                            //             'Swipe to navigate',
                            //             style: GoogleFonts.spaceGrotesk(
                            //               color: isDark
                            //                   ? Colors.white70
                            //                   : Colors.black54,
                            //               fontSize: 12,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Stack(
                              children: [
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: MediaQuery.of(context).size.height,
                                    initialPage: currentIndex,
                                    enableInfiniteScroll: false,
                                    enlargeCenterPage: true,
                                    viewportFraction: 1.0,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                  ),
                                  items: [
                                    _buildLeftPanel(isDark),
                                    EditorScreen(
                                      uid: widget.uid,
                                      title: widget.title,
                                      content: widget.content,
                                      htmlPreview: widget.content,
                                    ),
                                    _buildPreview(blogState, isDark)
                                  ].map((widget) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: widget,
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [0, 1, 2].map((i) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentIndex == i
                                            ? NexusColors.primaryBlue
                                            : (isDark
                                                ? Colors.white30
                                                : Colors.black26),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      desktopWidget: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _sidebarVisible ? 300 : 0,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                              color: isDark
                                  ? NexusColors.darkSurface
                                  : Colors.white,
                            ),
                            child: _sidebarVisible
                                ? Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Signal Library",
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildSectionHeader(
                                            "Local Signals", isDark),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                isLoading
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            localBlogs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final blog =
                                                              localBlogs.values
                                                                  .elementAt(
                                                                      index);
                                                          return GestureDetector(
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                      BlogBloc>()
                                                                  .add(
                                                                    ContentChanged(
                                                                      title: blog
                                                                          .title,
                                                                      content: blog
                                                                          .content,
                                                                    ),
                                                                  );
                                                              loadBlogs();
                                                              context.go(
                                                                '${AppRouterConstants.newblog}/${blog.uid}',
                                                                extra: {
                                                                  'title': blog
                                                                      .title,
                                                                  'content': blog
                                                                      .content,
                                                                  'htmlPreview':
                                                                      blog.htmlPreview,
                                                                  'shouldRefresh':
                                                                      true,
                                                                },
                                                              );
                                                            },
                                                            child: MouseRegion(
                                                              onExit: (event) {
                                                                setState(() {
                                                                  isHovering =
                                                                      false;
                                                                });
                                                              },
                                                              onEnter: (event) {
                                                                setState(() {
                                                                  isHovering =
                                                                      true;
                                                                });
                                                              },
                                                              child:
                                                                  _buildSignalListItem(
                                                                blog.uid,
                                                                blog.title,
                                                                isHovering,
                                                                blog.publishedTimestamp,
                                                                isLocal: true,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),

                                                const SizedBox(height: 24),

                                                // Network signals section
                                                _buildSectionHeader(
                                                    "Network Signals", isDark),
                                                const SizedBox(height: 12),

                                                // Remote blogs list
                                                FutureBuilder<QuerySnapshot>(
                                                  future: _blogsFuture,
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  24),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    }

                                                    final docs =
                                                        snapshot.data?.docs ??
                                                            [];
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: docs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final blog =
                                                            docs[index].data()
                                                                as Map<String,
                                                                    dynamic>;
                                                        if (localBlogs
                                                            .containsKey(
                                                                blog['uid'])) {
                                                          return const SizedBox
                                                              .shrink();
                                                        }
                                                        return GestureDetector(
                                                          onTap: () {
                                                            context
                                                                .read<
                                                                    BlogBloc>()
                                                                .add(
                                                                  ContentChanged(
                                                                    title: blog[
                                                                            'title'] ??
                                                                        '',
                                                                    content:
                                                                        blog['content'] ??
                                                                            '',
                                                                  ),
                                                                );
                                                            context.go(
                                                              '${AppRouterConstants.newblog}/${blog['uid']}',
                                                              extra: {
                                                                'title': blog[
                                                                        'title'] ??
                                                                    '',
                                                                'content': blog[
                                                                        'content'] ??
                                                                    '',
                                                                'htmlPreview':
                                                                    blog['htmlPreview'] ??
                                                                        '',
                                                                'shouldRefresh':
                                                                    true,
                                                              },
                                                            );
                                                          },
                                                          child: MouseRegion(
                                                            onExit: (event) {
                                                              setState(() {
                                                                isHoveringFutureBuilder =
                                                                    false;
                                                              });
                                                            },
                                                            onEnter: (event) {
                                                              setState(() {
                                                                isHoveringFutureBuilder =
                                                                    true;
                                                              });
                                                            },
                                                            child:
                                                                _buildSignalListItem(
                                                              blog['uid'] ?? '',
                                                              blog['title'] ??
                                                                  'Untitled',
                                                              isHoveringFutureBuilder,
                                                              blog['published'] ??
                                                                  false,
                                                              isLocal: false,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),

                          // Main content area - Editor and Preview
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Toggle sidebar button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: MediaQuery.of(context).size.height,
                                  // decoration: BoxDecoration(
                                  //   color: isDark
                                  //       ? Colors.black.withOpacity(0.2)
                                  //       : Colors.grey.withOpacity(0.1),
                                  // ),
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        _sidebarVisible
                                            ? Icons.chevron_left
                                            : Icons.chevron_right,
                                        size: 20,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _sidebarVisible = !_sidebarVisible;
                                        });
                                      },
                                      tooltip: _sidebarVisible
                                          ? 'Hide sidebar'
                                          : 'Show sidebar',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      splashRadius: 12,
                                    ),
                                  ),
                                ),

                                // Editor
                                Expanded(
                                  flex: 1,
                                  child: EditorScreen(
                                    uid: widget.uid,
                                    title: widget.title,
                                    content: widget.content,
                                    htmlPreview: widget.htmlPreview,
                                  ),
                                ),

                                // Preview
                                Expanded(
                                  flex: 1,
                                  child: _buildPreview(blogState, isDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignalListItem(
      String uid, String title, bool isHovering, bool isPublished,
      {bool isLocal = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: (uid == widget.uid)
            ? NexusColors.primaryBlue.withOpacity(0.1)
            : isHovering
                ? Colors.grey.withOpacity(0.05)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: uid == widget.uid
            ? Border.all(
                color: NexusColors.primaryBlue.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.isEmpty ? "Untitled Signal" : title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight:
                      uid == widget.uid ? FontWeight.w600 : FontWeight.normal,
                  color: uid == widget.uid
                      ? NexusColors.primaryBlue
                      : (context.isDark ? Colors.white : Colors.black87),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPublished
                    ? NexusColors.signalGreen.withOpacity(0.1)
                    : NexusColors.signalGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPublished ? 'Live' : 'Draft',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isPublished
                      ? NexusColors.signalGreen
                      : NexusColors.signalGray,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isLocal ? Icons.storage_outlined : Icons.cloud_outlined,
              size: 12,
              color: context.isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                uid,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  color: context.isDark ? Colors.white38 : Colors.black38,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildPreview(state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        color: isDark ? NexusColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: state is BlogEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          state.title.isEmpty ? "Untitled Signal" : state.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: NexusColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: NexusColors.primaryBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Preview',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: NexusColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  margin: const EdgeInsets.only(bottom: 24),
                ),
                Expanded(
                  child: Markdown(
                    data: state.content,
                    selectable: true,
                    imageBuilder: (Uri uri, String? title, String? alt) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 400,
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              uri.toString(),
                              loadingBuilder: (_, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: NexusColors.primaryBlue,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (_, error, __) => Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.withOpacity(0.1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image loading failed',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.grey,
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
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final uri = Uri.parse(href);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                      h1: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      h2: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      h3: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      code: GoogleFonts.firaCode(
                        backgroundColor: isDark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.grey[100],
                        color: isDark
                            ? Colors.greenAccent.shade200
                            : Colors.green.shade800,
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isDark ? Colors.grey.shade800 : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      codeblockPadding: const EdgeInsets.all(12),
                      tableBody: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                      tableHead: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      tableBorder: TableBorder.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[300]!,
                        width: 1,
                      ),
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
                      blockquotePadding: const EdgeInsets.only(
                          left: 20, top: 12, bottom: 12, right: 8),
                      listBullet: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.preview_outlined,
                    size: 48,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Signal preview will appear here',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start typing in the editor',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NexusColors.primaryBlue,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                NexusColors.primaryBlue.withOpacity(0.5),
                NexusColors.primaryBlue.withOpacity(0.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? NexusColors.darkSurface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Signal Library",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Local signals section
          _buildSectionHeader("Local Signals", isDark),
          const SizedBox(height: 12),
          // Local blogs list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : localBlogs.isEmpty
                    ? Center(
                        child: Text(
                          "No local signals found",
                          style: GoogleFonts.spaceGrotesk(
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: localBlogs.length,
                        itemBuilder: (context, index) {
                          final blog = localBlogs.values.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              context.read<BlogBloc>().add(
                                    ContentChanged(
                                      title: blog.title,
                                      content: blog.content,
                                    ),
                                  );
                              setState(() {
                                currentIndex = 1; // Switch to editor
                              });
                            },
                            child: _buildSignalListItem(
                              blog.uid,
                              blog.title,
                              false,
                              blog.publishedTimestamp,
                              isLocal: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  final String uid;
  final String? title;
  final String? content;
  final String? htmlPreview;
  const EditorScreen(
      {super.key,
      required this.uid,
      this.title,
      this.content,
      this.htmlPreview});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _additionController = TextEditingController();
  final TextEditingController _articleController = TextEditingController();
  String dropdownValue = 'p';
  String content = '';

  @override
  void initState() {
    super.initState();
    final blogBloc = context.read<BlogBloc>();
    final blogState = blogBloc.state;

    if (blogState is BlogEditing) {
      setState(() {
        content += blogState.content;
      });
      _contentController.text = blogState.content;
      _articleController.text = blogState.title;
    }

    _contentController.text = widget.content ?? '';
    _articleController.text = widget.title ?? '';

    print("initState called");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeData = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (routeData?['shouldRefresh'] == true) {
      _contentController.text = routeData?['content'] ?? '';
      _articleController.text = routeData?['title'] ?? '';

      context.read<BlogBloc>().add(
            ContentChanged(
              title: routeData?['title'] ?? '',
              content: routeData?['content'] ?? '',
            ),
          );
    }
  }

  Future<void> _uploadMarkdownFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown'],
      );

      if (result != null && result.files.single.bytes != null) {
        String fileContent = utf8.decode(result.files.single.bytes!);

        setState(() {
          _contentController.text = fileContent;
        });

        customAnimatedSnackbar(
          context,
          "Markdown file uploaded",
          Colors.green,
          Icons.check,
        );
      } else {
        customAnimatedSnackbar(
          context,
          "No file selected or failed to read file bytes",
          Colors.orange,
          Icons.info,
        );
      }
    } catch (e) {
      print('Error uploading markdown file: $e');
      customAnimatedSnackbar(
          context, "Failed to extract markdown", Colors.red, Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Column(
      children: [
        // Main editor area - now wrapped in a ScrollView
        Expanded(
          flex: 9,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
                color: context.isDark
                    ? AppColors.darkLightBackground
                    : AppColors.lightLightBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.compare_arrows_outlined),
                    ),

                  // Title field
                  TextFormField(
                    controller: _articleController,
                    onChanged: (value) {
                      context.read<BlogBloc>().add(ContentChanged(
                          title: _articleController.text.trim(),
                          content: content));
                    },
                    maxLines: null,
                    cursorColor: NexusColors.primaryBlue,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 22 : 32,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: context.isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Signal Title...',
                      hintStyle: GoogleFonts.spaceGrotesk(
                        color: context.isDark ? Colors.white38 : Colors.black38,
                        fontSize: isMobile ? 22 : 32,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Markdown content area - no longer in a ScrollView
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _contentController,
                      onChanged: (value) {
                        content = value;
                        context.read<BlogBloc>().add(ContentChanged(
                            content: content,
                            title: _articleController.text.trim()));
                      },
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      cursorColor: NexusColors.primaryBlue,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.normal,
                        height: 1.6,
                        color: context.isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Start broadcasting your signal in markdown...',
                        hintStyle: GoogleFonts.spaceGrotesk(
                          fontSize: isMobile ? 14 : 16,
                          color: context.isDark
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black38,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom toolbar (unchanged)
        Expanded(
          flex: context.isMobile ? 3 : 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              color: context.isDark ? NexusColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Rest of the toolbar code unchanged
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dropdown section - unchanged
                      Container(
                        width: context.isMobile ? 110 : 140,
                        margin: const EdgeInsets.only(right: 12),
                        child: _dropDownButton(context.isMobile),
                      ),

                      // Text input section - unchanged
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: dropdownValue == 'image'
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: _imagePicker(),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: TextFormField(
                                          controller: _additionController,
                                          onFieldSubmitted: (value) {
                                            if (value.isEmpty) return;

                                            String modifiedValue = value;

                                            // Existing dropdown handling code
                                            if (dropdownValue == 'p') {
                                              modifiedValue = '\n\n$value';
                                            }
                                            if (dropdownValue == 'h1') {
                                              modifiedValue = '\n\n# $value';
                                            }
                                            if (dropdownValue == 'h2') {
                                              modifiedValue = '\n\n## $value';
                                            }
                                            if (dropdownValue == 'h3') {
                                              modifiedValue = '\n\n### $value';
                                            }
                                            if (dropdownValue == 'code') {
                                              modifiedValue =
                                                  '\n\n```\n$value\n```';
                                            }
                                            if (dropdownValue == 'quote') {
                                              modifiedValue = '\n\n> $value';
                                            }
                                            if (dropdownValue == 'ul') {
                                              modifiedValue = '\n- $value';
                                            }
                                            if (dropdownValue == 'bold') {
                                              modifiedValue = '\n**$value**';
                                            }
                                            if (dropdownValue == 'italic') {
                                              modifiedValue = '\n*$value*';
                                            }
                                            if (dropdownValue == 'strike') {
                                              modifiedValue = '\n~~$value~~';
                                            }
                                            if (dropdownValue == 'Ctask') {
                                              modifiedValue = '\n- [ ] $value';
                                            }
                                            if (dropdownValue == 'UCtask') {
                                              modifiedValue = '\n- [x] $value';
                                            }

                                            setState(() {
                                              _contentController.text +=
                                                  modifiedValue;
                                              content += modifiedValue;
                                              _additionController.clear();
                                            });

                                            context.read<BlogBloc>().add(
                                                ContentChanged(
                                                    content: content,
                                                    title: _articleController
                                                        .text
                                                        .trim()));
                                          },
                                          cursorColor: NexusColors.primaryBlue,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            color: context.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                _getPlaceholderForDropdown(
                                                    dropdownValue),
                                            hintStyle: GoogleFonts.spaceGrotesk(
                                              color: context.isDark
                                                  ? Colors.white38
                                                  : Colors.black38,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Add button
                                    Container(
                                      height: double.infinity,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: NexusColors.primaryBlue
                                            .withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                        border: Border.all(
                                          color: NexusColors.primaryBlue
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          color: NexusColors.primaryBlue,
                                        ),
                                        onPressed: () {
                                          if (_additionController.text.isEmpty)
                                            return;

                                          String modifiedValue =
                                              _additionController.text;

                                          // Existing code for modifying based on dropdown
                                          if (dropdownValue == 'p') {
                                            modifiedValue =
                                                '\n\n$modifiedValue';
                                          }
                                          if (dropdownValue == 'h1') {
                                            modifiedValue =
                                                '\n\n# $modifiedValue';
                                          }
                                          if (dropdownValue == 'h2') {
                                            modifiedValue =
                                                '\n\n## $modifiedValue';
                                          }
                                          if (dropdownValue == 'h3') {
                                            modifiedValue =
                                                '\n\n### $modifiedValue';
                                          }
                                          if (dropdownValue == 'code') {
                                            modifiedValue =
                                                '\n\n```\n$modifiedValue\n```';
                                          }
                                          if (dropdownValue == 'quote') {
                                            modifiedValue =
                                                '\n\n> $modifiedValue';
                                          }
                                          if (dropdownValue == 'ul') {
                                            modifiedValue =
                                                '\n- $modifiedValue';
                                          }
                                          if (dropdownValue == 'bold') {
                                            modifiedValue =
                                                '\n**$modifiedValue**';
                                          }
                                          if (dropdownValue == 'italic') {
                                            modifiedValue =
                                                '\n*$modifiedValue*';
                                          }
                                          if (dropdownValue == 'strike') {
                                            modifiedValue =
                                                '\n~~$modifiedValue~~';
                                          }
                                          if (dropdownValue == 'Ctask') {
                                            modifiedValue =
                                                '\n- [ ] $modifiedValue';
                                          }
                                          if (dropdownValue == 'UCtask') {
                                            modifiedValue =
                                                '\n- [x] $modifiedValue';
                                          }

                                          setState(() {
                                            _contentController.text +=
                                                modifiedValue;
                                            content += modifiedValue;
                                            _additionController.clear();
                                          });

                                          context.read<BlogBloc>().add(
                                              ContentChanged(
                                                  content: content,
                                                  title: _articleController.text
                                                      .trim()));
                                        },
                                        tooltip: 'Add to Content',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dummySend() {
    return Opacity(
      opacity: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              width: .5,
            )),
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget _imagePicker() {
    return BlocBuilder<ImageBloc, ImageState>(
      builder: (context, state) {
        if (state is ImageLoading) {
          return Text(
            'Waiting for you to pick image',
            style: GoogleFonts.robotoMono(),
          );
        }
        if (state is ImagePicked) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dummySend(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.image.name, style: GoogleFonts.robotoMono()),
                  TextButton(
                    onPressed: () =>
                        context.read<ImageBloc>().add(PickImageEvent()),
                    child: Text('Change Image',
                        style: GoogleFonts.robotoMono(
                            color: AppColors.primaryLight)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  handleImageUpload(context, state);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          width: .5,
                          color: context.isDark
                              ? Colors.grey[500] ?? Colors.grey
                              : Colors.grey[800] ?? Colors.grey)),
                  child: Icon(Icons.upload_file,
                      color: context.isDark
                          ? Colors.grey[500] ?? Colors.grey
                          : Colors.grey[800] ?? Colors.grey),
                ),
              )
            ],
          );
        }
        if (state is ImageError) {
          return Row(
            children: [
              Text(state.message, style: GoogleFonts.robotoMono()),
              IconButton(
                  onPressed: () {
                    context.read<ImageBloc>().add(PickImageEvent());
                  },
                  icon: const Icon(Icons.refresh))
            ],
          );
        }
        return InkWell(
          onTap: () => context.read<ImageBloc>().add(PickImageEvent()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add),
              const SizedBox(
                height: 10,
              ),
              Text('Add Image from device', style: GoogleFonts.robotoMono())
            ],
          ),
        );
      },
    );
  }

  void handleImageUpload(BuildContext context, state) async {
    final String? uploadedImageUrl = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => BlocProvider(
            create: (context) => sl<UploadBloc>(),
            child: UploadDialog(
                imageExtension: (state.image.name).split('.').last,
                byteSize: (state.image.bytes!.length / 1024),
                fileBytes: state.image.bytes!,
                username: (context.read<AuthBloc>().state as AuthSuccess)
                    .userEntity
                    .username)));

    if (uploadedImageUrl != null) {
      _contentController.text += '![]($uploadedImageUrl)';
      content += '![]($uploadedImageUrl)';
      if (context.mounted) {
        context.read<BlogBloc>().add(ContentChanged(
            content: content, title: _articleController.text.trim()));
        context.read<ImageBloc>().add(ResetImageEvent());
      }
    }
  }

  Widget _dropDownButton(bool isMobile) {
    final dropdownItems = [
      {'value': 'p', 'label': 'Paragraph', 'icon': Icons.text_fields},
      {'value': 'h1', 'label': 'Heading 1', 'icon': Icons.title},
      {'value': 'h2', 'label': 'Heading 2', 'icon': Icons.title},
      {'value': 'h3', 'label': 'Heading 3', 'icon': Icons.title},
      {'value': 'code', 'label': 'Code Block', 'icon': Icons.code},
      {'value': 'quote', 'label': 'Quote', 'icon': Icons.format_quote},
      {'value': 'ul', 'label': 'List Item', 'icon': Icons.format_list_bulleted},
      {'value': 'bold', 'label': 'Bold', 'icon': Icons.format_bold},
      {'value': 'italic', 'label': 'Italic', 'icon': Icons.format_italic},
      {
        'value': 'strike',
        'label': 'Strikethrough',
        'icon': Icons.strikethrough_s
      },
      {
        'value': 'Ctask',
        'label': 'Task',
        'icon': Icons.check_box_outline_blank
      },
      {'value': 'UCtask', 'label': 'Completed Task', 'icon': Icons.check_box},
      {'value': 'image', 'label': 'Image', 'icon': Icons.image_outlined},
      {'value': 'upload', 'label': 'Upload File', 'icon': Icons.upload_file},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          dropdownColor:
              context.isDark ? NexusColors.darkSurface : Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: isMobile ? 16 : 20,
          elevation: 4,
          isExpanded: true,
          style: GoogleFonts.spaceGrotesk(
            color: context.isDark ? Colors.white : Colors.black87,
            fontSize: isMobile ? 13 : 14,
          ),
          menuMaxHeight: 400, // Set max height for dropdown menu
          items: dropdownItems.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item['value'] as String,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: isMobile ? 14 : 16,
                    color: NexusColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item['label'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: isMobile ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value == 'upload') {
              _uploadMarkdownFile();
            } else {
              setState(() {
                dropdownValue = value!;
              });
            }
          },
        ),
      ),
    );
  }

  String _getPlaceholderForDropdown(String dropdownValue) {
    switch (dropdownValue) {
      case 'p':
        return 'Type paragraph text...';
      case 'h1':
        return 'Type main heading...';
      case 'h2':
        return 'Type subheading...';
      case 'h3':
        return 'Type section heading...';
      case 'code':
        return 'Type code snippet...';
      case 'quote':
        return 'Type quoted text...';
      case 'ul':
        return 'Type list item...';
      case 'bold':
        return 'Type bold text...';
      case 'italic':
        return 'Type italic text...';
      case 'strike':
        return 'Type text to strikethrough...';
      case 'Ctask':
        return 'Type uncompleted task...';
      case 'UCtask':
        return 'Type completed task...';
      default:
        return 'Type content here...';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
