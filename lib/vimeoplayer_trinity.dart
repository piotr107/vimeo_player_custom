library vimeoplayer;

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vimeoplayer_trinity/src/controls_config.dart';
import 'src/quality_links.dart';

//Video player class
class VimeoPlayer extends StatefulWidget {
  /// Vimeo video id
  final String? id;

  /// Whether player should autoplay video
  final bool autoPlay;

  /// Whether player should loop video
  final bool looping;

  /// Start playing in fullscreen.default is false
  final bool fullScreenByDefault;

  /// Video fit in fullscreen mode
  final BoxFit fullscreenVideoFit;

  /// Configure controls
  final ControlsConfig? controlsConfig;

  /// Progress indicator color
  final Color? loaderColor;

  /// Progress indicator background color
  final Color? loaderBackgroundColor;

  /// Defines the set of allowed device orientations on entering fullscreen
  final List<DeviceOrientation> deviceOrientationsOnFullScreen;

  /// Defines the set of allowed device orientations after exiting fullscreen
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  /// Defines if player should auto detect full screen device orientation based on aspect ratio of the video. If aspect ratio of the video is < 1 then video will played in full screen in portrait mode. If aspect ratio is >= 1 then video will be played horizontally. If this parameter is true, then [deviceOrientationsOnFullScreen] and [fullScreenAspectRatio] value will be ignored.
  final bool autoDetectFullscreenDeviceOrientation;

  const VimeoPlayer({
    required this.id,
    this.autoPlay = false,
    this.looping = false,
    this.controlsConfig,
    this.loaderColor = Colors.white,
    this.loaderBackgroundColor,
    this.fullScreenByDefault = false,
    this.fullscreenVideoFit = BoxFit.contain,
    this.deviceOrientationsOnFullScreen = const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.deviceOrientationsAfterFullScreen = const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
    this.autoDetectFullscreenDeviceOrientation = false,
    Key? key,
  })  : assert(id != null, 'Video ID can not be null'),
        super(key: key);

  @override
  _VimeoPlayerState createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  int? position;
  bool fullScreenByDefault = false;

  //Quality Class
  late QualityLinks _quality;
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    fullScreenByDefault = widget.fullScreenByDefault;

    //Create class
    _quality = QualityLinks(widget.id);

    //Initializing video controllers when receiving data from Vimeo
    _quality.getQualitiesSync().then((value) {
      final _qualityValue = value[value.lastKey()];

      // Create resolutions map
      Map<String, String> resolutionsMap = {};
      value.keys.forEach((key) {
        String processedKey = key.split(" ")[0];
        resolutionsMap[processedKey] = value[key];
      });

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _qualityValue,
        resolutions: resolutionsMap,
      );

      setState(() {
        _betterPlayerController = BetterPlayerController(
          BetterPlayerConfiguration(
            autoPlay: widget.autoPlay,
            looping: widget.looping,
            fullScreenByDefault: fullScreenByDefault,
            controlsConfiguration: widget.controlsConfig == null
                ? ControlsConfig()
                : widget.controlsConfig as ControlsConfig,
            fit: widget.fullscreenVideoFit,
            autoDetectFullscreenAspectRatio: true,
            deviceOrientationsOnFullScreen:
                widget.deviceOrientationsOnFullScreen,
            deviceOrientationsAfterFullScreen:
                widget.deviceOrientationsAfterFullScreen,
            autoDetectFullscreenDeviceOrientation:
                widget.autoDetectFullscreenDeviceOrientation,
          ),
          betterPlayerDataSource: betterPlayerDataSource,
        );
      });

      //Update orientation and rebuilding page
      // setState(() {
      //   SystemChrome.setPreferredOrientations(
      //       [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
      // });
    });

    // //The video page takes precedence over portrait orientation
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.initState();
  }

  //Build player element
  @override
  Widget build(BuildContext context) {
    return _betterPlayerController == null
        ? AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(
              child: CircularProgressIndicator(
                color: widget.loaderColor,
                backgroundColor: widget.loaderBackgroundColor,
              ),
            ),
          )
        : BetterPlayer(
            controller: _betterPlayerController!,
          );
  }

  @override
  void dispose() {
    // _controller.dispose();
    // initFuture = null;

    super.dispose();
  }
}
