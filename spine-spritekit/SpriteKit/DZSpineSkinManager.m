//
//  DZSpineSkinManager.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 09/06/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpineSkinManager.h"
#import "NSArray+F.h"

@interface DZSpineSkinManager ()

@property (nonatomic, strong, readonly) NSDictionary<NSString *, SpineSkin *> *mapNameToSkin;
@property (nonatomic, strong, readonly) SpineSkin *defaultSkin;
@property (nonatomic, strong) SpineSkin *currentSkin;

@end

@implementation DZSpineSkinManager

- (instancetype)initWithSkins:(NSArray<SpineSkin *> *)skinList
				  currentSkin:(SpineSkin *)currentSkin
{
	if (self = [super init]) {
		_defaultSkin = [[skinList filter:^BOOL(SpineSkin *skin) {
			return skin.isDefault;
		}] firstObject];
		_currentSkin = currentSkin;
		_mapNameToSkin = [self createMappingNameToSkinWithSkins:skinList];
	}
	return self;
}

- (NSDictionary *)createMappingNameToSkinWithSkins:(NSArray<SpineSkin *> *)skinList
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[skinList count]];
	[skinList enumerateObjectsUsingBlock:^(SpineSkin * _Nonnull skin, NSUInteger idx, BOOL * _Nonnull stop) {
		dict[skin.name] = skin;
	}];
	return dict;
}

- (SpineRegionAttachment *)attachmentForName:(NSString *)attachmentName slotName:(NSString *)slotName
{
	SpineRegionAttachment *attachment = [self.currentSkin attachmentForName:attachmentName slotName:slotName];
	if (attachment) {
		return attachment;
	}
	
	attachment = [self.defaultSkin attachmentForName:attachmentName slotName:slotName];
	return attachment;
}

- (void)setSkinNamed:(NSString *)skinName
{
	SpineSkin *skin = self.mapNameToSkin[skinName];
	if (nil == skin) {
		return;
	}
	self.currentSkin = skin;
}

@end
