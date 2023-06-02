import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/generated_bindings.dart';
import 'package:pytorch_lite/pigeon.dart';
import 'package:image/image.dart' as imageLib;

import 'native_locator.dart';

export 'enums/dtype.dart';

const torchVisionNormMeanRGB = [0.485, 0.456, 0.406];
const torchVisionNormSTDRGB = [0.229, 0.224, 0.225];

/// The bindings to the native functions in [dylib].
final NativeLibrary _bindings = NativeLibrary(dylib);

class PytorchLite {
  /*
  ///Sets pytorch model path and returns Model
  static Future<CustomModel> loadCustomModel(String path) async {
    String absPathModelPath = await _getAbsolutePath(path);
    int index = await ModelApi().loadModel(absPathModelPath, null, 0, 0);
    return CustomModel(index);
  }
   */

  ///Sets pytorch model path and returns Model
  static Future<ClassificationModel> loadClassificationModel(
      String path, int imageWidth, int imageHeight,
      {String? labelPath}) async {
    String absPathModelPath = await _getAbsolutePath(path);

    int index = _bindings.load_ml_model(absPathModelPath.toNativeUtf8());
    List<String> labels = [];
    if (labelPath != null) {
      if (labelPath.endsWith(".txt")) {
        labels = await _getLabelsTxt(labelPath);
      } else {
        labels = await _getLabelsCsv(labelPath);
      }
    }

    return ClassificationModel(index, labels, imageWidth, imageHeight);
  }

  ///Sets pytorch object detection model (path and lables) and returns Model
  static Future<ModelObjectDetection> loadObjectDetectionModel(
      String path, int numberOfClasses, int imageWidth, int imageHeight,
      {String? labelPath,
      ObjectDetectionModelType objectDetectionModelType =
          ObjectDetectionModelType.yolov5}) async {
    String absPathModelPath = await _getAbsolutePath(path);
    int index = _bindings.load_ml_model(absPathModelPath.toNativeUtf8());

    // int index = await ModelApi().loadModel(absPathModelPath, numberOfClasses,
    //     imageWidth, imageHeight, objectDetectionModelType);
    List<String> labels = [];
    if (labelPath != null) {
      if (labelPath.endsWith(".txt")) {
        labels = await _getLabelsTxt(labelPath);
      } else {
        labels = await _getLabelsCsv(labelPath);
      }
    }
    return ModelObjectDetection(index, imageWidth, imageHeight, labels,
        modelType: objectDetectionModelType);
  }

  static Future<String> _getAbsolutePath(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String dirPath = join(dir.path, path);
    ByteData data = await rootBundle.load(path);
    //copy asset to documents directory
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //create non existant directories
    List split = path.split("/");
    String nextDir = "";
    for (int i = 0; i < split.length; i++) {
      if (i != split.length - 1) {
        nextDir += split[i];
        await Directory(join(dir.path, nextDir)).create();
        nextDir += "/";
      }
    }
    await File(dirPath).writeAsBytes(bytes);

    return dirPath;
  }
}

///get labels in csv format
///labels are separated by commas
Future<List<String>> _getLabelsCsv(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split(",");
}

///get labels in txt format
///each line is a label
Future<List<String>> _getLabelsTxt(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split("\n");
}

/*
class CustomModel {
  final int _index;

  CustomModel(this._index);

  ///predicts abstract number input
  Future<List?> getPrediction(
      List<double> input, List<int> shape, DType dtype) async {
    final List? prediction = await ModelApi().getPredictionCustom(
        _index, input, shape, dtype.toString().split(".").last);
    return prediction;
  }
}
*/
Pointer<Uint8> convertUint8ListToPointer(Uint8List data) {
  int length = data.length;
  Pointer<Uint8> dataPtr = calloc<Uint8>(length);

  for (int i = 0; i < length; i++) {
    dataPtr.elementAt(i).value = data[i];
  }

  return dataPtr;
}

Pointer<UnsignedChar> convertUint8ListToPointerChar(Uint8List data) {
  int length = data.length;
  Pointer<UnsignedChar> dataPtr = calloc<UnsignedChar>(length);

  for (int i = 0; i < length; i++) {
    dataPtr.elementAt(i).value = data[i];
  }

  return dataPtr;
}

