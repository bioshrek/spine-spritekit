//
//  DZSpinePreloadAttachmentMetaInfo.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpinePreloadAttachmentMetaInfo.h"

@implementation DZSpinePreloadAttachmentMetaInfo

- (instancetype)initWithSlotName:(NSString *)slotName
				  attachmentName:(NSString *)attachmentName
{
	if (self = [super init]) {
		_slotName = [slotName copy];
		_attachmentName = [attachmentName copy];
	}
	return self;
}

+ (instancetype)metaInfoWithSlotName:(NSString *)slotName
					  attachmentName:(NSString *)attachmentName
{
	return [[self alloc] initWithSlotName:slotName attachmentName:attachmentName];
}

@end
