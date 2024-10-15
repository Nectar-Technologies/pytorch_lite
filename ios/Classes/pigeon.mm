// Autogenerated from Pigeon (v22.5.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "pigeon.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSArray<id> *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}

static id GetNullableObjectAtIndex(NSArray<id> *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

@interface PyTorchRect ()
+ (PyTorchRect *)fromList:(NSArray<id> *)list;
+ (nullable PyTorchRect *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@interface ResultObjectDetection ()
+ (ResultObjectDetection *)fromList:(NSArray<id> *)list;
+ (nullable ResultObjectDetection *)nullableFromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

@implementation PyTorchRect
+ (instancetype)makeWithLeft:(double )left
    top:(double )top
    right:(double )right
    bottom:(double )bottom
    width:(double )width
    height:(double )height {
  PyTorchRect* pigeonResult = [[PyTorchRect alloc] init];
  pigeonResult.left = left;
  pigeonResult.top = top;
  pigeonResult.right = right;
  pigeonResult.bottom = bottom;
  pigeonResult.width = width;
  pigeonResult.height = height;
  return pigeonResult;
}
+ (PyTorchRect *)fromList:(NSArray<id> *)list {
  PyTorchRect *pigeonResult = [[PyTorchRect alloc] init];
  pigeonResult.left = [GetNullableObjectAtIndex(list, 0) doubleValue];
  pigeonResult.top = [GetNullableObjectAtIndex(list, 1) doubleValue];
  pigeonResult.right = [GetNullableObjectAtIndex(list, 2) doubleValue];
  pigeonResult.bottom = [GetNullableObjectAtIndex(list, 3) doubleValue];
  pigeonResult.width = [GetNullableObjectAtIndex(list, 4) doubleValue];
  pigeonResult.height = [GetNullableObjectAtIndex(list, 5) doubleValue];
  return pigeonResult;
}
+ (nullable PyTorchRect *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [PyTorchRect fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    @(self.left),
    @(self.top),
    @(self.right),
    @(self.bottom),
    @(self.width),
    @(self.height),
  ];
}
@end

@implementation ResultObjectDetection
+ (instancetype)makeWithClassIndex:(NSInteger )classIndex
    className:(nullable NSString *)className
    score:(double )score
    rect:(PyTorchRect *)rect {
  ResultObjectDetection* pigeonResult = [[ResultObjectDetection alloc] init];
  pigeonResult.classIndex = classIndex;
  pigeonResult.className = className;
  pigeonResult.score = score;
  pigeonResult.rect = rect;
  return pigeonResult;
}
+ (ResultObjectDetection *)fromList:(NSArray<id> *)list {
  ResultObjectDetection *pigeonResult = [[ResultObjectDetection alloc] init];
  pigeonResult.classIndex = [GetNullableObjectAtIndex(list, 0) integerValue];
  pigeonResult.className = GetNullableObjectAtIndex(list, 1);
  pigeonResult.score = [GetNullableObjectAtIndex(list, 2) doubleValue];
  pigeonResult.rect = GetNullableObjectAtIndex(list, 3);
  return pigeonResult;
}
+ (nullable ResultObjectDetection *)nullableFromList:(NSArray<id> *)list {
  return (list) ? [ResultObjectDetection fromList:list] : nil;
}
- (NSArray<id> *)toList {
  return @[
    @(self.classIndex),
    self.className ?: [NSNull null],
    @(self.score),
    self.rect ?: [NSNull null],
  ];
}
@end

@interface nullPigeonPigeonCodecReader : FlutterStandardReader
@end
@implementation nullPigeonPigeonCodecReader
- (nullable id)readValueOfType:(UInt8)type {
  switch (type) {
    case 129: 
      return [PyTorchRect fromList:[self readValue]];
    case 130: 
      return [ResultObjectDetection fromList:[self readValue]];
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface nullPigeonPigeonCodecWriter : FlutterStandardWriter
@end
@implementation nullPigeonPigeonCodecWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[PyTorchRect class]]) {
    [self writeByte:129];
    [self writeValue:[value toList]];
  } else if ([value isKindOfClass:[ResultObjectDetection class]]) {
    [self writeByte:130];
    [self writeValue:[value toList]];
  } else {
    [super writeValue:value];
  }
}
@end

@interface nullPigeonPigeonCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation nullPigeonPigeonCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[nullPigeonPigeonCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[nullPigeonPigeonCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *nullGetPigeonCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    nullPigeonPigeonCodecReaderWriter *readerWriter = [[nullPigeonPigeonCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}
void SetUpModelApi(id<FlutterBinaryMessenger> binaryMessenger, NSObject<ModelApi> *api) {
  SetUpModelApiWithSuffix(binaryMessenger, api, @"");
}

void SetUpModelApiWithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<ModelApi> *api, NSString *messageChannelSuffix) {
  messageChannelSuffix = messageChannelSuffix.length > 0 ? [NSString stringWithFormat: @".%@", messageChannelSuffix] : @"";
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.loadModel", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(loadModelModelPath:numberOfClasses:imageWidth:imageHeight:objectDetectionModelType:completion:)], @"ModelApi api (%@) doesn't respond to @selector(loadModelModelPath:numberOfClasses:imageWidth:imageHeight:objectDetectionModelType:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSString *arg_modelPath = GetNullableObjectAtIndex(args, 0);
        NSNumber *arg_numberOfClasses = GetNullableObjectAtIndex(args, 1);
        NSNumber *arg_imageWidth = GetNullableObjectAtIndex(args, 2);
        NSNumber *arg_imageHeight = GetNullableObjectAtIndex(args, 3);
        NSNumber *arg_objectDetectionModelType = GetNullableObjectAtIndex(args, 4);
        [api loadModelModelPath:arg_modelPath numberOfClasses:arg_numberOfClasses imageWidth:arg_imageWidth imageHeight:arg_imageHeight objectDetectionModelType:arg_objectDetectionModelType completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  ///predicts abstract number input
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.getPredictionCustom", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getPredictionCustomIndex:input:shape:dtype:completion:)], @"ModelApi api (%@) doesn't respond to @selector(getPredictionCustomIndex:input:shape:dtype:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSInteger arg_index = [GetNullableObjectAtIndex(args, 0) integerValue];
        NSArray<NSNumber *> *arg_input = GetNullableObjectAtIndex(args, 1);
        NSArray<NSNumber *> *arg_shape = GetNullableObjectAtIndex(args, 2);
        NSString *arg_dtype = GetNullableObjectAtIndex(args, 3);
        [api getPredictionCustomIndex:arg_index input:arg_input shape:arg_shape dtype:arg_dtype completion:^(NSArray<id> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  ///predicts raw image but returns the raw net output
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.getRawImagePredictionList", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getRawImagePredictionListIndex:imageData:completion:)], @"ModelApi api (%@) doesn't respond to @selector(getRawImagePredictionListIndex:imageData:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSInteger arg_index = [GetNullableObjectAtIndex(args, 0) integerValue];
        FlutterStandardTypedData *arg_imageData = GetNullableObjectAtIndex(args, 1);
        [api getRawImagePredictionListIndex:arg_index imageData:arg_imageData completion:^(NSArray<NSNumber *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  ///predicts raw image but returns the raw net output
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.getRawImagePredictionListObjectDetection", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getRawImagePredictionListObjectDetectionIndex:imageData:minimumScore:IOUThreshold:boxesLimit:completion:)], @"ModelApi api (%@) doesn't respond to @selector(getRawImagePredictionListObjectDetectionIndex:imageData:minimumScore:IOUThreshold:boxesLimit:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSInteger arg_index = [GetNullableObjectAtIndex(args, 0) integerValue];
        FlutterStandardTypedData *arg_imageData = GetNullableObjectAtIndex(args, 1);
        double arg_minimumScore = [GetNullableObjectAtIndex(args, 2) doubleValue];
        double arg_IOUThreshold = [GetNullableObjectAtIndex(args, 3) doubleValue];
        NSInteger arg_boxesLimit = [GetNullableObjectAtIndex(args, 4) integerValue];
        [api getRawImagePredictionListObjectDetectionIndex:arg_index imageData:arg_imageData minimumScore:arg_minimumScore IOUThreshold:arg_IOUThreshold boxesLimit:arg_boxesLimit completion:^(NSArray<ResultObjectDetection *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  ///predicts image but returns the raw net output
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.getImagePredictionList", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getImagePredictionListIndex:imageData:imageBytesList:imageWidthForBytesList:imageHeightForBytesList:mean:std:completion:)], @"ModelApi api (%@) doesn't respond to @selector(getImagePredictionListIndex:imageData:imageBytesList:imageWidthForBytesList:imageHeightForBytesList:mean:std:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSInteger arg_index = [GetNullableObjectAtIndex(args, 0) integerValue];
        FlutterStandardTypedData *arg_imageData = GetNullableObjectAtIndex(args, 1);
        NSArray<FlutterStandardTypedData *> *arg_imageBytesList = GetNullableObjectAtIndex(args, 2);
        NSNumber *arg_imageWidthForBytesList = GetNullableObjectAtIndex(args, 3);
        NSNumber *arg_imageHeightForBytesList = GetNullableObjectAtIndex(args, 4);
        NSArray<NSNumber *> *arg_mean = GetNullableObjectAtIndex(args, 5);
        NSArray<NSNumber *> *arg_std = GetNullableObjectAtIndex(args, 6);
        [api getImagePredictionListIndex:arg_index imageData:arg_imageData imageBytesList:arg_imageBytesList imageWidthForBytesList:arg_imageWidthForBytesList imageHeightForBytesList:arg_imageHeightForBytesList mean:arg_mean std:arg_std completion:^(NSArray<NSNumber *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  ///predicts image but returns the output detections
  {
    NSObject<FlutterTaskQueue> *taskQueue = [binaryMessenger makeBackgroundTaskQueue];
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.pytorch_lite.ModelApi.getImagePredictionListObjectDetection", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:nullGetPigeonCodec()
taskQueue:taskQueue];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(getImagePredictionListObjectDetectionIndex:imageData:imageBytesList:imageWidthForBytesList:imageHeightForBytesList:minimumScore:IOUThreshold:boxesLimit:completion:)], @"ModelApi api (%@) doesn't respond to @selector(getImagePredictionListObjectDetectionIndex:imageData:imageBytesList:imageWidthForBytesList:imageHeightForBytesList:minimumScore:IOUThreshold:boxesLimit:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSInteger arg_index = [GetNullableObjectAtIndex(args, 0) integerValue];
        FlutterStandardTypedData *arg_imageData = GetNullableObjectAtIndex(args, 1);
        NSArray<FlutterStandardTypedData *> *arg_imageBytesList = GetNullableObjectAtIndex(args, 2);
        NSNumber *arg_imageWidthForBytesList = GetNullableObjectAtIndex(args, 3);
        NSNumber *arg_imageHeightForBytesList = GetNullableObjectAtIndex(args, 4);
        double arg_minimumScore = [GetNullableObjectAtIndex(args, 5) doubleValue];
        double arg_IOUThreshold = [GetNullableObjectAtIndex(args, 6) doubleValue];
        NSInteger arg_boxesLimit = [GetNullableObjectAtIndex(args, 7) integerValue];
        [api getImagePredictionListObjectDetectionIndex:arg_index imageData:arg_imageData imageBytesList:arg_imageBytesList imageWidthForBytesList:arg_imageWidthForBytesList imageHeightForBytesList:arg_imageHeightForBytesList minimumScore:arg_minimumScore IOUThreshold:arg_IOUThreshold boxesLimit:arg_boxesLimit completion:^(NSArray<ResultObjectDetection *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
