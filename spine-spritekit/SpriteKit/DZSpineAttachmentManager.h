//
//  DZSpineAttachmentManager.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 27/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SKTexture.h>
#import "SpineRegionAttachment.h"

@interface DZSpineAttachmentManager : NSObject

- (void)setAttachment:(SpineRegionAttachment *)attachment
	forAttachmentName:(NSString *)attachmentName
			 slotName:(NSString *)slotName;

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName
									slotName:(NSString *)slotName;

@end
