import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../utilities/database/database_helper.dart';

class MediaScannerProvider with ChangeNotifier {
  List<Map<String, dynamic>> _audios = [];
  List<String> _videos = []; // Fixed variable name
  List<Map<String, dynamic>> _favorites = [];
  final ValueNotifier<Map<String, String?>> _thumbnailCache = ValueNotifier({});
  String? _errorMessage;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const platform = MethodChannel('com.example.s_player/metadata');

  MediaScannerProvider() {
    loadMedia(); // Scan media on initialization
    _loadFavorites();
  }

  List<Map<String, dynamic>> get audios => _audios;
  List<String> get videos => _videos;
  List<Map<String, dynamic>> get favorites => _favorites;
  ValueNotifier<Map<String, String?>> get thumbnailCache => _thumbnailCache;
  String? get errorMessage => _errorMessage;

  List<String> get artists =>
      _audios.map((audio) => audio['artist'] as String).toSet().toList()..sort();
  List<String> get albums =>
      _audios.map((audio) => audio['album'] as String).toSet().toList()..sort();
  List<String> get folders =>
      _audios.map((audio) => audio['folder'] as String).toSet().toList()..sort();

  List<Map<String, dynamic>> getAudiosByArtist(String artist) =>
      _audios.where((audio) => audio['artist'] == artist).toList();
  List<Map<String, dynamic>> getAudiosByAlbum(String album) =>
      _audios.where((audio) => audio['album'] == album).toList();
  List<Map<String, dynamic>> getAudiosByFolder(String folder) =>
      _audios.where((audio) => audio['folder'] == folder).toList();

