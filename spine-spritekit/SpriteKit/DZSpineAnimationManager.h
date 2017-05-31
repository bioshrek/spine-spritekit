//
//  DZSpineAnimationManager.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineSkeleton.h"
#import "DZSpineSceneBuilder.h"

@interface DZSpineAnimationManager : NSObject

- (instancetype)initWithSkeleton:(SpineSkeleton *)skeleton
						 builder:(DZSpineSceneBuilder *)builder;

- (void)playAnimation:(NSString *)animationName repeat:(BOOL)repeat;

@end
