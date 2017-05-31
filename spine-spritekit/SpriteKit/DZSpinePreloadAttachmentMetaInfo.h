//
//  DZSpinePreloadAttachmentMetaInfo.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZSpinePreloadAttachmentMetaInfo : NSObject

@property (nonatomic, strong, readonly) NSString *slotName;
@property (nonatomic, strong, readonly) NSString *attachmentName;

+ (instancetype)metaInfoWithSlotName:(NSString *)slotName
					  attachmentName:(NSString *)attachmentName;

@end
