// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:video_player/video_player.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:path_provider/path_provider.dart';
//
// import '../../utilities/database/database_helper.dart';
//
// class MediaProvider with ChangeNotifier {
//   final SharedPreferences _prefs;
//   List<String> _videos = [];
//   List<String> _audios = [];
//   List<Map<String, dynamic>> _favorites = [];
//   final ValueNotifier<Map<String, String?>> _thumbnailCache = ValueNotifier({});
//   VideoPlayerController? _videoController;
//   AudioPlayer? _audioPlayer;
//   Source? _audioSource;
//   bool _isPlaying = false;
//   double _progress = 0.0;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   String? _currentMedia;
//   String? _errorMessage;
//   bool _repeatSong = false;
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//
//   MediaProvider(this._prefs) {
//     loadMedia();
//     _loadFavorites();
//   }
//
//   List<String> get videos => _videos;
//   List<String> get audios => _audios;
//   List<Map<String, dynamic>> get favorites => _favorites;
//   ValueNotifier<Map<String, String?>> get thumbnailCache => _thumbnailCache;
//   VideoPlayerController? get videoController => _videoController;
//   AudioPlayer? get audioPlayer => _audioPlayer;
//   bool get isPlaying => _isPlaying;
//   double get progress => _progress;
//   Duration get currentPosition => _currentPosition;
//   Duration get totalDuration => _totalDuration;
//   String? get currentMedia => _currentMedia;
//   String? get errorMessage => _errorMessage;
//   bool get repeatSong => _repeatSong;
//
//   set repeatSong(bool value) {
//     _repeatSong = value;
//     if (_audioPlayer != null && _audioSource != null) {
//       _audioPlayer!.setReleaseMode(value ? ReleaseMode.loop : ReleaseMode.release);
//     }
//     notifyListeners();
//   }
//
//   Future<void> _loadFavorites() async {
//     _favorites = await _dbHelper.getFavorites();
//     notifyListeners();
//   }
//
//   Future<void> toggleFavorite(String path) async {
//     final isFav = await _dbHelper.isFavorite(path);
//     if (isFav) {
//       await _dbHelper.deleteFavorite(path);
//     } else {
//       await _dbHelper.insertFavorite({
//         'path': path,
//         'title': path.split('/').last, // Placeholder: Use metadata extraction for real title
//         'artist': 'Unknown Artist', // Placeholder
//         'duration': _totalDuration.inSeconds, // Approximate duration
//       });
//     }
//     await _loadFavorites();
//   }
//
//   Future<bool> isFavorite(String path) async {
//     return await _dbHelper.isFavorite(path);
//   }
//
//   // Future<void> loadMedia() async {
//   //   if (await _requestPermissions()) {
//   //     try {
//   //       final directories = [
//   //         '/storage/emulated/0/Download',
//   //         '/storage/emulated/0/Music',
//   //         '/storage/emulated/0/Movies',
//   //         '/storage/emulated/0/DCIM',
//   //       ];
//   //       final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
//   //       final audioExtensions = ['.mp3', '.m4a', '.wav', '.aac'];
//   //
//   //       _videos = [];
//   //       _audios = [];
//   //       _thumbnailCache.value = {};
//   //
//   //       for (final dirPath in directories) {
//   //         final dir = Directory(dirPath);
//   //         if (await dir.exists()) {
//   //           print('Scanning directory: $dirPath');
//   //           final files = await dir.list(recursive: true).toList();
//   //           _videos.addAll(files
//   //               .where((file) =>
//   //           file is File &&
//   //               videoExtensions.any((ext) => file.path.toLowerCase().endsWith(ext)))
//   //               .map((file) => file.path));
//   //           _audios.addAll(files
//   //               .where((file) =>
//   //           file is File &&
//   //               audioExtensions.any((ext) => file.path.toLowerCase().endsWith(ext)))
//   //               .map((file) => file.path));
//   //         } else {
//   //           print('Directory does not exist: $dirPath');
//   //         }
//   //       }
//   //
//   //       _videos = _videos.toSet().toList();
//   //       _audios = _audios.toSet().toList();
//   //
//   //       _thumbnailCache.value = {
//   //         for (var video in _videos) video: null,
//   //       };
//   //
//   //       if (_videos.isEmpty && _audios.isEmpty) {
//   //         _errorMessage = 'No media files found in common directories';
//   //       } else {
//   //         _errorMessage = null;
//   //       }
//   //
//   //       notifyListeners();
//   //
//   //       _generateThumbnailsAsync();
//   //     } catch (e) {
//   //       _errorMessage = 'Error loading media: $e';
//   //       print(_errorMessage);
//   //       notifyListeners();
//   //     }
//   //   } else {
//   //     _errorMessage = 'Storage permissions denied';
//   //     print(_errorMessage);
//   //     notifyListeners();
//   //   }
//   // }
//
//   Future<void> loadMedia() async {
//     if (await _requestPermissions()) {
//       try {
//         final audioExtensions = ['.mp3', '.m4a', '.wav', '.aac'];
//         _audios = [];
//         _videos = []; // Keep videos empty if only loading audio
//         _thumbnailCache.value = {};
//
//         // Define root directories to scan
//         final rootDirs = [
//           '/storage/emulated/0/', // Internal storage
//         ];
//
//         // Add external storage (SD card) if available
//         final externalDirs = await _getExternalStorageDirectories();
//         rootDirs.addAll(externalDirs);
//
//         print('Scanning root directories: $rootDirs');
//
//         for (final dirPath in rootDirs) {
//           final dir = Directory(dirPath);
//           if (await dir.exists()) {
//             await _scanDirectory(dir, audioExtensions);
//           } else {
//             print('Directory does not exist: $dirPath');
//           }
//         }
//
//         // Remove duplicates and sort
//         _audios = _audios.toSet().toList()..sort();
//         _videos = _videos.toSet().toList()..sort();
//
//         if (_audios.isEmpty) {
//           _errorMessage = 'No audio files found on the device';
//         } else {
//           _errorMessage = null;
//         }
//
//         print('Found ${_audios.length} audio files');
//         notifyListeners();
//       } catch (e, stackTrace) {
//         _errorMessage = 'Error loading audio: $e';
//         print('$_errorMessage\n$stackTrace');
//         notifyListeners();
//       }
//     } else {
//       _errorMessage = 'Storage or audio permissions denied';
//       print(_errorMessage);
//       notifyListeners();
//     }
//   }
//
// // Helper method to scan a directory recursively
//   Future<void> _scanDirectory(Directory dir, List<String> audioExtensions) async {
//     try {
//       // Skip system directories to avoid permission issues and improve performance
//       final skipDirs = ['/Android', '/data', '/system', '/cache'];
//       if (skipDirs.any((skip) => dir.path.contains(skip))) {
//         return;
//       }
//
//       await for (final entity in dir.list(recursive: false)) {
//         if (entity is File &&
//             audioExtensions.any((ext) => entity.path.toLowerCase().endsWith(ext))) {
//           if (await _canAccessFile(entity.path)) {
//             _audios.add(entity.path);
//           }
//         } else if (entity is Directory) {
//           // Recursively scan subdirectories
//           await _scanDirectory(entity, audioExtensions);
//         }
//       }
//     } catch (e) {
//       print('Error scanning directory ${dir.path}: $e');
//     }
//   }
//
// // Helper method to get external storage directories (e.g., SD card)
//   Future<List<String>> _getExternalStorageDirectories() async {
//     final externalDirs = <String>[];
//     try {
//       // Get external storage paths using path_provider or manual detection
//       final extDir = await getExternalStorageDirectory();
//       if (extDir != null) {
//         final parent = Directory(extDir.path.split('/Android')[0]);
//         if (await parent.exists()) {
//           externalDirs.add(parent.path);
//         }
//       }
//
//       // Manually check for SD card paths
//       final possibleSdCardPaths = [
//         '/storage/sdcard',
//         '/mnt/sdcard',
//         '/storage/extSdCard',
//       ];
//       for (final path in possibleSdCardPaths) {
//         final dir = Directory(path);
//         if (await dir.exists() && !externalDirs.contains(path)) {
//           externalDirs.add(path);
//         }
//       }
//     } catch (e) {
//       print('Error detecting external storage: $e');
//     }
//     return externalDirs.toSet().toList();
//   }
//   Future<void> _generateThumbnailsAsync() async {
//     final tempDir = await getTemporaryDirectory();
//     for (final videoPath in _videos) {
//       if (_thumbnailCache.value[videoPath] == null) {
//         try {
//           final thumbnailPath = await VideoThumbnail.thumbnailFile(
//             video: videoPath,
//             thumbnailPath: tempDir.path,
//             imageFormat: ImageFormat.PNG,
//             maxHeight: 100,
//             quality: 75,
//           );
//           if (thumbnailPath != null) {
//             _thumbnailCache.value = {
//               ..._thumbnailCache.value,
//               videoPath: thumbnailPath,
//             };
//             _thumbnailCache.notifyListeners();
//           }
//         } catch (e) {
//           print('Error generating thumbnail for $videoPath: $e');
//           _thumbnailCache.value = {
//             ..._thumbnailCache.value,
//             videoPath: null,
//           };
//           _thumbnailCache.notifyListeners();
//         }
//       }
//     }
//   }
//
//   String? getThumbnailPath(String videoPath) {
//     return _thumbnailCache.value[videoPath];
//   }
//
//   Future<void> pickMediaManually() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.media,
//         allowMultiple: true,
//       );
//       if (result != null) {
//         final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
//         final audioExtensions = ['mp3', 'm4a', 'wav', 'aac'];
//         final newVideos = result.files
//             .where((file) => videoExtensions.contains(file.extension?.toLowerCase()))
//             .map((file) => file.path!)
//             .toList();
//         final newAudios = result.files
//             .where((file) => audioExtensions.contains(file.extension?.toLowerCase()))
//             .map((file) => file.path!)
//             .toList();
//
//         _videos.addAll(newVideos);
//         _audios.addAll(newAudios);
//         _videos = _videos.toSet().toList();
//         _audios = _audios.toSet().toList();
//
//         final updatedCache = Map<String, String?>.from(_thumbnailCache.value);
//         for (var video in newVideos) {
//           updatedCache[video] = null;
//         }
//         _thumbnailCache.value = updatedCache;
//         notifyListeners();
//
//         _generateThumbnailsAsync();
//
//         _errorMessage = _videos.isEmpty && _audios.isEmpty
//             ? 'No media files selected'
//             : null;
//         print('Manually picked videos: ${_videos.length}, audios: ${_audios.length}');
//         notifyListeners();
//       } else {
//         _errorMessage = 'No files selected';
//         print(_errorMessage);
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = 'Error picking media: $e';
//       print(_errorMessage);
//       notifyListeners();
//     }
//   }
//
//   Future<bool> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses;
//     final androidInfo = await DeviceInfoPlugin().androidInfo;
//     final sdkVersion = androidInfo.version.sdkInt ?? 0;
//
//     if (Platform.isAndroid && sdkVersion >= 33) {
//       statuses = await [
//         Permission.videos,
//         Permission.audio,
//       ].request();
//     } else if (Platform.isAndroid && sdkVersion >= 30) {
//       statuses = await [
//         Permission.storage,
//         Permission.manageExternalStorage,
//       ].request();
//     } else {
//       statuses = await [Permission.storage].request();
//     }
//     final granted = statuses.values.every((status) => status.isGranted);
//     print('Permissions granted: $granted, SDK: $sdkVersion');
//     return granted;
//   }
//
//   Future<bool> _canAccessFile(String path) async {
//     try {
//       final file = File(path);
//       return await file.exists() && await file.length() > 0;
//     } catch (e) {
//       print('Cannot access file $path: $e');
//       return false;
//     }
//   }
//
//   Future<void> playVideo(String path) async {
//     if (!(await _canAccessFile(path))) {
//       _errorMessage = 'Cannot access video file: $path';
//       print(_errorMessage);
//       notifyListeners();
//       return;
//     }
//     _currentMedia = path;
//     _videoController?.dispose();
//     _audioPlayer?.dispose();
//     _audioSource = null;
//     _videoController = VideoPlayerController.file(File(path))
//       ..initialize().then((_) {
//         _videoController!.play();
//         _isPlaying = true;
//         _updateProgress();
//         _videoController!.addListener(() {
//           if (_videoController!.value.isInitialized &&
//               _videoController!.value.position >= _videoController!.value.duration &&
//               _isPlaying) {
//             pause();
//           }
//         });
//         notifyListeners();
//       }).catchError((e) {
//         _errorMessage = 'Error playing video: $e';
//         print(_errorMessage);
//         notifyListeners();
//       });
//   }
//
//   Future<void> playAudio(String path) async {
//     if (!(await _canAccessFile(path))) {
//       _errorMessage = 'Cannot access audio file: $path';
//       print(_errorMessage);
//       notifyListeners();
//       return;
//     }
//     _currentMedia = path;
//     _videoController?.dispose();
//     _audioPlayer?.dispose();
//     _audioPlayer = AudioPlayer();
//     _audioSource = UrlSource('file://$path');
//     try {
//       _audioPlayer!.setReleaseMode(_repeatSong ? ReleaseMode.loop : ReleaseMode.release);
//       await _audioPlayer!.play(_audioSource!);
//       _isPlaying = true;
//       _updateAudioProgress();
//       _audioPlayer!.onPlayerComplete.listen((_) {
//         playNext(_audios);
//       });
//       notifyListeners();
//     } catch (e) {
//       print('UrlSource failed: $e');
//       _errorMessage = 'Error playing audio: $e';
//       notifyListeners();
//     }
//   }
//
//   void pause() {
//     if (_videoController != null) {
//       _videoController!.pause();
//     } else if (_audioPlayer != null) {
//       _audioPlayer!.pause();
//     }
//     _isPlaying = false;
//     notifyListeners();
//   }
//
//   void resume() {
//     if (_videoController != null) {
//       _videoController!.play();
//     } else if (_audioPlayer != null && _audioSource != null) {
//       _audioPlayer!.play(_audioSource!);
//     }
//     _isPlaying = true;
//     notifyListeners();
//   }
//
//   void seekTo(Duration position) {
//     if (_videoController != null) {
//       _videoController!.seekTo(position);
//     } else if (_audioPlayer != null) {
//       _audioPlayer!.seek(position);
//     }
//     notifyListeners();
//   }
//
//   void _updateProgress() {
//     _videoController?.addListener(() {
//       if (_videoController!.value.isInitialized) {
//         _currentPosition = _videoController!.value.position;
//         _totalDuration = _videoController!.value.duration;
//         _progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
//         notifyListeners();
//       }
//     });
//   }
//
//   void _updateAudioProgress() {
//     _audioPlayer?.onPositionChanged.listen((position) {
//       _currentPosition = position;
//       _audioPlayer?.getDuration().then((duration) {
//         if (duration != null) {
//           _totalDuration = duration;
//           _progress = position.inMilliseconds / duration.inMilliseconds;
//           notifyListeners();
//         }
//       });
//     });
//   }
//
//   void playNext(List<String> mediaList) {
//     if (_currentMedia == null || mediaList.isEmpty) return;
//     if (_repeatSong) {
//       playAudio(_currentMedia!);
//     } else {
//       final currentIndex = mediaList.indexOf(_currentMedia!);
//       if (currentIndex < mediaList.length - 1) {
//         final nextMedia = mediaList[currentIndex + 1];
//         if (nextMedia.toLowerCase().endsWith('.mp4') ||
//             nextMedia.toLowerCase().endsWith('.mov') ||
//             nextMedia.toLowerCase().endsWith('.avi') ||
//             nextMedia.toLowerCase().endsWith('.mkv')) {
//           playVideo(nextMedia);
//         } else {
//           playAudio(nextMedia);
//         }
//       } else {
//         final firstMedia = mediaList[0];
//         if (firstMedia.toLowerCase().endsWith('.mp4') ||
//             firstMedia.toLowerCase().endsWith('.mov') ||
//             firstMedia.toLowerCase().endsWith('.avi') ||
//             firstMedia.toLowerCase().endsWith('.mkv')) {
//           playVideo(firstMedia);
//         } else {
//           playAudio(firstMedia);
//         }
//       }
//     }
//   }
//
//   void playPrevious(List<String> mediaList) {
//     if (_currentMedia == null || mediaList.isEmpty) return;
//     final currentIndex = mediaList.indexOf(_currentMedia!);
//     if (currentIndex > 0) {
//       final prevMedia = mediaList[currentIndex - 1];
//       if (prevMedia.toLowerCase().endsWith('.mp4') ||
//           prevMedia.toLowerCase().endsWith('.mov') ||
//           prevMedia.toLowerCase().endsWith('.avi') ||
//           prevMedia.toLowerCase().endsWith('.mkv')) {
//         playVideo(prevMedia);
//       } else {
//         playAudio(prevMedia);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _videoController?.dispose();
//     _audioPlayer?.dispose();
//     _thumbnailCache.dispose();
//     _dbHelper.close();
//     super.dispose();
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../utilities/database/database_helper.dart';

class MediaProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<Map<String, dynamic>> _audios = [
  ]; // Changed from List<String> to store metadata
  List<String> _videos = [];
  List<Map<String, dynamic>> _favorites = [];
  final ValueNotifier<Map<String, String?>> _thumbnailCache = ValueNotifier({});
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Source? _audioSource;
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _currentMedia;
  String? _errorMessage;
  bool _repeatSong = false;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const platform = MethodChannel('com.example.s_player/metadata');

  MediaProvider(this._prefs) {
    loadMedia();
    _loadFavorites();
  }

  // Getters updated for audios
  List<Map<String, dynamic>> get audios => _audios;

  set audios(List<Map<String, dynamic>> value) {
    _audios = value;
    notifyListeners();
  }
  List<String> get videos => _videos;

  List<Map<String, dynamic>> get favorites => _favorites;

  ValueNotifier<Map<String, String?>> get thumbnailCache => _thumbnailCache;

  VideoPlayerController? get videoController => _videoController;

  AudioPlayer? get audioPlayer => _audioPlayer;

  bool get isPlaying => _isPlaying;

  double get progress => _progress;

  Duration get currentPosition => _currentPosition;

  Duration get totalDuration => _totalDuration;

  String? get currentMedia => _currentMedia;

  String? get errorMessage => _errorMessage;

  bool get repeatSong => _repeatSong;

  // New getters for artists, albums, and folders
  List<String> get artists =>
      _audios.map((audio) => audio['artist'] as String).toSet().toList()
        ..sort();

  List<String> get albums =>
      _audios.map((audio) => audio['album'] as String).toSet().toList()
        ..sort();

  List<String> get folders =>
      _audios.map((audio) => audio['folder'] as String).toSet().toList()
        ..sort();

  set repeatSong(bool value) {
    _repeatSong = value;
    if (_audioPlayer != null && _audioSource != null) {
      _audioPlayer!.setReleaseMode(
          value ? ReleaseMode.loop : ReleaseMode.release);
    }
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    _favorites = await _dbHelper.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(String path) async {
    final isFav = await _dbHelper.isFavorite(path);
    if (isFav) {
      await _dbHelper.deleteFavorite(path);
    } else {
      final audio = _audios.firstWhere((a) => a['path'] == path,
          orElse: () => {});
      if (audio.isNotEmpty) {
        await _dbHelper.insertFavorite({
          'path': path,
          'title': audio['title'] ?? p.basenameWithoutExtension(path),
          'artist': audio['artist'] ?? 'Unknown Artist',
          'duration': _totalDuration.inSeconds,
        });
      }
    }
    await _loadFavorites();
  }

  Future<bool> isFavorite(String path) async {
    return await _dbHelper.isFavorite(path);
  }

  Future<void> loadMedia() async {
    if (await _requestPermissions()) {
      try {
        final audioExtensions = ['.mp3', '.m4a', '.wav', '.aac'];
        _audios = [];
        _videos = [];
        _thumbnailCache.value = {};
        final audioPaths = <String>{}; // To track unique audio paths

        final rootDirs = ['/storage/emulated/0/'];
        final externalDirs = await _getExternalStorageDirectories();
        rootDirs.addAll(externalDirs);

        print('Scanning root directories: $rootDirs');

        for (final dirPath in rootDirs) {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            await _scanDirectory(dir, audioExtensions, audioPaths);
          } else {
            print('Directory does not exist: $dirPath');
          }
        }

        _audios.sort((a, b) =>
            (a['title'] as String).compareTo(b['title'] as String));

        if (_audios.isEmpty) {
          _errorMessage = 'No audio files found on the device';
        } else {
          _errorMessage = null;
        }

        print('Found ${_audios.length} audio files');
        notifyListeners();
      } catch (e, stackTrace) {
        _errorMessage = 'Error loading audio: $e';
        print('$_errorMessage\n$stackTrace');
        notifyListeners();
      }
    } else {
      _errorMessage = 'Storage or audio permissions denied';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<void> _scanDirectory(Directory dir, List<String> audioExtensions,
      Set<String> audioPaths) async {
    try {
      final skipDirs = [
        '/Android',
        '/data',
        '/system',
        '/cache',
        '/WhatsApp',
        '/Recordings',
        '/DCIM/.thumbnails',
        '/Download/Telegram',
        '/Voice Recorder',
        '/Call Recorder',
      ];
      if (skipDirs.any((skip) =>
          dir.path.toLowerCase().contains(skip.toLowerCase()))) {
        print('Skipping private directory: ${dir.path}');
        return;
      }

      await for (final entity in dir.list(recursive: false)) {
        if (entity is File &&
            audioExtensions.any((ext) =>
                entity.path.toLowerCase().endsWith(ext))) {
          if (await _canAccessFile(entity.path) &&
              !audioPaths.contains(entity.path)) {
            final metadata = await _extractMetadata(entity.path);
            _audios.add({
              'path': entity.path,
              'title': metadata['title'] ??
                  p.basenameWithoutExtension(entity.path),
              'artist': metadata['artist'] ?? 'Unknown Artist',
              'album': metadata['album'] ?? 'Unknown Album',
              'folder': p.dirname(entity.path),
            });
            audioPaths.add(entity.path);
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, audioExtensions, audioPaths);
        }
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
    }
  }

  Future<Map<String, String>> _extractMetadata(String path) async {
    try {
      if (Platform.isAndroid) {
        final metadata = await platform.invokeMethod(
            'getMetadata', {'path': path});
        return {
          'title': (metadata['title'] as String?)?.isNotEmpty == true
              ? metadata['title']
              : '',
          'artist': (metadata['artist'] as String?)?.isNotEmpty == true
              ? metadata['artist']
              : 'Unknown Artist',
          'album': (metadata['album'] as String?)?.isNotEmpty == true
              ? metadata['album']
              : 'Unknown Album',
        };
      } else {
        return {
          'title': '',
          'artist': 'Unknown Artist',
          'album': 'Unknown Album',
        };
      }
    } on PlatformException catch (e) {
      print('PlatformException extracting metadata for $path: $e');
      return {
        'title': '',
        'artist': 'Unknown Artist',
        'album': 'Unknown Album',
      };
    } catch (e) {
      print('Error extracting metadata for $path: $e');
      return {
        'title': '',
        'artist': 'Unknown Artist',
        'album': 'Unknown Album',
      };
    }
  }

  Future<List<String>> _getExternalStorageDirectories() async {
    final externalDirs = <String>[];
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final parent = Directory(extDir.path.split('/Android')[0]);
        if (await parent.exists()) {
          externalDirs.add(parent.path);
        }
      }
      final possibleSdCardPaths = [
        '/storage/sdcard',
        '/mnt/sdcard',
        '/storage/extSdCard',
      ];
      for (final path in possibleSdCardPaths) {
        final dir = Directory(path);
        if (await dir.exists() && !externalDirs.contains(path)) {
          externalDirs.add(path);
        }
      }
    } catch (e) {
      print('Error detecting external storage: $e');
    }
    return externalDirs.toSet().toList();
  }

  Future<void> _generateThumbnailsAsync() async {
    final tempDir = await getTemporaryDirectory();
    for (final videoPath in _videos) {
      if (_thumbnailCache.value[videoPath] == null) {
        try {
          final thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: videoPath,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.PNG,
            maxHeight: 100,
            quality: 75,
          );
          if (thumbnailPath != null) {
            _thumbnailCache.value = {
              ..._thumbnailCache.value,
              videoPath: thumbnailPath,
            };
            _thumbnailCache.notifyListeners();
          }
        } catch (e) {
          print('Error generating thumbnail for $videoPath: $e');
          _thumbnailCache.value = {
            ..._thumbnailCache.value,
            videoPath: null,
          };
          _thumbnailCache.notifyListeners();
        }
      }
    }
  }

  String? getThumbnailPath(String videoPath) {
    return _thumbnailCache.value[videoPath];
  }

  Future<void> pickMediaManually() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result != null) {
        final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
        final audioExtensions = ['mp3', 'm4a', 'wav', 'aac'];
        final newVideos = result.files
            .where((file) =>
            videoExtensions.contains(file.extension?.toLowerCase()))
            .map((file) => file.path!)
            .toList();
        final newAudios = result.files
            .where((file) =>
            audioExtensions.contains(file.extension?.toLowerCase()))
            .map((file) => file.path!)
            .toList();
        final audioPaths = _audios.map((a) => a['path'] as String).toSet();

        for (final path in newAudios) {
          if (!audioPaths.contains(path)) {
            final metadata = await _extractMetadata(path);
            _audios.add({
              'path': path,
              'title': metadata['title'] ?? p.basenameWithoutExtension(path),
              'artist': metadata['artist'] ?? 'Unknown Artist',
              'album': metadata['album'] ?? 'Unknown Album',
              'folder': p.dirname(path),
            });
            audioPaths.add(path);
          }
        }
        _videos.addAll(newVideos.where((v) => !_videos.contains(v)));
        _videos = _videos.toSet().toList();
        _audios = _audios.toSet().toList();

        final updatedCache = Map<String, String?>.from(_thumbnailCache.value);
        for (var video in newVideos) {
          updatedCache[video] = null;
        }
        _thumbnailCache.value = updatedCache;
        notifyListeners();

        _generateThumbnailsAsync();

        _errorMessage = _videos.isEmpty && _audios.isEmpty
            ? 'No media files selected'
            : null;
        print('Manually picked videos: ${_videos.length}, audios: ${_audios
            .length}');
        notifyListeners();
      } else {
        _errorMessage = 'No files selected';
        print(_errorMessage);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error picking media: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt ?? 0;

    if (Platform.isAndroid && sdkVersion >= 33) {
      statuses = await [
        Permission.videos,
        Permission.audio,
      ].request();
    } else if (Platform.isAndroid && sdkVersion >= 30) {
      statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
    } else {
      statuses = await [Permission.storage].request();
    }
    final granted = statuses.values.every((status) => status.isGranted);
    print('Permissions granted: $granted, SDK: $sdkVersion');
    return granted;
  }

  Future<bool> _canAccessFile(String path) async {
    try {
      final file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      print('Cannot access file $path: $e');
      return false;
    }
  }

  Future<void> playVideo(String path) async {
    if (!(await _canAccessFile(path))) {
      _errorMessage = 'Cannot access video file: $path';
      print(_errorMessage);
      notifyListeners();
      return;
    }
    _currentMedia = path;
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _audioSource = null;
    _videoController = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        _videoController!.play();
        _isPlaying = true;
        _updateProgress();
        _videoController!.addListener(() {
          if (_videoController!.value.isInitialized &&
              _videoController!.value.position >=
                  _videoController!.value.duration &&
              _isPlaying) {
            pause();
          }
        });
        notifyListeners();
      }).catchError((e) {
        _errorMessage = 'Error playing video: $e';
        print(_errorMessage);
        notifyListeners();
      });
  }

  Future<void> playAudio(String path) async {
    if (!(await _canAccessFile(path))) {
      _errorMessage = 'Cannot access audio file: $path';
      print(_errorMessage);
      notifyListeners();
      return;
    }
    _currentMedia = path;
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();
    _audioSource = UrlSource('file://$path');
    try {
      _audioPlayer!.setReleaseMode(
          _repeatSong ? ReleaseMode.loop : ReleaseMode.release);
      await _audioPlayer!.play(_audioSource!);
      _isPlaying = true;
      _updateAudioProgress();
      _audioPlayer!.onPlayerComplete.listen((_) {
        playNext(_audios.map((a) => a['path'] as String).toList());
      });
      notifyListeners();
    } catch (e) {
      print('UrlSource failed: $e');
      _errorMessage = 'Error playing audio: $e';
      notifyListeners();
    }
  }

  void pause() {
    if (_videoController != null) {
      _videoController!.pause();
    } else if (_audioPlayer != null) {
      _audioPlayer!.pause();
    }
    _isPlaying = false;
    notifyListeners();
  }

  void resume() {
    if (_videoController != null) {
      _videoController!.play();
    } else if (_audioPlayer != null && _audioSource != null) {
      _audioPlayer!.play(_audioSource!);
    }
    _isPlaying = true;
    notifyListeners();
  }

  void seekTo(Duration position) {
    if (_videoController != null) {
      _videoController!.seekTo(position);
    } else if (_audioPlayer != null) {
      _audioPlayer!.seek(position);
    }
    notifyListeners();
  }

  void _updateProgress() {
    _videoController?.addListener(() {
      if (_videoController!.value.isInitialized) {
        _currentPosition = _videoController!.value.position;
        _totalDuration = _videoController!.value.duration;
        _progress =
            _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
        notifyListeners();
      }
    });
  }

  void _updateAudioProgress() {
    _audioPlayer?.onPositionChanged.listen((position) {
      _currentPosition = position;
      _audioPlayer?.getDuration().then((duration) {
        if (duration != null) {
          _totalDuration = duration;
          _progress = position.inMilliseconds / duration.inMilliseconds;
          notifyListeners();
        }
      });
    });
  }

  void playNext(List<String> mediaList) {
    if (_currentMedia == null || mediaList.isEmpty) return;
    if (_repeatSong) {
      playAudio(_currentMedia!);
    } else {
      final currentIndex = mediaList.indexOf(_currentMedia!);
      if (currentIndex < mediaList.length - 1) {
        final nextMedia = mediaList[currentIndex + 1]; // Increment index by 1
        if (nextMedia.toLowerCase().endsWith('.mp4') ||
            nextMedia.toLowerCase().endsWith('.mov') ||
            nextMedia.toLowerCase().endsWith('.avi') ||
            nextMedia.toLowerCase().endsWith('.mkv')) {
          playVideo(nextMedia);
        } else {
          playAudio(nextMedia);
        }
      } else {
        final firstMedia = mediaList[0];
        if (firstMedia.toLowerCase().endsWith('.mp4') ||
            firstMedia.toLowerCase().endsWith('.mov') ||
            firstMedia.toLowerCase().endsWith('.avi') ||
            firstMedia.toLowerCase().endsWith('.mkv')) {
          playVideo(firstMedia);
        } else {
          playAudio(firstMedia);
        }
      }
    }
  }

  void playPrevious(List<String> mediaList) {
    if (_currentMedia == null || mediaList.isEmpty) return;
    final currentIndex = mediaList.indexOf(_currentMedia!);
    if (currentIndex > 0) {
      final prevMedia = mediaList[currentIndex - 1];
      if (prevMedia.toLowerCase().endsWith('.mp4') ||
          prevMedia.toLowerCase().endsWith('.mov') ||
          prevMedia.toLowerCase().endsWith('.avi') ||
          prevMedia.toLowerCase().endsWith('.mkv')) {
        playVideo(prevMedia);
      } else {
        playAudio(prevMedia);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _thumbnailCache.dispose();
    _dbHelper.close();
    super.dispose();
  }
}