package com.cardcapture.card_capture

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import android.net.Uri
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cardcapture.cardCapture/ocr"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "recognizeText") {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath == null) {
                    result.error("INVALID_ARGUMENTS", "imagePath is required", null)
                    return@setMethodCallHandler
                }
                recognizeTextNatively(imagePath, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun recognizeTextNatively(imagePath: String, result: MethodChannel.Result) {
        try {
            val file = File(imagePath)
            val image = InputImage.fromFilePath(this, Uri.fromFile(file))
            val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            recognizer.process(image)
                .addOnSuccessListener { visionText ->
                    val lines = mutableListOf<Map<String, Any>>()
                    for (block in visionText.textBlocks) {
                        for (line in block.lines) {
                            val rect = line.boundingBox
                            lines.add(mapOf(
                                "text" to line.text,
                                "x" to (rect?.left?.toDouble() ?: 0.0),
                                "y" to (rect?.top?.toDouble() ?: 0.0),
                                "width" to (rect?.width()?.toDouble() ?: 0.0),
                                "height" to (rect?.height()?.toDouble() ?: 0.0)
                            ))
                        }
                    }
                    result.success(lines)
                }
                .addOnFailureListener { e ->
                    result.error("VISION_ERROR", e.localizedMessage, null)
                }
        } catch (e: Exception) {
            result.error("LOAD_ERROR", e.localizedMessage, null)
        }
    }
}
