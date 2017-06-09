//
//  SpineSkin.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 09/06/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Skeleton.h"
#import "SpineRegionAttachment.h"

@interface SpineSkin : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL isDefault;

- (instancetype)initWithCSkin:(spSkin *)skin
					CSkeleton:(spSkeleton *)skeleton;

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName
									slotName:(NSString *)slotName;

@end
