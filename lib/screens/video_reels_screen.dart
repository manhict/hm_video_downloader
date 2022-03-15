import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_video_downloader/screens/downloads_screen.dart';
import 'package:hm_video_downloader/utils/custom_colors.dart';
import 'package:hm_video_downloader/widgets/video_card.dart';

class VideoReelsScreen extends StatefulWidget {
  final List<FileSystemEntity> downloads;
  final List<VideoData> videoData;
  final int initialIndex;

  const VideoReelsScreen({
    Key? key,
    required this.downloads,
    required this.videoData,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<VideoReelsScreen> createState() => _VideoReelsScreenState();
}

class _VideoReelsScreenState extends State<VideoReelsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  _showAlertDialog(BuildContext context, int index) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: GoogleFonts.poppins(
          color: CustomColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        style: GoogleFonts.poppins(
          color: CustomColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () async {
        try {
          final file = File(widget.downloads[index].path);
          await file.delete();
        } catch (e) {
          debugPrint(e.toString());
        }
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DownloadsScreen(),
          ),
        );
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: CustomColors.backGround,
      title: Text(
        "Delete Confirmation",
        style: GoogleFonts.poppins(
          color: CustomColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        "Are you sure you want to delete this video ?",
        style: GoogleFonts.poppins(
          color: CustomColors.white,
          fontSize: 18,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DownloadsScreen(),
          ),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: CustomColors.backGround,
        appBar: AppBar(
          backgroundColor: CustomColors.appBar,
          iconTheme: IconThemeData(color: CustomColors.primary),
          title: Text(
            "Watch Videos",
            style: GoogleFonts.poppins(
              fontSize: 25,
              color: CustomColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          children: List.generate(
            widget.downloads.length,
            (index) => VideoCard(
              path: widget.downloads[index].path,
              data: widget.videoData[index],
              onVideoDeleted: () {
                _showAlertDialog(context, index);
              },
            ),
          ),
        ),
      ),
    );
  }
}