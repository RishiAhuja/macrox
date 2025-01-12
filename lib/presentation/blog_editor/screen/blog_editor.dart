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
  String? selectedValue;

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
      print('Loaded blogs: ${res.length}');
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
          appBar: BlogEditorAppbar(
            mobileDropdown: PopupMenuButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: context.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'CRM',
                  child: Row(
                    children: [
                      const Icon(Icons.copy),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Copy Raw Markdown',
                        style: GoogleFonts.robotoMono(
                          color: context.isDark
                              ? Colors.grey[300]
                              : Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'publish',
                  child: Row(
                    children: [
                      const Icon(Icons.publish_rounded),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Publish',
                        style: GoogleFonts.robotoMono(
                          color: context.isDark
                              ? Colors.grey[300]
                              : Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'CRM':
                    copyToClipboard(
                        (context.read<BlogBloc>().state as BlogEditing)
                            .content);
                    break;
                }
              },
              icon: const Icon(
                  Icons.keyboard_arrow_down_rounded), // Three-dot menu icon
            ),
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
            draftRepacement: BlocBuilder<BlogBloc, BlogState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: state is BlogSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Draft',
                          style: GoogleFonts.robotoMono(
                            color: context.isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            fontSize: 18,
                          ),
                        ),
                );
              },
            ),
            customActionWidget: appBarInfoPopup(
              context.isDark,
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
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.published ? 'Update' : 'Publish',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              );
            }),
            onPressedPublish: () {
              final authState = context.read<AuthBloc>().state as AuthSuccess;
              final blogState = context.read<BlogBloc>().state as BlogEditing;
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
              context
                  .read<PublishBloc>()
                  .add(InitiatePublishRequest(requestModel: publishModel));
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
                    context.go(
                        '/blog/@${authState.userEntity.username}/${widget.uid}');
                  }
                  if (state is PublishFailed) {
                    customAnimatedSnackbar(
                        context,
                        'Failed to publish: ${state.errorMessage}',
                        Colors.red,
                        Icons.error);
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
                            child: CarouselSlider(
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
                            _buildLeftPanel(context.isDark),
                            EditorScreen(
                              uid: widget.uid,
                              title: widget.title,
                              content: widget.content,
                              htmlPreview: widget.content,
                            ),
                            _buildPreview(blogState, context.isDark)
                          ].map((widget) {
                            return Builder(
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: widget,
                                );
                              },
                            );
                          }).toList(),
                        )),
                        desktopWidget: Center(
                            child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: _buildLeftPanel(context.isDark)),
                            Expanded(
                                flex: 5,
                                child: EditorScreen(
                                  uid: widget.uid,
                                  title: widget.title,
                                  content: widget.content,
                                  htmlPreview: widget.content,
                                )),
                            Expanded(
                                flex: 5,
                                child:
                                    _buildPreview(blogState, context.isDark)),
                          ],
                        )));
                  },
                ),
                Align(
                  alignment: Alignment.center,
                  child: ConfettiWidget(
                    emissionFrequency: 0.8,
                    minimumSize: const Size(4, 4),
                    maximumSize: const Size(12, 12),
                    numberOfParticles: 100,
                    gravity: 0.1,
                    confettiController: _controllerCenter,
                    blastDirectionality: BlastDirectionality
                        .explosive, // don't specify a direction, blast randomly
                    shouldLoop:
                        false, // start again as soon as the animation is finished
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ], // manually specify the colors to be used
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _leftPanelListTile(String uid, String title, bool isHovering) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
          color: ((uid == widget.uid) || isHovering)
              ? Colors.grey.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
      child: Text(uid),
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          color: isDark
              ? AppColors.darkLightBackground
              : AppColors.lightLightBackground,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_right_rounded)),
          Text("Locally Available Blogs",
              style: GoogleFonts.spaceGrotesk(fontSize: 16)),
          ListView.builder(
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
                    loadBlogs();
                    context.go(
                      '${AppRouterConstants.newblog}/${blog.uid}',
                      extra: {
                        'title': blog.title,
                        'content': blog.content,
                        'htmlPreview': blog.htmlPreview,
                        'shouldRefresh': true, // Flag to force refresh
                      },
                    );
                  },
                  child: MouseRegion(
                      onExit: (event) {
                        setState(() {
                          isHovering = false;
                        });
                      },
                      onEnter: (event) {
                        setState(() {
                          isHovering = true;
                        });
                      },
                      child: _leftPanelListTile(
                          blog.uid, blog.title, isHovering)));
            },
          ),
          const SizedBox(height: 20),
          Text("Remote Blogs", style: GoogleFonts.spaceGrotesk(fontSize: 16)),
          FutureBuilder<QuerySnapshot>(
            future: _blogsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final blog = docs[index].data() as Map<String, dynamic>;
                  if (localBlogs.containsKey(blog['uid'])) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      context.read<BlogBloc>().add(
                            ContentChanged(
                              title: blog['title'],
                              content: blog['content'],
                            ),
                          );
                      context.go(
                        '${AppRouterConstants.newblog}/${blog['uid']}',
                        extra: {
                          'title': blog['title'],
                          'content': blog['content'],
                          'htmlPreview': blog['htmlPreview'],
                          'shouldRefresh': true, // Flag to force refresh
                        },
                      );
                    },
                    child: MouseRegion(
                      onExit: (event) {
                        setState(() {
                          isHovering = false;
                        });
                      },
                      onEnter: (event) {
                        setState(() {
                          isHovering = true;
                        });
                      },
                      child: _leftPanelListTile(
                        blog['uid'],
                        blog['title'] ?? 'Untitled',
                        false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          color: isDark
              ? AppColors.darkLightBackground
              : AppColors.lightLightBackground,
          borderRadius: BorderRadius.circular(10)),
      child: state is BlogEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(state.title,
                      style: GoogleFonts.spaceGrotesk(fontSize: 37)),
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
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              uri.toString(),
                              // 'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                              loadingBuilder: (_, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (_, error, __) =>
                                  const Icon(Icons.error),
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
                      p: GoogleFonts.robotoMono(),
                      h1: GoogleFonts.robotoMono(fontSize: 30),
                      h2: GoogleFonts.robotoMono(fontSize: 24),
                      h3: GoogleFonts.robotoMono(fontSize: 20),
                      code: GoogleFonts.firaCode(
                        backgroundColor:
                            isDark ? Colors.grey[900] : Colors.grey[300],
                        color: isDark ? Colors.grey[300] : Colors.grey[900],
                        fontSize: 16,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      blockquote: GoogleFonts.robotoMono(
                        fontSize: 21,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[400],
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey[700]!,
                            width: 4,
                          ),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.only(left: 20),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
              'Preview will appear here',
              style: GoogleFonts.robotoMono(),
            )),
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
    return Column(
      children: [
        Expanded(
          flex: 9,
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
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  if (context.isMobile)
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.compare_arrows_outlined)),
                  TextFormField(
                    controller: _articleController,
                    onChanged: (value) {
                      context.read<BlogBloc>().add(ContentChanged(
                          title: _articleController.text.trim(),
                          content: content));
                    },
                    maxLines: null,
                    cursorColor: AppColors.primaryLight,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: context.isMobile ? 22 : 28,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Article Title..',
                      hintStyle: GoogleFonts.robotoMono(),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.only(left: 15, right: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
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
                        cursorColor: AppColors.primaryLight,
                        style: GoogleFonts.robotoMono(
                            fontSize: context.isMobile ? 12 : 16,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Start writing markdown here..',
                          hintStyle: GoogleFonts.robotoMono(),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(left: 15, right: 15),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                  flex: context.isMobile ? 3 : 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                          color: context.isDark
                              ? AppColors.darkLightBackground
                              : AppColors.lightLightBackground,
                          borderRadius: BorderRadius.circular(10)),
                      child: _dropDownButton(context.isMobile),
                    ),
                  )),
              Expanded(
                  flex: context.isMobile ? 8 : 9,
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
                        borderRadius: BorderRadius.circular(10)),
                    child: dropdownValue == 'image'
                        ? _imagePicker()
                        : TextFormField(
                            controller: _additionController,
                            onFieldSubmitted: (value) {
                              String modifiedValue = value;

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
                                modifiedValue = '\n\n``` \n$value\n ```';
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
                                modifiedValue = '\n$value*';
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
                                _contentController.text += modifiedValue;
                                content += modifiedValue;
                                _additionController.clear();
                              });
                              print(content);
                              context.read<BlogBloc>().add(ContentChanged(
                                  content: content,
                                  title: _articleController.text.trim()));
                            },
                            cursorColor: AppColors.primaryLight,
                            style: GoogleFonts.robotoMono(
                                fontSize: 18, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText:
                                  'Write content based on selected markdown..',
                              hintStyle: GoogleFonts.robotoMono(),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.only(left: 15, right: 15),
                            ),
                          ),
                  ))
            ],
          ),
        )
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
    return DropdownButton<String>(
      value: dropdownValue,
      dropdownColor: context.isDark
          ? AppColors.darkLightBackground
          : AppColors.lightLightBackground,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: isMobile ? 16 : 24,
      elevation: 0,
      style: GoogleFonts.robotoMono(),
      underline: Container(
        height: 2,
        color: Colors.transparent,
      ),
      items: <String>[
        'p',
        'h1',
        'h2',
        'h3',
        'code',
        'quote',
        'ul',
        'bold',
        'italic',
        'strike',
        'Ctask',
        'UCtask',
        'image',
        'upload',
      ].map<DropdownMenuItem<String>>((String value) {
        return _dropDownItem(value, isMobile);
      }).toList(),
      onChanged: (String? value) {
        if (dropdownValue == 'upload') {
          print("want upload");
          _uploadMarkdownFile();
        } else {
          setState(() {
            dropdownValue = value!;
          });
        }
      },
    );
  }

  DropdownMenuItem<String> _dropDownItem(String value, bool isMobile) {
    return DropdownMenuItem<String>(
      value: value,
      child: Center(
        child: Text(
          value,
          style: GoogleFonts.robotoMono(
              fontSize: isMobile ? 10 : 14,
              color: context.isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
