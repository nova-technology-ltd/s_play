import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';
import '../../../utilities/constants/app_icons.dart';
import '../../state_management/media_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int _rotation = 0; // 0, 1, 2, 3 representing 0°, 90°, 180°, 270°
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isLocked = false; // New flag for lock state
  bool _isMuted = false; // New flag for mute state
  Timer? _seekDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
    // Listen for device orientation changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRotationFromDevice();
    });
  }

  // Update _rotation based on device orientation
  void _updateRotationFromDevice() {
    final orientation = MediaQuery.of(context).orientation;
    setState(() {
      if (orientation == Orientation.landscape) {
        _rotation = 1; // 90° for landscape
        _isFullscreen = true;
      } else {
        _rotation = 0; // 0° for portrait
        _isFullscreen = false;
      }
      _scale = 1.0;
      _offset = Offset.zero;
      _setOrientation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final videoController = provider.videoController;
    final isVideo = provider.currentMedia?.toLowerCase().endsWith('.mp4') ??
        provider.currentMedia?.toLowerCase().endsWith('.mov') ??
        provider.currentMedia?.toLowerCase().endsWith('.avi') ??
        provider.currentMedia?.toLowerCase().endsWith('.mkv') ??
        false;
    final mediaList = isVideo ? provider.videos : provider.audios;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = _rotation % 2 == 0;
    final videoAspectRatio = videoController != null && videoController.value.isInitialized
        ? videoController.value.aspectRatio
        : 16 / 9;

    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _isFullscreen ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _isLocked
                  ? null
                  : () {
                setState(() {
                  _showControls = !_showControls;
                  if (_showControls) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) setState(() => _showControls = false);
                    });
                  }
                });
              },
              onScaleStart: _isLocked
                  ? null
                  : (details) {
                _previousScale = _scale;
                _previousOffset = details.focalPoint;
              },
              onScaleUpdate: _isLocked
                  ? null
                  : (details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
                  final currentOffset = details.focalPoint;
                  final delta = currentOffset - _previousOffset;
                  _offset += delta / _scale;
                  _previousOffset = currentOffset;
                  final maxOffsetX = (screenWidth * (_scale - 1)) / 2;
                  final maxOffsetY = (screenHeight * (_scale - 1)) / 2;
                  _offset = Offset(
                    _offset.dx.clamp(-maxOffsetX, maxOffsetX),
                    _offset.dy.clamp(-maxOffsetY, maxOffsetY),
                  );
                });
              },
              onDoubleTap: _isLocked
                  ? null
                  : () {
                setState(() {
                  _scale = _scale == 1.0 ? 2.0 : 1.0;
                  _offset = Offset.zero;
                });
              },
              child: Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_offset.dx, _offset.dy)
                    ..scale(_scale)
                    ..rotateZ(_rotation * (3.14159265359 / 2)),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: isPortrait ? screenWidth : screenHeight,
                    height: isPortrait ? screenWidth / videoAspectRatio : screenHeight / videoAspectRatio,
                    child: videoController != null && videoController.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: videoAspectRatio,
                      child: VideoPlayer(videoController),
                    )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
            if (_showControls) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: themeProvider ? null : Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _isLocked
                        ? null
                        : () {
                      Navigator.of(context).pop();
                      provider.pause();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _isLocked ? null : _toggleFullscreen,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onHorizontalDragUpdate: _isLocked
                            ? null
                            : (details) {
                          final barWidth = MediaQuery.of(context).size.width - 32;
                          final dragPosition = details.localPosition.dx.clamp(0.0, barWidth);
                          final progress = dragPosition / barWidth;
                          final seekPosition = provider.totalDuration * progress;
                          provider.seekTo(seekPosition);
                        },
                        onTapDown: _isLocked
                            ? null
                            : (details) {
                          final barWidth = MediaQuery.of(context).size.width - 32;
                          final tapPosition = details.localPosition.dx.clamp(0.0, barWidth);
                          final progress = tapPosition / barWidth;
                          final seekPosition = provider.totalDuration * progress;
                          provider.seekTo(seekPosition);
                        },
                        child: Container(
                          height: 8,
                          width: MediaQuery.of(context).size.width,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 8,
                                  width: MediaQuery.of(context).size.width * provider.progress,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(provider.currentPosition),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(provider.totalDuration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // SafeArea(
                      //   child: !isPortrait
                      //       ? Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: _buildControlButtons(provider, mediaList, themeProvider),
                      //   )
                      //       : SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //       children: _buildControlButtons(provider, mediaList, themeProvider),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildControlButtons(
      MediaProvider provider,
      List<String> mediaList,
      bool themeProvider,
      ) {
    return [
      IconButton(
        icon: Icon(
          _isLocked ? IconlyLight.lock : IconlyLight.unlock,
          color: Colors.white,
          size: 25,
        ),
        onPressed: () {
          setState(() {
            _isLocked = !_isLocked;
            if (_isLocked) {
              _showControls = true; // Keep controls visible when locked
            } else {
              // Auto-hide controls after 3 seconds when unlocked
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted && !_isLocked) setState(() => _showControls = false);
              });
            }
          });
        },
      ),
      IconButton(
        icon: const Icon(
          Icons.fullscreen_rounded,
          color: Colors.white,
          size: 28,
        ),
        onPressed: _isLocked ? null : _toggleFullscreen,
      ),
      IconButton(
        icon: SizedBox(
          height: 28,
          width: 28,
          child: Image.asset(
            AppIcons.playPrevFilledIcon,
            color: themeProvider ? Colors.white : Colors.black,
          ),
        ),
        onPressed: _isLocked ? null : () => provider.playPrevious(mediaList),
      ),
      IconButton(
        icon: SizedBox(
          height: 28,
          width: 28,
          child: Image.asset(
            provider.isPlaying ? AppIcons.pauseFilledIcon : AppIcons.playFiledIcon,
            color: themeProvider ? Colors.white : Colors.black,
          ),
        ),
        onPressed: _isLocked
            ? null
            : () {
          if (provider.isPlaying) {
            provider.pause();
          } else {
            provider.resume();
          }
        },
      ),
      IconButton(
        icon: SizedBox(
          height: 28,
          width: 28,
          child: Image.asset(
            AppIcons.playNextFilledIcon,
            color: themeProvider ? Colors.white : Colors.black,
          ),
        ),
        onPressed: _isLocked ? null : () => provider.playNext(mediaList),
      ),
      IconButton(
        icon: Icon(
          _isMuted ? IconlyLight.volume_off : IconlyLight.volume_up,
          color: Colors.white,
          size: 25,
        ),
        onPressed: _isLocked
            ? null
            : () {
          setState(() {
            _isMuted = !_isMuted;
            if (provider.videoController != null) {
              provider.videoController!.setVolume(_isMuted ? 0.0 : 1.0);
            } else if (provider.audioPlayer != null) {
              provider.audioPlayer!.setVolume(_isMuted ? 0.0 : 1.0);
            }
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.rotate_right, color: Colors.white, size: 28),
        onPressed: _isLocked ? null : _rotateVideo,
      ),
    ];
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _rotateVideo() {
    setState(() {
      _rotation = (_rotation + 1) % 4;
      _scale = 1.0;
      _offset = Offset.zero;
      _isFullscreen = _rotation % 2 == 1;
      _setOrientation();
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (!_isFullscreen) {
        _rotation = 0; // Reset to portrait when exiting fullscreen
      }
      _setOrientation();
    });
  }

  void _setOrientation() {
    if (_isFullscreen) {
      if (_rotation % 2 == 0) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _seekDebounceTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}