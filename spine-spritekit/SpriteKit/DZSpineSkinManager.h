//
//  DZSpineSkinManager.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 09/06/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpineSkin.h"

@interface DZSpineSkinManager : NSObject

- (instancetype)initWithSkins:(NSArray<SpineSkin *> *)skinList
				  currentSkin:(SpineSkin *)currentSkin;

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName slotName:(NSString *)slotName;

- (void)setSkinNamed:(NSString *)skinName;

@end