void normalizeImage(List<List<List<num>>> imageMatrix,
    {List<double> mean = torchVisionNormMeanRGB,
    List<double> std = torchVisionNormSTDRGB}) {
  print("mean: $mean");
  print("std: $std");
  print("before $imageMatrix");
  for (var row in imageMatrix) {
    for (var pixel in row) {
      for (var i = 0; i < 3; i++) {
        pixel[i] = ((pixel[i] / 255) - mean[i]) / std[i];
      }
    }
  }
  print("after $imageMatrix");
}

Uint8List _imageToUint8List(imageLib.Image image,
    {List<double> mean = torchVisionNormMeanRGB,
    List<double> std = torchVisionNormSTDRGB,
    bool contiguous = true}) {
  var bytes = Float32List(1 * image.height * image.width * 3);
  var buffer = Float32List.view(bytes.buffer);

  if (contiguous) {
    int offset_g = image.height * image.width;
    int offset_b = 2 * image.height * image.width;
    int i = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        imageLib.Pixel pixel = image.getPixel(x, y);
        buffer[i] = ((pixel.r / 255) - mean[0]) / std[0];
        buffer[offset_g + i] = ((pixel.g / 255) - mean[1]) / std[1];
        buffer[offset_b + i] = ((pixel.b / 255) - mean[2]) / std[2];
        i++;
      }
    }
  } else {
    int i = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        imageLib.Pixel pixel = image.getPixel(x, y);
        buffer[i++] = ((pixel.r / 255) - mean[0]) / std[0];
        buffer[i++] = ((pixel.g / 255) - mean[1]) / std[1];
        buffer[i++] = ((pixel.b / 255) - mean[2]) / std[2];
      }
    }
  }

  return bytes.buffer.asUint8List();
}

Pointer<Float> convertListToPointer(List<double> floatList) {
  // Create a native array to hold the double values
  final nativeArray = calloc<Double>(floatList.length);

  // Copy the values from the list to the native array
  for (var i = 0; i < floatList.length; i++) {
    nativeArray[i] = floatList[i];
  }

  // Obtain the pointer to the native array
  final nativePointer = nativeArray.cast<Float>();

  return nativePointer;
}

class ClassificationModel {
  final int _index;
  final List<String> labels;
  final int imageWidth;
  final int imageHeight;
  ClassificationModel(
      this._index, this.labels, this.imageWidth, this.imageHeight);

