//package com.example.s_player
//
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import android.media.MediaMetadataRetriever
//import android.net.Uri
//import java.io.File
//
//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "com.example.s_player/metadata"
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "getMetadata") {
//                val path = call.argument<String>("path")
//                if (path != null) {
//                    try {
//                        val metadata = getAudioMetadata(path)
//                        result.success(metadata)
//                    } catch (e: Exception) {
//                        result.error("METADATA_ERROR", "Failed to extract metadata: ${e.message}", null)
//                    }
//                } else {
//                    result.error("INVALID_PATH", "Path is null", null)
//                }
//            } else {
//                result.notImplemented()
//            }
//        }
//    }
//
//    private fun getAudioMetadata(path: String): Map<String, String?> {
//        val retriever = MediaMetadataRetriever()
//        try {
//            retriever.setDataSource(this, Uri.fromFile(File(path)))
//            return mapOf(
//                "title" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
//                "artist" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST),
//                "album" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM),
//            )
//        } finally {
//            retriever.release()
//        }
//    }
//}


package com.example.s_player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaMetadataRetriever
import android.net.Uri
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.s_player/metadata"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getMetadata") {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        val metadata = getAudioMetadata(path)
                        result.success(metadata)
                    } catch (e: Exception) {
                        result.error("METADATA_ERROR", "Failed to extract metadata: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_PATH", "Path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAudioMetadata(path: String): Map<String, Any?> {
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(this, Uri.fromFile(File(path)))
            val albumArt = retriever.embeddedPicture // Get album art as byte array
            return mapOf(
                "title" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
                "artist" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST),
                "album" to retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM),
                "albumArt" to albumArt // Include album art byte array
            )
        } finally {
            retriever.release()
        }
    }
}