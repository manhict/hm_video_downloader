import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_video_downloader/utils/ad_helper.dart';
import 'package:hm_video_downloader/utils/custom_colors.dart';
import 'package:hm_video_downloader/widgets/my_banner_ad.dart';
import 'package:hm_video_downloader/widgets/video_card.dart';

class VideoReelsScreen extends StatefulWidget {
  final List<VideoData> videoData;
  final List<FileSystemEntity> downloads;
  final ValueChanged onVideoDeleted,
      onControllerInit,
      onControllerDisp,
      onPageViewInit,
      onPageViewDisp;

  const VideoReelsScreen({
    Key? key,
    required this.videoData,
    required this.downloads,
    required this.onVideoDeleted,
    required this.onControllerInit,
    required this.onControllerDisp,
    required this.onPageViewInit,
    required this.onPageViewDisp,
  }) : super(key: key);

  @override
  State<VideoReelsScreen> createState() => _VideoReelsScreenState();
}

class _VideoReelsScreenState extends State<VideoReelsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    widget.onPageViewInit(_pageController);
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) {
      widget.onPageViewDisp(_pageController);
      _pageController.dispose();
    }
    super.dispose();
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
        widget.onVideoDeleted("");
        try {
          final file = File(widget.downloads[index].path);
          await file.delete();
        } catch (e) {
          debugPrint(e.toString());
        }
        Navigator.of(context, rootNavigator: true).pop('dialog');
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
    return SafeArea(
      child: Column(
        children: [
          MyBannerAd(
              type: MyBannerType.full,
              adUnitId: AdHelper.videosScreenBannerAdUnitId),
          widget.downloads.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 50.w,
                          color: CustomColors.primary,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Hmmm.... it seems like you have no downloaded videos. Please download some videos and come back later.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: CustomColors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                      widget.downloads.length,
                      (index) {
                        return VideoCard(
                          path: widget.downloads[index].path,
                          data: widget.videoData[index],
                          onVideoDeleted: () {
                            _showAlertDialog(context, index);
                          },
                          onControllerInit: (controller) {
                            widget.onControllerInit(controller);
                          },
                          onControllerDisp: (controller) {
                            widget.onControllerDisp(controller);
                          },
                        );
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