  Future<void> _loadFavorites() async {
    try {
      _favorites = await _dbHelper.getFavorites();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading favorites: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String path) async {
    try {
      final isFav = await _dbHelper.isFavorite(path);
      if (isFav) {
        await _dbHelper.deleteFavorite(path);
      } else {
        final audio = _audios.firstWhere((a) => a['path'] == path, orElse: () => {});
        if (audio.isNotEmpty) {
          await _dbHelper.insertFavorite({
            'path': path,
            'title': audio['title'] ?? 'Unknown Title',
            'artist': audio['artist'] ?? 'Unknown Artist',
            'album': audio['album'] ?? 'Unknown Album',
            'albumArt': audio['albumArt'],
            'duration': audio['duration'] ?? 0,
          });
        } else {
          _errorMessage = 'Audio not found in library';
          notifyListeners();
          return;
        }
      }
      await _loadFavorites();
    } catch (e) {
      _errorMessage = e is DatabaseException ? e.message : 'Error toggling favorite: $e';
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String path) async {
    try {
      return await _dbHelper.isFavorite(path);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<void> loadMedia() async {
    if (await _requestPermissions()) {
      try {
        final audioExtensions = ['.mp3', '.m4a', '.wav', '.aac'];
        final newAudios = <Map<String, dynamic>>[];
        final newVideos = <String>[];

        final rootDirs = ['/storage/emulated/0/'];
        final externalDirs = await _getExternalStorageDirectories();
        rootDirs.addAll(externalDirs);

        for (final dirPath in rootDirs) {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            await _scanDirectory(dir, audioExtensions, newAudios, newVideos);
          }
        }

        // Remove duplicates by path
        final uniqueAudios = <String, Map<String, dynamic>>{};
        for (var audio in newAudios) {
          uniqueAudios[audio['path']] = audio;
        }
        _audios = uniqueAudios.values.toList();

        _sortAudios(); // Centralized sorting logic

        _videos = newVideos.toSet().toList();

        if (_audios.isEmpty && _videos.isEmpty) {
          _errorMessage = 'No media files found on the device';
        } else {
          _errorMessage = null;
        }

        notifyListeners();
        _generateThumbnailsAsync();
      } catch (e, stackTrace) {
        _errorMessage = 'Error loading media: $e';
        print('$_errorMessage\n$stackTrace');
        notifyListeners();
      }
    } else {
      _errorMessage = 'Storage or media permissions denied. Please grant permissions in settings.';
      notifyListeners();
    }
  }

  void _sortAudios() {
    _audios.sort((a, b) {
      final titleA = (a['title'] ?? '').trim();
      final titleB = (b['title'] ?? '').trim();
      final aIsInvalid = titleA.isEmpty || RegExp(r'^\d').hasMatch(titleA);
      final bIsInvalid = titleB.isEmpty || RegExp(r'^\d').hasMatch(titleB);

      if (aIsInvalid && !bIsInvalid) return 1; // a goes to bottom
      if (!aIsInvalid && bIsInvalid) return -1; // b goes to bottom
      return titleA.compareTo(titleB); // normal sorting for valid titles
    });
  }

  Future<void> _scanDirectory(
      Directory dir, List<String> audioExtensions, List<Map<String, dynamic>> audios, List<String> videos) async {
    final skipDirs = [
      '/Android',
      '/data',
      '/system',
      '/cache',
      '/WhatsApp',
      '/CallRecordings',
      '/Recordings',
      '/VoiceRecorder',
    ];
    if (skipDirs.any((skip) => dir.path.contains(skip))) {
      return;
    }

    try {
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (audioExtensions.contains(ext) && await _canAccessFile(entity.path)) {
            final metadata = await _extractMetadata(entity.path);
            if (!audios.any((audio) => audio['path'] == entity.path)) {
              audios.add({
                'path': entity.path,
                'title': metadata['title'] ?? p.basenameWithoutExtension(entity.path),
                'artist': metadata['artist'] ?? 'Unknown Artist',
                'album': metadata['album'] ?? 'Unknown Album',
                'albumArt': metadata['albumArt'],
                'folder': p.dirname(entity.path),
                'duration': metadata['duration'] ?? 0, // Include duration if available
              });
            }
          } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(ext)) {
            if (!videos.contains(entity.path)) {
              videos.add(entity.path);
            }
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, audioExtensions, audios, videos);
        }
      }
    } catch (e) {
      _errorMessage = 'Error scanning directory ${dir.path}: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _extractMetadata(String path) async {
    try {
      if (Platform.isAndroid) {
        final metadata = await platform.invokeMethod('getMetadata', {'path': path});
        return {
          'title': metadata['title'] is String && metadata['title'].isNotEmpty
              ? metadata['title']
              : p.basenameWithoutExtension(path),
          'artist': metadata['artist'] is String && metadata['artist'].isNotEmpty
              ? metadata['artist']
              : 'Unknown Artist',
          'album': metadata['album'] is String && metadata['album'].isNotEmpty
              ? metadata['album']
              : 'Unknown Album',
          'albumArt': metadata['albumArt'],
          'duration': metadata['duration'] is int ? metadata['duration'] : 0,
        };
      }
      return {
        'title': p.basenameWithoutExtension(path),
        'artist': 'Unknown Artist',
        'album': 'Unknown Album',
        'albumArt': null,
        'duration': 0,
      };
    } catch (e) {
      print('Error extracting metadata for $path: $e');
      return {
        'title': p.basenameWithoutExtension(path),
        'artist': 'Unknown Artist',
        'album': 'Unknown Album',
        'albumArt': null,
        'duration': 0,
      };
    }
  }

  Future<List<String>> _getExternalStorageDirectories() async {
    final externalDirs = <String>{};
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        externalDirs.add(extDir.path.split('/Android')[0]);
      }
      final possibleSdCardPaths = [
        '/storage/sdcard',
        '/mnt/sdcard',
        '/storage/extSdCard',
      ];
      for (final path in possibleSdCardPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          externalDirs.add(path);
        }
      }
    } catch (e) {
      print('Error detecting external storage: $e');
    }
    return externalDirs.toList();
  }

  Future<void> _generateThumbnailsAsync() async {
    final tempDir = await getTemporaryDirectory();
    for (final videoPath in _videos) {
      if (_thumbnailCache.value[videoPath] == null && await _canAccessFile(videoPath)) {
        try {
          final thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: videoPath,
            thumbnailPath: tempDir.path,
            imageFormat: ImageFormat.PNG,
            maxHeight: 100,
            quality: 75,
          );
          _thumbnailCache.value = {
            ..._thumbnailCache.value,
            videoPath: thumbnailPath,
          };
          _thumbnailCache.notifyListeners();
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

  String? getThumbnailPath(String videoPath) => _thumbnailCache.value[videoPath];

  Future<void> pickMediaManually() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );
      if (result != null) {
        final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];
        final audioExtensions = ['mp3', 'm4a', 'wav', 'aac'];
        final newVideos = <String>{};
        final newAudios = <Map<String, dynamic>>{};

        for (final file in result.files) {
          final path = file.path!;
          final ext = file.extension?.toLowerCase();
          if (ext == null || path.contains('/WhatsApp') || path.contains('/CallRecordings') || path.contains('/Recordings') || path.contains('/VoiceRecorder')) {
            continue;
          }

          if (audioExtensions.contains(ext) && await _canAccessFile(path)) {
            if (!_audios.any((audio) => audio['path'] == path)) {
              final metadata = await _extractMetadata(path);
              newAudios.add({
                'path': path,
                'title': metadata['title'] ?? p.basenameWithoutExtension(path),
                'artist': metadata['artist'] ?? 'Unknown Artist',
                'album': metadata['album'] ?? 'Unknown Album',
                'albumArt': metadata['albumArt'],
                'folder': p.dirname(path),
                'duration': metadata['duration'] ?? 0,
              });
            }
          } else if (videoExtensions.contains(ext)) {
            if (!_videos.contains(path)) {
              newVideos.add(path);
            }
          }
        }

        _audios.addAll(newAudios);
        _sortAudios(); // Use centralized sorting
        _videos.addAll(newVideos);

        final updatedCache = Map<String, String?>.from(_thumbnailCache.value);
        for (var video in newVideos) {
          if (!updatedCache.containsKey(video)) {
            updatedCache[video] = null;
          }
        }
        _thumbnailCache.value = updatedCache;

        _errorMessage = _audios.isEmpty && _videos.isEmpty ? 'No media files selected' : null;

        notifyListeners();
        _generateThumbnailsAsync();
      } else {
        _errorMessage = 'No files selected';
      }
    } catch (e) {
      _errorMessage = 'Error picking media: $e';
    }
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt ?? 0;
    Map<Permission, PermissionStatus> statuses;

    try {
      if (Platform.isAndroid && sdkVersion >= 33) {
        statuses = await [Permission.videos, Permission.audio].request();
      } else if (Platform.isAndroid && sdkVersion >= 30) {
        statuses = await [Permission.storage, Permission.manageExternalStorage].request();
      } else {
        statuses = await [Permission.storage].request();
      }

      final deniedPermissions = statuses.entries
          .where((entry) => !entry.value.isGranted)
          .map((entry) => entry.key)
          .toList();

      if (deniedPermissions.isNotEmpty) {
        _errorMessage = 'Permissions denied: ${deniedPermissions.join(', ')}. Please grant in settings.';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error requesting permissions: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> _canAccessFile(String path) async {
    try {
      final file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      print('Error accessing file $path: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _thumbnailCache.dispose();
    _dbHelper.close();
    super.dispose();
  }
}