//
//  FlowerClassifier.h
//  tf_simple_example
//
//  Created by Alexandra Stroulger on 2017-08-03.
//  Copyright © 2017 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlowerClassifier : NSObject

+ (NSString *)getFlowerClassificationForImage:(UIImage *)image;

@end
