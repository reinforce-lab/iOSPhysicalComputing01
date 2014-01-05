//
//  FaceDetector.m
//  OTOsense
//
//  Created by 昭宏 上原 on 12/06/19.
//  Copyright (c) 2012年 REINFORCE Lab. All rights reserved.
//

#import "FaceDetector.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>

@interface FaceDetector() {
    NSArray *_features;
    UIView *_preview;
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureVideoDataOutput *_videoOutput;
    CIDetector *_faceDetector;
    CALayer *_layer;
    
    int _imageOrientation;
}
@property (assign, nonatomic) BOOL isCameraAvailable;
@end

@implementation FaceDetector
#pragma mark - constructor
-(id)initWithView:(UIView *)preview
{
    self = [super init];
    if(self) {
        [self initVideoSession];
        
        _preview = preview;
        _faceDetector = [CIDetector
                         detectorOfType:CIDetectorTypeFace context:nil
                         options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
        
        //    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
        //                            context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
        // adding camera preview layer
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _previewLayer.frame = _preview.bounds;
        [_preview.layer addSublayer:_previewLayer];
        
        // add sublayer
        _layer = [CALayer layer];
        _layer.delegate = self;
        _layer.frame = _preview.bounds;
        _layer.contentsScale = [[UIScreen mainScreen] scale];
        [_preview.layer addSublayer:_layer];
        
        // 回転方向通知、登録
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}
-(void)dealloc
{
    [self stop];
    
    // 回転方向通知、登録削除
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - Private methods
- (void)didRotate:(NSNotification*)notification
{
    [self updateDeviceRotation:[UIDevice currentDevice].orientation];
}
- (void)updateDeviceRotation:(UIDeviceOrientation)orientation
{
    /*
     Value Location of the origin of the image
     1 Top, left
     2 Top, right
     3 Bottom, right
     4 Bottom, left
     5 Left, top
     6 Right, top
     7 Right, bottom
     8 Left, bottom
     */
    AVCaptureVideoOrientation videoOrietantion;
    _imageOrientation = 1;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrietantion = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationPortrait:
        default:
            videoOrietantion = AVCaptureVideoOrientationPortrait;
            break;
    }
    AVCaptureConnection *videoConnectin;
    
    // previewの表示向きを更新
    videoConnectin = _previewLayer.connection;
    if([videoConnectin isVideoOrientationSupported]) {
        [videoConnectin setVideoOrientation:videoOrietantion] ;
    }
    
    // 顔認識のソース画像の向きを更新
    videoConnectin = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if([videoConnectin isVideoOrientationSupported]) {
        [videoConnectin setVideoOrientation:videoOrietantion] ;
    }
}

- (void)initVideoSession {
    NSError *error;
    
    _captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    //    session_.sessionPreset = AVCaptureSessionPresetHigh;
    
    // setting up vidoe input
    //	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //NSLog(@"video device count: %d", [devices count]);
    self.isCameraAvailable = ([devices count] >= 2);
    if( ! self.isCameraAvailable) {
        return;
    }
    
    AVCaptureDevice *videoDevice = [devices objectAtIndex:1];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error) {
        NSLog(@"Video input device initialization error. %s, %@",__func__, error);
    }
    [_captureSession addInput:videoInput];
    
    // setting up video output
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // Specify the pixel format
    _videoOutput.videoSettings = [NSDictionary dictionaryWithObject:
                                  [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // queue for sample buffer callback
    dispatch_queue_t queue = dispatch_queue_create("videoqueue", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setSampleBufferDelegate:self queue:queue];
    
    _videoOutput.alwaysDiscardsLateVideoFrames = YES; // allow dropping a frame when its disposing time ups, default is YES
    [_captureSession addOutput:_videoOutput];
    
    [_captureSession commitConfiguration];
}

-(void)start
{
    if(! self.isCameraAvailable) return;
    
    // starting video session (starting preview)
    [_captureSession startRunning];
    
    // updating an orientation of the preview layer
    int64_t delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updateDeviceRotation:[UIDevice currentDevice].orientation];
    });
    
}
-(void)stop
{
    if(! self.isCameraAvailable) return;
    
    [_captureSession stopRunning];
}
#pragma mark - Private methods
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    // 描画領域のクリア
	CGContextSetRGBFillColor(ctx,   1.0, 1.0, 1.0, 0.0); // fill clear
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 0.0); // stroke transparent
	CGContextFillRect(ctx, _preview.bounds);
    
    // 領域の描画
    CGContextSetRGBStrokeColor(ctx, 0, 1.0, 0, 0.8); // stroke green
    CGContextSetLineWidth(ctx, 4);
    for(CIFaceFeature *feature in _features) {
        // 座標変換
        // 顔検出は、640x480 (ホームボタンを右に見て、第1象限。画面縦方向に640)
        // 画面表示領域は、320x411 (UIKitの座標系)
        // なので画面両端に 6px 隙間がある
        // 縮尺率は、0.624
        const float scale = 0.642;
        const CGRect r = feature.bounds;
        CGRect rect = CGRectMake((480 - r.origin.x - r.size.width)  * scale + 6,
                                 (680 - r.origin.y - r.size.height) * scale,
                                 r.size.height *scale,
                                 r.size.width  *scale);
        CGContextStrokeRect(ctx, rect);
        //NSLog(@"%@ bounds:%@", NSStringFromCGRect(rect), NSStringFromCGRect(previewView_.bounds));
    }
    
    CGContextRestoreGState(ctx);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    BOOL isVideoFrame = (captureOutput == (AVCaptureOutput *)_videoOutput);
    
    if(isVideoFrame)
    {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        
        /*
         image = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:
         kCIInputImageKey, image,
         @"inputColor0", [CIColor colorWithRed:0.0 green:0.2 blue:0.0],
         @"inputColor1", [CIColor colorWithRed:0.0 green:0.0 blue:1.0],
         nil].outputImage;*/
        //[coreImageContext_ drawImage:image atPoint:CGPointZero fromRect:[image extent] ];
        //[self.context presentRenderbuffer:GL_RENDERBUFFER];
        
        // face detection
        NSArray *features = [_faceDetector
                             featuresInImage:image
                             options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_imageOrientation] forKey:CIDetectorImageOrientation]];
        
        // 座標変換
        NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:10];
        if([features count] > 0) {
            CIFaceFeature *f = (CIFaceFeature *)[features objectAtIndex:0];
            CGRect r = f.bounds;
            CGRect rect = CGRectMake((480 - r.origin.x - r.size.width) *  255.0 / 480.0,
                                     (640 - r.origin.y)    * 255.0/ 640.0,
                                     r.size.width   * 255.0 / 480.0,
                                     r.size.height  * 255.0 / 640.0);
            [ary addObject:[NSValue valueWithCGRect:rect]];
        }
        
        // invoke delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            _features = features;
            [_layer setNeedsDisplay];
            [self.delegate detectionUpdated:ary];
        });
    }
}
@end
