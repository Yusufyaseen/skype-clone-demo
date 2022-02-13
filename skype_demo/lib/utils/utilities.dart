import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

class Utils {
  static String getUsername(String? email) {
    return email!.split('@')[0];
  }

  static String getInitials(String? name) {
    List<String> splitterName = name!.split(" ");
    String firstLetter = splitterName[0][0];
    String secondLetter = splitterName[1][0];
    return firstLetter + secondLetter;
  }

  static Future<File> pickImage({required ImageSource source}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if(selectedImage != null){
      return await compressImage(selectedImage);
    }
    return File('file.txt');
  }

  static Future<File> compressImage(XFile imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);
    File file = File(imageToCompress.path);

    Im.Image? image = Im.decodeImage(file.readAsBytesSync());
    Im.copyResize(image!, width: 500, height: 500);

    return File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }
}
