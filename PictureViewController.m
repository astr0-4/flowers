//
//  PictureViewController.m
//  tf_simple_example
//
//  Created by Alexandra Stroulger on 2017-08-02.
//  Copyright © 2017 Google. All rights reserved.
//

#import "PictureViewController.h"
#import "FlowerClassifier.h"

@interface PictureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;

@end

@implementation PictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)photoButtonPressed:(UIButton *)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (BOOL)startCameraControllerFromViewController:(UIViewController*) controller
                                   usingDelegate:(id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>)delegate {

    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) 
        return NO;

    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

    cameraUI.delegate = delegate;

    [controller presentViewController:cameraUI animated:YES completion:nil];

    return YES;
}

- (IBAction)photoLibraryButtonPressed:(id)sender {
    [self startPhotoLibraryControllerFromViewController:self usingDelegate:self];
}

-(BOOL)startPhotoLibraryControllerFromViewController:(UIViewController*) controller
                                  usingDelegate:(id <UIImagePickerControllerDelegate,
                                                 UINavigationControllerDelegate>)delegate {

    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;

    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraUI.delegate = delegate;

    [controller presentViewController:cameraUI animated:YES completion:nil];

    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf classifyImage:info];
    }];
}

-(void)classifyImage:(NSDictionary<NSString *,id> *)info {

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSDictionary *results = [FlowerClassifier getFlowerClassificationForImage:image];

    NSMutableString *alertMessage = [[NSMutableString alloc] init];
    for (NSString *key in [results allKeys]) {
        NSArray *sortedKeys = [[[[results allValues]
                                 sortedArrayUsingSelector:@selector(compare:)]
                                reverseObjectEnumerator]
                               allObjects];

        if ([sortedKeys.firstObject floatValue] < 0.8) {
            alertMessage = [[NSMutableString alloc] initWithString:@"No flowers here!"];
        } else {
            [alertMessage appendString:key];
            NSString *value = [NSString stringWithFormat:@": %.f%% \n", [[results objectForKey:key] floatValue] * 100];
            [alertMessage appendString:value];
        }
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your Results"
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