  ///predicts image and returns the supposed label belonging to it
  Future<String> getImagePrediction(Uint8List imageAsBytes,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction =
        await getImagePredictionList(imageAsBytes, mean: mean, std: std);

    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction.length; i++) {
      if (prediction[i]! > maxScore) {
        maxScore = prediction[i]!;
        maxScoreIndex = i;
      }
    }
    // free(dataPointer);
    return labels[maxScoreIndex];
  }

  ///predicts image but returns the raw net output
  Future<List<double?>> getImagePredictionList(Uint8List imageAsBytes,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    imageLib.Image? img = imageLib.decodeImage(imageAsBytes);
    imageLib.Image scaledImageBytes =
        imageLib.copyResize(img!, width: imageWidth, height: imageHeight);
    // // Creating matrix representation, [height, width, 3]
    // List<List<List<num>>> imageMatrix = List.generate(
    //   scaledImageBytes.height,
    //   (y) => List.generate(
    //     scaledImageBytes.width,
    //     (x) {
    //       final pixel = scaledImageBytes.getPixel(x, y);
    //       return [pixel.r, pixel.g, pixel.b];
    //     },
    //   ),
    // );
    // normalizeImage(imageMatrix, mean: mean, std: std);
    // // Flatten the matrix into a single list
    // List<double> flattenedList = imageMatrix
    //     .expand((row) => row)
    //     .expand((pixel) => pixel.map((e) => e.toDouble()))
    //     .toList();

    Pointer<UnsignedChar> dataPointer = convertUint8ListToPointerChar(
        _imageToUint8List(scaledImageBytes, mean: mean, std: std));
    Pointer<Float> meanPointer = convertListToPointer(mean);
    Pointer<Float> stdPointer = convertListToPointer(std);

    OutputData outputData = _bindings.image_model_inference(
        _index,
        dataPointer,
        scaledImageBytes.length,
        imageWidth,
        imageHeight,
        meanPointer,
        stdPointer);

    final List<double?> prediction =
        outputData.values.asTypedList(outputData.length);

    // final List<double?>? prediction = await ModelApi().getImagePredictionList(
    //     _index, imageAsBytes, null, null, null, mean, std);
    return prediction;
  }

  ///predicts image but returns the output as probabilities
  ///[image] takes the File of the image
  Future<List<double?>?> getImagePredictionListProbabilities(
      Uint8List imageAsBytes,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    List<double?> prediction =
        await getImagePredictionList(imageAsBytes, mean: mean, std: std);
    List<double?> predictionProbabilities = [];

    //Getting sum of exp
    double? sumExp;
    for (var element in prediction) {
      if (sumExp == null) {
        sumExp = exp(element!);
      } else {
        sumExp = sumExp + exp(element!);
      }
    }
    for (var element in prediction) {
      predictionProbabilities.add(exp(element!) / sumExp!);
    }

    return predictionProbabilities;
  }

  ///predicts image and returns the supposed label belonging to it
  Future<String> getImagePredictionFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?>? prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);

    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction!.length; i++) {
      if (prediction[i]! > maxScore) {
        maxScore = prediction[i]!;
        maxScoreIndex = i;
      }
    }

    return labels[maxScoreIndex];
  }

  ///predicts image but returns the raw net output
  Future<List<double?>?> getImagePredictionListFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    final List<double?>? prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);
    return prediction;
  }

  ///predicts image but returns the output as probabilities
  ///[image] takes the File of the image
  Future<List<double?>?> getImagePredictionListProbabilitiesFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {List<double> mean = torchVisionNormMeanRGB,
      List<double> std = torchVisionNormSTDRGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    List<double?>? prediction = await ModelApi().getImagePredictionList(
        _index, null, imageAsBytesList, imageWidth, imageHeight, mean, std);
    List<double?>? predictionProbabilities = [];

    //Getting sum of exp
    double? sumExp;
    for (var element in prediction!) {
      if (sumExp == null) {
        sumExp = exp(element!);
      } else {
        sumExp = sumExp + exp(element!);
      }
    }
    for (var element in prediction) {
      predictionProbabilities.add(exp(element!) / sumExp!);
    }

    return predictionProbabilities;
  }
}

class ModelObjectDetection {
  final int _index;
  final int imageWidth;
  final int imageHeight;
  final List<String> labels;
  final ObjectDetectionModelType modelType;
  ModelObjectDetection(
      this._index, this.imageWidth, this.imageHeight, this.labels,
      {this.modelType = ObjectDetectionModelType.yolov5});

  ///predicts image and returns the supposed label belonging to it
  Future<List<ResultObjectDetection?>> getImagePrediction(
      Uint8List imageAsBytes,
      {double minimumScore = 0.5,
      double iOUThreshold = 0.5,
      int boxesLimit = 10}) async {
    List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, imageAsBytes, null, null,
            null, minimumScore, iOUThreshold, boxesLimit);

    for (var element in prediction) {
      element?.className = labels[element.classIndex];
    }

