import 'package:blog/common/helper/extensions/random_string.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_event.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadDialog extends StatefulWidget {
  final double? byteSize;
  final Uint8List fileBytes;
  final String username;
  final String imageExtension;
  const UploadDialog(
      {super.key,
      this.byteSize,
      required this.fileBytes,
      required this.username,
      required this.imageExtension});

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        backgroundColor: isDark ? NexusColors.darkSurface : Colors.white,
        child: BlocBuilder<UploadBloc, UploadState>(builder: (context, state) {
          return Container(
            width: 360, // Slightly wider to accommodate content
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            clipBehavior: Clip.antiAlias, // For cleaner rounded corners
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: _content(state),
          );
        }),
      ),
    );
  }

  Widget _content(state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is UploadInitial) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dialog header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : NexusColors.primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 36,
                  color: NexusColors.primaryBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload Image',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Dialog content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will upload the image to your personal storage.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    height: 1.4,
                    color:
                        isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // File size info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_size_select_actual_outlined,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image Size',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Text(
                              '${(widget.byteSize ?? 0).toStringAsFixed(2)} KB',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Upload button
                    ElevatedButton(
                      onPressed: () {
                        context.read<UploadBloc>().add(UploadImageEvent(
                            imageReq: UploadImageRequest(
                                fileBytes: widget.fileBytes,
                                fileName:
                                    '${context.generateRandomString(10)}.${widget.imageExtension}',
                                folderPath: widget.username)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NexusColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Upload',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state is UploadLoading) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(NexusColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Uploading Image...',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This may take a moment depending on your connection speed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (state is UploadError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(isDark ? 0.3 : 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 36,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload Failed',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Error content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withOpacity(0.1)
                        : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    state.message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark ? Colors.red[300] : Colors.red[700],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1),
                      foregroundColor:
                          isDark ? Colors.red[300] : Colors.red[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state is UploadSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(isDark ? 0.3 : 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 36,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload Successful',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Success content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Your image has been uploaded and is ready to use in your signal.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    height: 1.4,
                    color:
                        isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                // URL display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                          state.imageUrl,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: NexusColors.primaryBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 16,
                          color: NexusColors.primaryBlue,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: state.imageUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Image URL copied to clipboard',
                                style: GoogleFonts.spaceGrotesk(),
                              ),
                              backgroundColor: NexusColors.primaryBlue,
                            ),
                          );
                        },
                        tooltip: 'Copy URL',
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(state.imageUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Insert Image & Close',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
