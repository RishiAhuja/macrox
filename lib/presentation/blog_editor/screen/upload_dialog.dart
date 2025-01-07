import 'dart:typed_data';

import 'package:blog/common/helper/extensions/random_string.dart';
import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:blog/data/models/cloud_storage/storage/upload_image_request.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_bloc.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_event.dart';
import 'package:blog/presentation/blog_editor/bloc/upload/upload_state.dart';
import 'package:flutter/material.dart';
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
    return PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          // Make dialog shape with rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              BlocBuilder<UploadBloc, UploadState>(builder: (context, state) {
            return Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                child: _content(state));
          }),
        ));
  }

  Widget _content(state) {
    if (state is UploadInitial) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This is a heavy operation, Do you really want to upload?',
            style: GoogleFonts.spaceGrotesk(fontSize: 25),
          ),
          Row(
            children: [
              Text('Size: ${(widget.byteSize ?? 0).toStringAsFixed(2)} KB',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18)),
              TextButton(
                  onPressed: () {
                    context.read<UploadBloc>().add(UploadImageEvent(
                        imageReq: UploadImageRequest(
                            fileBytes: widget.fileBytes,
                            fileName:
                                '${context.generateRandomString(10)}.${widget.imageExtension}',
                            folderPath: widget.username)));
                  },
                  child: Text(
                    'Upload',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18, color: AppColors.primaryLight),
                  ))
            ],
          )
        ],
      );
    }
    if (state is UploadLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Uploading...',
            style: GoogleFonts.spaceGrotesk(fontSize: 25),
          ),
          const CircularProgressIndicator()
        ],
      );
    }
    if (state is UploadError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Error: ${state.message}',
            style: GoogleFonts.spaceGrotesk(fontSize: 25),
          ),
          TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, color: AppColors.primaryLight),
              ))
        ],
      );
    }
    if (state is UploadSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upload Success',
            style: GoogleFonts.spaceGrotesk(fontSize: 25),
          ),
          TextButton(
              onPressed: () => Navigator.of(context).pop(state.imageUrl),
              child: Text(
                'Close',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, color: AppColors.primaryLight),
              ))
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
