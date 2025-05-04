// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'dart:ui';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:permission_handler/permission_handler.dart';

// class QRGeneratorPage extends StatefulWidget {
//   const QRGeneratorPage({super.key});

//   @override
//   State<QRGeneratorPage> createState() => _QRGeneratorPageState();
// }

// class _QRGeneratorPageState extends State<QRGeneratorPage> {
//   final TextEditingController _controller = TextEditingController();
//   String? _qrData;
//   final GlobalKey _qrKey = GlobalKey();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _generateQR() {
//     if (_controller.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please enter some data')));
//       return;
//     }

//     setState(() {
//       _qrData = _controller.text.trim();
//     });
//   }

//   Future<bool> storagePermission() async {
//     final DeviceInfoPlugin info = DeviceInfoPlugin();
//     final AndroidDeviceInfo androidInfo = await info.androidInfo;
//     debugPrint('releaseVersion : ${androidInfo.version.release}');
//     final int androidVersion = int.parse(androidInfo.version.release);
//     bool havePermission = false;

//     // Here you can use android api level
//     // like android api level 33 = android 13
//     // This way you can also find out how to request storage permission

//     if (androidVersion >= 13) {
//       final request =
//           await [
//             Permission.videos,
//             Permission.photos,
//             //..... as needed
//           ].request(); //import 'package:permission_handler/permission_handler.dart';

//       havePermission = request.values.every((status) => status == PermissionStatus.granted);
//     } else {
//       final status = await Permission.storage.request();
//       havePermission = status.isGranted;
//     }

//     if (!havePermission) {
//       // if no permission then open app-setting
//       await openAppSettings();
//     }

//     return havePermission;
//   }

//   Future<void> _saveQRToGallery() async {
//     if (_qrData == null) return;

//     try {
//       // Check permissions
//       await storagePermission();

//       // Capture QR code image
//       final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       final image = await boundary.toImage(pixelRatio: 3.0);
//       final byteData = await image.toByteData(format: ImageByteFormat.png);
//       final pngBytes = byteData!.buffer.asUint8List();

