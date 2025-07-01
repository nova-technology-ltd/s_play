import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoPlayerController;
  String? _currentMedia;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _repeatSong = false;
  Function(String)? _onComplete;
  SharedPreferences? _prefs;

  AudioPlayerProvider() {
    _initPrefs(); // Initialize SharedPreferences
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_repeatSong) {
        playAudio(_currentMedia!);
      } else if (_onComplete != null) {
        _onComplete!(_currentMedia!);
      }
    });
  }

  // Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Restore last played audio
    final lastPlayed = _prefs?.getString('current_audio');
    if (lastPlayed != null && await _canAccessFile(lastPlayed)) {
      _currentMedia = lastPlayed;
      notifyListeners();
    }
  }

  String? get currentMedia => _currentMedia;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get progress => _totalDuration.inMilliseconds > 0
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
      : 0.0;
  bool get repeatSong => _repeatSong;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  set repeatSong(bool value) {
    _repeatSong = value;
    notifyListeners();
  }

  Future<void> playAudio(String path, {Function(String)? onComplete}) async {
    try {
      if (_currentMedia != path) {
        await _audioPlayer.stop();
        _currentMedia = path;
        _onComplete = onComplete;
        await _audioPlayer.play(DeviceFileSource(path));
        _isPlaying = true;
        // Save the current audio path to SharedPreferences
        await _prefs?.setString('current_audio', path);
        notifyListeners();
      } else if (!_isPlaying) {
        await resume();
      }
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playVideo(String path) async {
    try {
      await _videoPlayerController?.dispose();
      _currentMedia = path;
      // Save video path to SharedPreferences (if you want to persist videos too)
      await _prefs?.setString('current_audio', path);
      _videoPlayerController = VideoPlayerController.file(File(path))
        ..initialize().then((_) {
          _videoPlayerController!.play();
          _isPlaying = true;
          notifyListeners();
        }).catchError((e) {
          print('Error initializing video: $e');
          _isPlaying = false;
          notifyListeners();
        });
      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.isPlaying != _isPlaying) {
          _isPlaying = _videoPlayerController!.value.isPlaying;
          notifyListeners();
        }
        _currentPosition = _videoPlayerController!.value.position;
        _totalDuration = _videoPlayerController!.value.duration;
        notifyListeners();
      });
    } catch (e) {
      print('Error playing video: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
        await _videoPlayerController!.pause();
      } else if (_isPlaying) {
        await _audioPlayer.pause();
      }
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (_videoPlayerController != null && !_videoPlayerController!.value.isPlaying) {
        await _videoPlayerController!.play();
      } else if (!_isPlaying && _currentMedia != null) {
        await _audioPlayer.resume();
      }
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error resuming: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.seekTo(position);
      } else {
        await _audioPlayer.seek(position);
      }
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  void playNext(List<String> playlist) {
    if (_currentMedia == null || playlist.isEmpty) return;
    final currentIndex = playlist.indexOf(_currentMedia!);
    if (currentIndex < playlist.length - 1) {
      playAudio(playlist[currentIndex + 1], onComplete: (completedPath) {
        playNext(playlist);
      });
    } else if (_repeatSong) {
      playAudio(playlist[currentIndex], onComplete: (completedPath) {
        playNext(playlist);
      });
    }
  }

  void playPrevious(List<String> playlist) {
    if (_currentMedia == null || playlist.isEmpty) return;
    final currentIndex = playlist.indexOf(_currentMedia!);
    if (currentIndex > 0) {
      playAudio(playlist[currentIndex - 1], onComplete: (completedPath) {
        playNext(playlist);
      });
    } else if (_repeatSong) {
      playAudio(playlist[currentIndex], onComplete: (completedPath) {
        playNext(playlist);
      });
    }
  }

  // Check if a file is accessible
  Future<bool> _canAccessFile(String path) async {
    try {
      final file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}