//
//  LiveCameraViewController.m
//  tf_simple_example
//
//  Created by Alexandra Stroulger on 2017-08-11.
//  Copyright © 2017 Google. All rights reserved.
//

#import "LiveCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FlowerClassifier.h"


@interface LiveCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation LiveCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpCamera];
    self.label1.text = @"testing";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

-(void)setUpCamera {
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    NSError *error = nil;

    AVCaptureDevice *cameraDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    [captureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error]];

    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;

    [captureSession startRunning];

    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];

    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    }

    output.videoSettings =
    @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

    dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];

    cameraDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 15);

    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    layer.bounds = self.view.bounds;

    layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    UIView *cameraPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];

    [cameraPreview.layer addSublayer:layer];
    [self.view addSubview:cameraPreview];
    [self.view sendSubviewToBack:cameraPreview];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSDictionary *classification = [FlowerClassifier getFlowerClassificationForImage:image];

    NSArray *keys = [classification allKeys];
    NSArray *values = [classification allValues];
    if (keys.count > 0 && values.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label1.text = keys[0];
            self.label2.text = [NSString stringWithFormat:@"%@", values[0]];
        });
    }

    NSLog(@"%@, %@", [classification allKeys].firstObject, [classification allValues].firstObject);
    NSLog(@"%@", image.description);
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{

    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);


    // Get the number of bytes per row for the pixel buffer
    u_int8_t *baseAddress = (u_int8_t *)malloc(bytesPerRow*height);
    memcpy( baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height     );

    // size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data

    //The context draws into a bitmap which is `width'
    //  pixels wide and `height' pixels high. The number of components for each
    //      pixel is specified by `space'
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);

    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);

    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);


    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];

    free(baseAddress);
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    
    return (image);
}

@end