    return prediction;
  }

  ///predicts image and returns the supposed label belonging to it
  Future<List<ResultObjectDetection?>> getImagePredictionFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {double minimumScore = 0.5,
      double iOUThreshold = 0.5,
      int boxesLimit = 10}) async {
    List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, null, imageAsBytesList,
            imageWidth, imageHeight, minimumScore, iOUThreshold, boxesLimit);

    for (var element in prediction) {
      element?.className = labels[element.classIndex];
    }

    return prediction;
  }

  ///predicts image but returns the raw net output
  Future<List<ResultObjectDetection?>> getImagePredictionList(
      Uint8List imageAsBytes,
      {double minimumScore = 0.5,
      double iOUThreshold = 0.5,
      int boxesLimit = 10}) async {
    final List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, imageAsBytes, null, null,
            null, minimumScore, iOUThreshold, boxesLimit);
    return prediction;
  }

  ///predicts image but returns the raw net output
  Future<List<ResultObjectDetection?>> getImagePredictionListFromBytesList(
      List<Uint8List> imageAsBytesList, int imageWidth, int imageHeight,
      {double minimumScore = 0.5,
      double iOUThreshold = 0.5,
      int boxesLimit = 10}) async {
    final List<ResultObjectDetection?> prediction = await ModelApi()
        .getImagePredictionListObjectDetection(_index, null, imageAsBytesList,
            imageWidth, imageHeight, minimumScore, iOUThreshold, boxesLimit);
    return prediction;
  }

  /*

   */
  Widget renderBoxesOnImage(
      File image, List<ResultObjectDetection?> recognitions,
      {Color? boxesColor, bool showPercentage = true}) {
    //if (_recognitions == null) return Cont;
    //if (_imageHeight == null || _imageWidth == null) return [];

    //double factorX = screen.width;
    //double factorY = _imageHeight / _imageWidth * screen.width;
    //boxesColor ??= Color.fromRGBO(37, 213, 253, 1.0);

    // print(recognitions.length);
    return LayoutBuilder(builder: (context, constraints) {
      debugPrint(
          'Max height: ${constraints.maxHeight}, max width: ${constraints.maxWidth}');
      double factorX = constraints.maxWidth;
      double factorY = constraints.maxHeight;
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: factorX,
            height: factorY,
            child: Image.file(
              image,
              fit: BoxFit.fill,
            ),
          ),
          ...recognitions.map((re) {
            if (re == null) {
              return Container();
            }
            Color usedColor;
            if (boxesColor == null) {
              //change colors for each label
              usedColor = Colors.primaries[
                  ((re.className ?? re.classIndex.toString()).length +
                          (re.className ?? re.classIndex.toString())
                              .codeUnitAt(0) +
                          re.classIndex) %
                      Colors.primaries.length];
            } else {
              usedColor = boxesColor;
            }

            // print({
            //   "left": re.rect.left.toDouble() * factorX,
            //   "top": re.rect.top.toDouble() * factorY,
            //   "width": re.rect.width.toDouble() * factorX,
            //   "height": re.rect.height.toDouble() * factorY,
            // });
            return Positioned(
              left: re.rect.left * factorX,
              top: re.rect.top * factorY - 20,
              //width: re.rect.width.toDouble(),
              //height: re.rect.height.toDouble(),

              //left: re?.rect.left.toDouble(),
              //top: re?.rect.top.toDouble(),
              //right: re.rect.right.toDouble(),
              //bottom: re.rect.bottom.toDouble(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    alignment: Alignment.centerRight,
                    color: usedColor,
                    child: Text(
                      "${re.className ?? re.classIndex.toString()}_${showPercentage ? "${(re.score * 100).toStringAsFixed(2)}%" : ""}",
                    ),
                  ),
                  Container(
                    width: re.rect.width.toDouble() * factorX,
                    height: re.rect.height.toDouble() * factorY,
                    decoration: BoxDecoration(
                        border: Border.all(color: usedColor, width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2))),
                    child: Container(),
                  ),
                ],
              ),
              /*
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(
                    color: boxesColor!,
                    width: 2,
                  ),
                ),
                child: Text(
                  "${re.className ?? re.classIndex} ${(re.score * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    background: Paint()..color = boxesColor!,
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),*/
            );
          }).toList()
        ],
      );
    });
  }

/*
  ///predicts image and returns the supposed label belonging to it
  Future<String> getImagePrediction(
      File image, int width, int height, String labelPath,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    List<String> labels = [];
    if (labelPath.endsWith(".txt")) {
      labels = await _getLabelsTxt(labelPath);
    } else {
      labels = await _getLabelsCsv(labelPath);
    }

    List byteArray = image.readAsBytesSync();
    final List? prediction =
        await _channel.invokeListMethod("predictImage_ObjectDetection", {
      "index": _index,
      "image": byteArray,
      "width": width,
      "height": height,
      "mean": mean,
      "std": std
    });
    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction!.length; i++) {
      if (prediction[i] > maxScore) {
        maxScore = prediction[i];
        maxScoreIndex = i;
      }
    }
    return labels[maxScoreIndex];
  }

  ///predicts image but returns the raw net output
  Future<List?> getImagePredictionList(File image, int width, int height,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "Mean should have size of 3");
    assert(std.length == 3, "STD should have size of 3");
    final List? prediction =
        await _channel.invokeListMethod("predictImage_ObjectDetection", {
      "index": _index,
      "image": image.readAsBytesSync(),
      "width": width,
      "height": height,
      "mean": mean,
      "std": std
    });
    return prediction;
  }

 */
}
