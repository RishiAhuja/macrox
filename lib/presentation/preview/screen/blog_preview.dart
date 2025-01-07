import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/helper/extensions/is_mobile.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/presentation/preview/bloc/preview_bloc.dart';
import 'package:blog/presentation/preview/bloc/preview_event.dart';
import 'package:blog/presentation/preview/bloc/preview_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPreview extends StatelessWidget {
  const BlogPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // final String? username =
    //     GoRouterState.of(context).pathParameters['username'];
    final String? uid = GoRouterState.of(context).pathParameters['uid'];

    return uid != null
        ? BlocProvider(
            create: (context) => PreviewBloc()..add(LoadBlogPreview(uid)),
            child: BlogPreviewContent(uid: uid),
          )
        : Scaffold(
            body: Center(
              child: Text('Blog not found',
                  style: GoogleFonts.robotoMono(fontSize: 18)),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppBar(
        isLanding: false,
      ),
      body: BlocBuilder<PreviewBloc, PreviewState>(builder: (context, state) {
        if (state is PreviewLoading) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Loading blog data',
                style: GoogleFonts.robotoMono(),
              )
            ],
          ));
        }
        if (state is PreviewError) {
          return Center(
            child: Text("Error: //${state.message}",
                style: GoogleFonts.robotoMono()),
          );
        }
        if (state is PreviewLoaded) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      (context.isMobile ? 1 : 0.6),
                  child: Text(state.blogEntity.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: context.isMobile ? 35 : 50,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle username click - e.g., navigate to profile
                        context.go('/profile/@${state.blogEntity.authors[0]}',
                            extra: {
                              'userUid': state.blogEntity.authorUid[0],
                              'username': state.blogEntity.authors[0],
                            });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text('@${state.blogEntity.authors[0]}',
                            style: GoogleFonts.robotoMono(fontSize: 20)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(' · '),
                    ),
                    Text(
                        DateFormat.yMMMMd().format(
                            (state.blogEntity.publishedTimestamp).toDate()),
                        style: GoogleFonts.robotoMono(fontSize: 20)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(' · '),
                    ),
                    const Icon(Icons.book, size: 20),
                    const SizedBox(width: 8),
                    Text(
                        '${calculateReadTime(state.blogEntity.content)} min read',
                        style: GoogleFonts.robotoMono(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                // Text(state.blogEntity.content,
                //     style: GoogleFonts.robotoMono(fontSize: 18)),
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width *
                        (context.isMobile ? 0.95 : 0.60),
                    child: _markdown(context.isDark, state))
              ],
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget _markdown(bool isDark, state) {
    return Markdown(
      padding: const EdgeInsets.all(20),
      data: state.blogEntity.content,
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
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (_, error, __) => const Icon(Icons.error),
              ),
            ),
          ),
        );
      },
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.robotoMono(),
        h1: GoogleFonts.robotoMono(fontSize: 30),
        h2: GoogleFonts.robotoMono(fontSize: 24),
        h3: GoogleFonts.robotoMono(fontSize: 20),
        code: GoogleFonts.firaCode(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[300],
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
    );
  }
}
