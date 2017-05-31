//
//  DZSpineAnimationManager.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpineAnimationManager.h"
#import "NSArray+F.h"
#import "DZSpineBoneAnimationActionTransformer.h"
#import "DZSpineSlotAnimationActionTransformer.h"

@interface DZSpineAnimationManager ()

@property (nonatomic, strong) NSDictionary *mapAnimationToBoneActionInfo;
@property (nonatomic, strong) NSDictionary *mapAnimationToSlotActionInfo;

@property (nonatomic, weak) DZSpineSceneBuilder *builder;

@end

@implementation DZSpineAnimationManager

- (instancetype)initWithSkeleton:(SpineSkeleton *)skeleton
						 builder:(DZSpineSceneBuilder *)builder
{
	if (self = [super init]) {
		_builder = builder;
		
		_mapAnimationToBoneActionInfo =
			[self createMappingAnimationToBoneActionInfoWithSkeleton:skeleton builder:builder];
		_mapAnimationToSlotActionInfo =
			[self createMappingAnimationToSlotActionInfoWithSkeleton:skeleton builder:builder];
	}
	return self;
}

- (NSDictionary *)createMappingAnimationToBoneActionInfoWithSkeleton:(SpineSkeleton *)skeleton
															 builder:(DZSpineSceneBuilder *)builder
{
	// + transformer
	// animationName -> animation -> action info
	
	DZSpineBoneAnimationActionTransformer *transformer =
		[[DZSpineBoneAnimationActionTransformer alloc] initWithSkeleton:skeleton builder:builder];
	
	NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
	NSArray *animationNameList = [skeleton allAnimationNames];
	[animationNameList enumerateObjectsUsingBlock:
	 ^(NSString * _Nonnull animationName, NSUInteger idx, BOOL * _Nonnull stop) {
		 SpineAnimation *animation = [skeleton animationWithName:animationName];
		 if (animation) {
			 NSDictionary *actionInfo = [transformer mapActionsFromBoneAnimations:@[animation]];
			 if (actionInfo) {
				 mapper[animationName] = actionInfo;
			 }
		 }
	}];
	return mapper;
}

- (NSDictionary *)createMappingAnimationToSlotActionInfoWithSkeleton:(SpineSkeleton *)skeleton
															 builder:(DZSpineSceneBuilder *)builder
{
	// + transformer
	// animationName -> animation -> action info
	
	DZSpineSlotAnimationActionTransformer *transformer =
	[[DZSpineSlotAnimationActionTransformer alloc] initWithSkeleton:skeleton builder:builder];
	
	NSMutableDictionary *mapper = [[NSMutableDictionary alloc] init];
	NSArray *animationNameList = [skeleton allAnimationNames];
	[animationNameList enumerateObjectsUsingBlock:
	 ^(NSString * _Nonnull animationName, NSUInteger idx, BOOL * _Nonnull stop) {
		 SpineAnimation *animation = [skeleton animationWithName:animationName];
		 if (animation) {
			 NSDictionary *actionInfo = [transformer mapActionsFromSlotAnimations:@[animation]];
			 if (actionInfo) {
				 mapper[animationName] = actionInfo;
			 }
		 }
	 }];
	return mapper;
}

- (NSDictionary *)boneActionInfoForAnimation:(NSString *)animationName
{
	return self.mapAnimationToBoneActionInfo[animationName];
}

- (NSDictionary *)slotActionInfoForAnimation:(NSString *)animationName
{
	return self.mapAnimationToSlotActionInfo[animationName];
}

- (void)playAnimation:(NSString *)animationName repeat:(BOOL)repeat
{
	[self removeAllBoneAnimations];
	[self removeAllSlotAnimations];
	
	[self playBoneAnimation:animationName repeat:repeat];
	[self playSlotAnimation:animationName repeat:repeat];
}

- (void)removeAllBoneAnimations
{
	NSArray<NSString *> *boneNameList = [self.builder allBoneNames];
	[boneNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull boneName, NSUInteger idx, BOOL * _Nonnull stop) {
		// node + action
		
		SKNode *node = [self.builder findNodeByBoneName:boneName];
		if (node) {
			[node removeAllActions];
		}
	}];
}

- (void)playBoneAnimation:(NSString *)animationName repeat:(BOOL)repeat
{
	NSDictionary *mapBoneToAction = [self boneActionInfoForAnimation:animationName];
	if (0 == [mapBoneToAction count]) {
		return;
	}
	
	NSArray<NSString *> *boneNameList = [self.builder allBoneNames];
	[boneNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull boneName, NSUInteger idx, BOOL * _Nonnull stop) {
		// node + action
		
		SKNode *node = [self.builder findNodeByBoneName:boneName];
		SKAction *action = mapBoneToAction[boneName];
		if (node && action) {
			if (repeat) {
				[node runAction:[SKAction repeatActionForever:action]];
			} else {
				[node runAction:action];
			}
		}
	}];
}

- (void)removeAllSlotAnimations
{
	NSArray<NSString *> *slotNameList = [self.builder allSlotNames];
	[slotNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull slotName, NSUInteger idx, BOOL * _Nonnull stop) {
		// node + action
		
		SKNode *node = [self.builder findNodeBySlotName:slotName];
		if (node) {
			[node removeAllActions];
		}
	}];
}

- (void)playSlotAnimation:(NSString *)animationName repeat:(BOOL)repeat
{
	NSDictionary *mapSlotToAction = [self slotActionInfoForAnimation:animationName];
	if (0 == [mapSlotToAction count]) {
		return;
	}
	
	NSArray<NSString *> *slotNameList = [self.builder allSlotNames];
	[slotNameList enumerateObjectsUsingBlock:^(NSString * _Nonnull slotName, NSUInteger idx, BOOL * _Nonnull stop) {
		// node + action
		
		SKNode *node = [self.builder findNodeBySlotName:slotName];
		SKAction *action = mapSlotToAction[slotName];
		if (node && action) {
			if (repeat) {
				[node runAction:[SKAction repeatActionForever:action]];
			} else {
				[node runAction:action];
			}
		}
	}];
}

@end
