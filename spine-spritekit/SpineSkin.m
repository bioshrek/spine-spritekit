//
//  SpineSkin.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 09/06/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "SpineSkin.h"
#import "spine_adapt.h"
#import "NSDictionary+F.h"

@interface SpineSkin ()

@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary<NSString *, SpineRegionAttachment *> *> *mapSlotToAttachmentMap;

@end

@implementation SpineSkin

- (instancetype)initWithCSkin:(spSkin *)skin
					CSkeleton:(spSkeleton *)skeleton
{
	if (NULL == skin ||
		NULL == skeleton) {
		return nil;
	}
	
	if (self = [super init]) {
		_name = @(skin->name);
		
		spSkin *defaultSkin = skeleton->data->defaultSkin;
		_isDefault = defaultSkin ? (0 == strcmp(skin->name, defaultSkin->name)) : NO;
		self.mapSlotToAttachmentMap = spSkin_mapSlotToAttachmentMap(skin, skeleton);;
	}
	return self;
}

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName slotName:(NSString *)slotName
{
	SpineRegionAttachment *attachment = self.mapSlotToAttachmentMap[slotName][attachmentName];
	return attachment;
}

@end
