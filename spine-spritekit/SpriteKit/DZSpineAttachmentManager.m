//
//  DZSpineAttachmentManager.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 27/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpineAttachmentManager.h"
#import "DZSpineTexturePool.h"

@interface DZSpineAttachmentManager ()

@property (nonatomic, strong) NSMutableDictionary *mapSlotToAttachment;

@end

@implementation DZSpineAttachmentManager

#pragma mark - Set Attachment

- (void)setAttachment:(SpineRegionAttachment *)attachment
	forAttachmentName:(NSString *)attachmentName
			 slotName:(NSString *)slotName
{
	NSMutableDictionary *nameMapper = [self ensureAttachmentNameMapperForSlotName:slotName];
	nameMapper[attachmentName] = attachment;
}

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName
									slotName:(NSString *)slotName
{
	NSDictionary *nameMapper = [self attachmentNameMapperForSlotName:slotName];
	return nameMapper[attachmentName];
}

- (NSMutableDictionary *)ensureAttachmentNameMapperForSlotName:(NSString *)slotName
{
	NSMutableDictionary *mapper = self.mapSlotToAttachment[slotName];
	if (nil == mapper) {
		mapper = [[NSMutableDictionary alloc] init];
		self.mapSlotToAttachment[slotName] = mapper;
	}
	return mapper;
}

- (NSDictionary *)attachmentNameMapperForSlotName:(NSString *)slotName
{
	return self.mapSlotToAttachment[slotName];
}

- (NSMutableDictionary *)mapSlotToAttachment
{
	if (!_mapSlotToAttachment) {
		_mapSlotToAttachment = [[NSMutableDictionary alloc] init];
	}
	return _mapSlotToAttachment;
}

@end