//       // Save using photo_manager (updated API)
//       await PhotoManager.editor.saveImage(
//         pngBytes,
//         title: 'QR_${DateTime.now().millisecondsSinceEpoch}.png',
//         filename: 'QR_${DateTime.now().millisecondsSinceEpoch}.png',
//       );

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('QR code saved to gallery')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving QR: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('QR Code Generator'), centerTitle: true),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: 'Enter data',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _generateQR,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     ),
//                     child: const Text('Generate QR Code'),
//                   ),
//                 ),
//                 if (_qrData != null)
//                   IconButton(
//                     icon: const Icon(Icons.download),
//                     onPressed: _saveQRToGallery,
//                     tooltip: 'Save QR Code',
//                   ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             if (_qrData != null)
//               RepaintBoundary(
//                 key: _qrKey,
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.3),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: QrImageView(
//                     data: _qrData!,
//                     version: QrVersions.auto,
//                     size: 250,
//                     backgroundColor: Colors.white,
//                     eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.square),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stuff_app/services/image/image_service.dart';
import 'package:stuff_app/widgets/ui_color.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String? _qrData;
  final GlobalKey _qrKey = GlobalKey();

  // Customization parameters
  double _errorCorrection = 0.0;
  bool _squareEyes = true;
  double _qrSize = 250.0;
  double _embImgSize = 80;
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;

  ImageData imageData = ImageData();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateQR() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some data')));
      return;
    }

    setState(() {
      _qrData = _controller.text.trim();
    });
  }

  Future<bool> storagePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);

    if (androidVersion >= 13) {
      final request = await [Permission.photos, Permission.videos].request();
      return request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<void> _saveQRToGallery() async {
    if (_qrData == null) return;

    try {
      await storagePermission();

      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await PhotoManager.editor.saveImage(
        pngBytes,
        title: 'QR_${DateTime.now().millisecondsSinceEpoch}.png',
        filename: 'QR_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR code saved to gallery')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving QR: $e')));
      }
    }
  }

  void _showColorPicker(bool isForeground) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '${isForeground ? 'Foreground' : 'Background'} Color',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Predefined color palette
                  BlockPicker(
                    availableColors: [
                      Colors.black,
                      Colors.white,
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.deepPurple,
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.green,
                      Colors.lightGreen,
                      Colors.yellow,
                      Colors.orange,
                      Colors.brown,
                      Colors.grey,
                    ],
                    pickerColor: isForeground ? _foregroundColor : _backgroundColor,
                    onColorChanged: (color) {
                      setState(() {
                        if (isForeground) {
                          _foregroundColor = color;
                        } else {
                          _backgroundColor = color;
                        }
                      });
                    },
                  ),

                  // Custom color button
                  TextButton.icon(
                    onPressed: () => _showMaterialPicker(isForeground),
                    icon: const Icon(Icons.palette),
                    label: Text('Advanced Color Picker'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Full material color picker
  void _showMaterialPicker(bool isForeground) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Material Color Picker',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: isForeground ? _foregroundColor : _backgroundColor,
                onColorChanged: (color) {
                  setState(() {
                    if (isForeground) {
                      _foregroundColor = color;
                    } else {
                      _backgroundColor = color;
                    }
                  });
                  Navigator.of(context).pop(); // Close advanced picker
                },
                enableLabel: true,
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Generator'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter data',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ImageService(parentContext: context, imageData: imageData),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error Correction'),
                Slider(
                  value: _errorCorrection,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: ['L', 'M', 'Q', 'H'][_errorCorrection.toInt()],
                  onChanged: (value) => setState(() => _errorCorrection = value),
                  thumbColor: UIColor().darkGray,
                  activeColor: UIColor().springGreen,
                  inactiveColor: UIColor().gray,
                ),
                const SizedBox(height: 10),
                Text('QR Size'),
                Slider(
                  value: _qrSize,
                  min: 100,
                  max: 500,
                  divisions: 40,
                  label: '${_qrSize.toInt()} px',
                  onChanged: (value) => setState(() => _qrSize = value),
                  thumbColor: UIColor().darkGray,
                  activeColor: UIColor().springGreen,
                  inactiveColor: UIColor().gray,
                ),
                const SizedBox(height: 10),
                Text('Image Size'),
                Slider(
                  value: _embImgSize,
                  min: 5,
                  max: 150,
                  onChanged: (value) => setState(() => _embImgSize = value),
                  thumbColor: UIColor().darkGray,
                  activeColor: UIColor().springGreen,
                  inactiveColor: UIColor().gray,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Square Eyes',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
                  ),
                  value: _squareEyes,
                  onChanged: (value) => setState(() => _squareEyes = value!),
                  activeColor: UIColor().springGreen,
                  checkColor: UIColor().whiteSmoke,
                ),
                const SizedBox(height: 16),
                Text('Color'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Foreground'),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showColorPicker(true),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _foregroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Background'),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showColorPicker(false),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateQR,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('Generate QR Code'),
                  ),
                ),
                if (_qrData != null)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _saveQRToGallery,
                    tooltip: 'Save QR Code',
                  ),
              ],
            ),
            const SizedBox(height: 30),
            if (_qrData != null)
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: _qrSize,
                        backgroundColor: _backgroundColor,
                        dataModuleStyle: QrDataModuleStyle(
                          color: _foregroundColor,
                          dataModuleShape:
                              _squareEyes ? QrDataModuleShape.square : QrDataModuleShape.circle,
                        ),
                        eyeStyle: QrEyeStyle(
                          color: _foregroundColor,
                          eyeShape: _squareEyes ? QrEyeShape.square : QrEyeShape.circle,
                        ),
                        errorCorrectionLevel: _errorCorrection.toInt(),
                        embeddedImage: MemoryImage(imageData.imageBytes),
                        embeddedImageStyle: QrEmbeddedImageStyle(size: Size.square(_embImgSize)),
                        gapless: true,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
