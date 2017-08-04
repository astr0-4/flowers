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

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {

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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    __weak typeof(self) weakSelf = self;

    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf classifyImage:info];
    }];
}

-(void)classifyImage:(NSDictionary<NSString *,id> *)info {

    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *results = [FlowerClassifier getFlowerClassificationForImage:image];
    NSString *classificationMessage = [NSString stringWithFormat:@"Your flower is a: %@", results];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Classified!"
                                                                   message:classificationMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
