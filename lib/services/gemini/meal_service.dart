import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stuff_app/entities/nutrition/nutrition_entity.dart';
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<NutritionEntity?> analyzeFoodNutrition(
  String imagePath,
  Uint8List imageBytes,
  String apiKey,
  String mealDesc,
) async {
  try {
    // 1. Get file details
    int numBytes = imageBytes.length;
    String? mimeType = lookupMimeType(imagePath);
    if (mimeType == null) {
      debugPrint('Error: Could not determine MIME type for $imagePath');
      return null;
    }
    String displayName = 'food_image';

    // 2. Initial Resumable Upload Request (Metadata)
    String baseUrl = 'https://generativelanguage.googleapis.com/upload/v1beta/files';
    String initialUrl = '$baseUrl?key=$apiKey';

    var initialResponse = await http.post(
      Uri.parse(initialUrl),
      headers: {
        'X-Goog-Upload-Protocol': 'resumable',
        'X-Goog-Upload-Command': 'start',
        'X-Goog-Upload-Header-Content-Length': numBytes.toString(),
        'X-Goog-Upload-Header-Content-Type': mimeType,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'file': {'display_name': displayName},
      }),
    );

    if (initialResponse.statusCode != 200) {
      debugPrint('Initial upload failed: ${initialResponse.statusCode}, ${initialResponse.body}');
      return null;
    }

    String uploadUrl = initialResponse.headers['x-goog-upload-url']!;

    // 3. Upload Actual Bytes
    var uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Length': numBytes.toString(),
        'X-Goog-Upload-Offset': '0',
        'X-Goog-Upload-Command': 'upload, finalize',
      },
      body: imageBytes,
    );

    if (uploadResponse.statusCode != 200) {
      debugPrint('Byte upload failed: ${uploadResponse.statusCode}, ${uploadResponse.body}');
      return null;
    }

    Map<String, dynamic> fileInfo = jsonDecode(uploadResponse.body);
    String fileUri = fileInfo['file']['uri'];

    // 4. Generate Content Request for Nutrition Analysis
    String generateContentUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
    String prompt = '''
Please analyze the nutritional content of the following meal description and provide the estimated breakdown of calories, protein, fat, carbohydrates, and dietary fiber. The output should be a JSON object with a top-level key "${NutritionEnum.data.key}" containing the following structure:

// NutrientEntity
import 'package:cloud_firestore/cloud_firestore.dart';

enum NutritionEnum {
  id("id"),
  data("data"), // Top-level key for the entire nutrition information
  components("components"),
  name("name"),
  quantity("quantity"),
  calories("calories"),
  protein("protein"),
  fat("fat"),
  carbohydrates("carbohydrates"),
  fiber("dietary_fiber"),
  valueKey("value"), // Renamed instance member
  unit("unit"),
  type("type"),
  totals("totals"),
  createdAt("createdAt");

  final String key; // Renamed to 'key' to avoid conflict
  const NutritionEnum(this.key);

  // Optional: Add a getter for clarity if you use 'value' often elsewhere
  String get value => key;
}

class NutritionEntity {
  final String id;
  final Map<String, dynamic> data;
  final Timestamp createdAt;

  NutritionEntity({required this.id, required this.data, required this.createdAt});

  factory NutritionEntity.fromMap(Map<String, dynamic> map) {
    return NutritionEntity(
      id: map[NutritionEnum.id.key], // Use .key to access the enum's string value
      data: map[NutritionEnum.data.key] as Map<String, dynamic>, // Use .key
      createdAt: map[NutritionEnum.createdAt.key] as Timestamp, // Use .key
    );
  }

  Map<String, dynamic> toMap() {
    return {
      NutritionEnum.id.key: id, // Use .key
      NutritionEnum.data.key: data, // Use .key
      NutritionEnum.createdAt.key: createdAt, // Use .key
    };
  }

  // Helper method to access specific nutrition details
  List<Map<String, dynamic>>? get components => data[NutritionEnum.components.key] as List<Map<String, dynamic>>?; // Use .key
  Map<String, dynamic>? get totals => data[NutritionEnum.totals.key] as Map<String, dynamic>?; // Use .key
}

{
  "${NutritionEnum.components.key}": [
    {
      "${NutritionEnum.name.key}": "...",
      "${NutritionEnum.quantity.key}": "...",
      "${NutritionEnum.calories.key}": {
        "${NutritionEnum.valueKey.key}": 0.0,
        "${NutritionEnum.unit.key}": "kcal",
        "${NutritionEnum.type.key}": "double"
      },
      "${NutritionEnum.protein.key}": {
        "${NutritionEnum.valueKey.key}": 0.0,
        "${NutritionEnum.unit.key}": "grams",
        "${NutritionEnum.type.key}": "double"
      },
      "${NutritionEnum.fat.key}": {
        "${NutritionEnum.valueKey.key}": 0.0,
        "${NutritionEnum.unit.key}": "grams",
        "${NutritionEnum.type.key}": "double"
      },
      "${NutritionEnum.carbohydrates.key}": {
        "${NutritionEnum.valueKey.key}": 0.0,
        "${NutritionEnum.unit.key}": "grams",
        "${NutritionEnum.type.key}": "double"
      },
      "${NutritionEnum.fiber.key}": {
        "${NutritionEnum.valueKey.key}": 0.0,
        "${NutritionEnum.unit.key}": "grams",
        "${NutritionEnum.type.key}": "double"
      }
    }
    // ... more components
  ],
  "${NutritionEnum.totals.key}": {
    "${NutritionEnum.calories.key}": {
      "${NutritionEnum.valueKey.key}": 0.0,
      "${NutritionEnum.unit.key}": "kcal",
      "${NutritionEnum.type.key}": "double"
    },
    "${NutritionEnum.protein.key}": {
      "${NutritionEnum.valueKey.key}": 0.0,
      "${NutritionEnum.unit.key}": "grams",
      "${NutritionEnum.type.key}": "double"
    },
    "${NutritionEnum.fat.key}": {
      "${NutritionEnum.valueKey.key}": 0.0,
      "${NutritionEnum.unit.key}": "grams",
      "${NutritionEnum.type.key}": "double"
    },
    "${NutritionEnum.carbohydrates.key}": {
      "${NutritionEnum.valueKey.key}": 0.0,
      "${NutritionEnum.unit.key}": "grams",
      "${NutritionEnum.type.key}": "double"
    },
    "${NutritionEnum.fiber.key}": {
      "${NutritionEnum.valueKey.key}": 0.0,
      "${NutritionEnum.unit.key}": "grams",
      "${NutritionEnum.type.key}": "double"
    }
  }
}

Here is the description of the meal: $mealDesc
''';

    var generateContentResponse = await http.post(
      Uri.parse(generateContentUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'file_data': {'mime_type': mimeType, 'file_uri': fileUri},
              },
            ],
          },
        ],
        'generation_config': {
          'response_mime_type': 'application/json', // Request JSON response
        },
      }),
    );

    if (generateContentResponse.statusCode != 200) {
      debugPrint(
        'Generate content failed: ${generateContentResponse.statusCode}, ${generateContentResponse.body}',
      );
      return null;
    }

    Map<String, dynamic> responseJson = jsonDecode(generateContentResponse.body);
    if (responseJson['candidates'] != null &&
        responseJson['candidates'].isNotEmpty &&
        responseJson['candidates'][0]['content'] != null &&
        responseJson['candidates'][0]['content']['parts'] != null &&
        responseJson['candidates'][0]['content']['parts'].isNotEmpty &&
        responseJson['candidates'][0]['content']['parts'][0]['text'] != null) {
      try {
        // Attempt to parse the JSON response
        Map<String, dynamic> nutritionJson = jsonDecode(
          responseJson['candidates'][0]['content']['parts'][0]['text'],
        );
        Timestamp timestamp = Timestamp.now();
        DateTime dateTime = timestamp.toDate();

        return NutritionEntity(
          id: '', // ID will be added in Firestore
          data: nutritionJson,
          createdAt: Timestamp.now(), // Timestamp will be set to now
          meal: 'Breakfast',
          year: dateTime.year,
          month: dateTime.month,
          day: dateTime.day,
        );
      } catch (e) {
        debugPrint(
          'Error parsing nutrition JSON: $e\nRaw response: ${responseJson['candidates'][0]['content']['parts'][0]['text']}',
        );
        return null;
      }
    } else {
      debugPrint('Error: Could not extract nutrition information from the response.');
      return null;
    }
  } catch (e) {
    debugPrint('Error during food nutrition analysis: $e');
    return null;
  }
}
