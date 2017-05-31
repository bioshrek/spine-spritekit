//
//  DZSpineAnimationActionTransformer.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineAnimation.h"
#import <SpriteKit/SpriteKit.h>
#import "SpineSkeleton.h"
#import "DZSpineSceneBuilder.h"

@interface DZSpineBoneAnimationActionTransformer : NSObject

- (instancetype)initWithSkeleton:(SpineSkeleton *)skeleton
						 builder:(DZSpineSceneBuilder *)builder;

- (NSDictionary *)mapActionsFromBoneAnimations:(NSArray<SpineAnimation *> *)animations;

@end
