//
//  DZSpineAnimationActionTransformer.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpineBoneAnimationActionTransformer.h"
#import "SpineSequence.h"
#import "SpineGeometry.h"

#define GEOMETRY_FOR_BONE(bone) SpineGeometryMake(bone->data->x, bone->data->y, bone->data->scaleX, bone->data->scaleY, bone->data->rotation)

@interface DZSpineBoneAnimationActionTransformer ()

@property (nonatomic, strong) SpineSkeleton *skeleton;
@property (nonatomic, strong) DZSpineSceneBuilder *builder;

@property (nonatomic, strong) NSMutableDictionary *mapTraceSettings;

- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part;
- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part;

@end


@implementation DZSpineBoneAnimationActionTransformer

- (instancetype)initWithSkeleton:(SpineSkeleton *)skeleton
						 builder:(DZSpineSceneBuilder *)builder
{
	self = [super init];
	if ( self ) {
		_skeleton = skeleton;
		_builder = builder;
		
	}
	return self;
}

#pragma mark - Trace
- (NSMutableDictionary *) mapTraceSettings
{
	if ( _mapTraceSettings == nil ) {
		_mapTraceSettings = [NSMutableDictionary dictionary];
	}
	return _mapTraceSettings;
}

- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part
{
	NSMutableDictionary *mapParts = self.mapTraceSettings[type];
	if ( mapParts == nil ) {
		mapParts = [NSMutableDictionary dictionary];
		self.mapTraceSettings[type] = mapParts;
	}
	mapParts[part] = @(on);
}

- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part
{
	NSMutableDictionary *mapParts = self.mapTraceSettings[type];
	return (mapParts != nil && [mapParts[part] boolValue] == YES);
}

#pragma mark - Experimental Bone Animation

- (NSDictionary *)mapActionsFromBoneAnimations:(NSArray<SpineAnimation *> *)animations
{
	CGFloat delay = 0;
	
	NSMutableDictionary *mapBoneToAction = [[NSMutableDictionary alloc] init];
	for( NSString *boneName in [self.builder allBoneNames]) {
		SKNode *node = [self.builder findNodeByBoneName:boneName];
		spBone *bone = spSkeleton_findBone(self.skeleton.spineContext->skeleton, [boneName UTF8String]);
		
		
		if ( node && bone ) {
			NSMutableArray *timeLineActions = [NSMutableArray array];
			for (SpineAnimation *animation in animations) {
				SpineTimeline *timeline = [animation timelineForType:@"bones" forPart:boneName];
				if ( timeline ) {
					SKAction *action = [self skActionForBone:bone timeline:timeline duration:animation.duration delay:delay];
					if ( action ) {
						[timeLineActions addObject:action];
					}
				}
			}
			if ( timeLineActions.count > 0) {
				SKAction *boneAction = [SKAction sequence:timeLineActions];
				mapBoneToAction[boneName] = boneAction;
			}
		}
	}
	return mapBoneToAction;
}

- (SKAction *) skActionForBone:(spBone *) bone sequence:(SpineSequence *) sequence
{
	SKAction *action = nil;
	SpineGeometry geometry = GEOMETRY_FOR_BONE(bone);
	NSString *boneName = @(bone->data->name);
	
	if ( sequence.dummy ) {
		action = [SKAction waitForDuration:sequence.duration];
	} else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesTranslate]) {
		CGPoint point = geometry.origin; //node.position;
		point.x += ((SpineSequenceBone *)sequence).translate.x;
		point.y += ((SpineSequenceBone *)sequence).translate.y;
		
		action = [SKAction moveTo:point duration:sequence.duration];
		
	} else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesRotate]) {
		CGFloat radians = geometry.rotation * M_PI / 180;
		radians += ((SpineSequenceBone *)sequence).angle * M_PI / 180;
		action = [SKAction rotateToAngle:radians duration:sequence.duration shortestUnitArc:YES];
	} else if ( [sequence.type isEqualToString:kSpineSequenceTypeBonesScale]) {
		CGPoint scale = geometry.scale;
		scale.x *= ((SpineSequenceBone *)sequence).scale.x;
		scale.y *= ((SpineSequenceBone *)sequence).scale.y;
		action = [SKAction scaleXTo:scale.x y:scale.y duration:sequence.duration];
	} else {
		NSLog(@"Unsupported sequence type:%@", sequence.type);
		action = [SKAction waitForDuration:sequence.duration];
	}
	
	if ( [self isTraceOnForType:@"bones" part:boneName]) {
		action = [SKAction group:@[action, [SKAction runBlock:^{
			NSLog(@"bones.%@.type:%@ duration:%2.4f sequence:%@", boneName, sequence.type, sequence.duration, sequence);
		}]]];
	}
	
	return action;
}

- (SKAction *) skActionsForBone:(spBone *) bone sequences:(NSArray *) sequences sequenceType:(NSString *) sequenceType
{
	NSMutableArray *actions = [NSMutableArray array];
	CGFloat totalDuration = 0;
	NSString *boneName = @(bone->data->name);
	SpineSequence *lastSequence = sequences[0];
	
	lastSequence.duration = lastSequence.time;
	[actions addObject:[self skActionForBone:bone sequence:lastSequence]];
	
	totalDuration += lastSequence.duration;
	SpineSequence *sequence = nil;
	for( int i = 1; i < sequences.count; i++ ) {
		sequence = sequences[i];
		sequence.duration = sequence.time - lastSequence.time;
		SKAction *action = [self skActionForBone:bone sequence:sequence];
		
		// Apply curve data in the last sequence
		if (lastSequence.curve == SpineSequenceCurveBezier ) {
			action.timingMode = SKActionTimingEaseInEaseOut;
		} else {
			action.timingMode = SKActionTimingLinear;
		}
		[actions addObject:action];
		totalDuration += sequence.duration;
		
		lastSequence = sequence;
	}
	
	if ( [self isTraceOnForType:@"bones" part:boneName]) {
		[actions addObject:[SKAction runBlock:^{
			NSLog(@"End of sequence for bone:%@ type:%@ totalDuration:%2.3f", boneName, sequenceType, totalDuration);
		}]];
	}
	return [SKAction sequence:actions];
}

- (SKAction *) skActionForBone:(spBone *) bone timeline:(SpineTimeline *) timeline duration:(CGFloat) duration delay:(CGFloat) delay
{
	NSMutableArray *actions = [NSMutableArray array];
	NSArray *sequenceTypes = [timeline types];
	SKAction *poseGroup = nil;
	NSString *boneName = @(bone->data->name);
	
	// Pose actions
	if ( [self isTraceOnForType:@"bones" part:boneName]) {
		[actions addObject:[SKAction runBlock:^{
			NSLog(@"Beginning of sequence for bone:%@", boneName);
		}]];
	}
	
	// Ugly Hack: pose setup if the first sequence is not a time 0s
	SpineGeometry geometry = GEOMETRY_FOR_BONE(bone);
	CGFloat poseDelay = delay;
	if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesTranslate] || [[timeline sequencesForType:kSpineSequenceTypeBonesTranslate][0] time] != 0) {
		[actions addObject:[SKAction moveTo:geometry.origin duration:poseDelay]];
	}
	if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesRotate] || [[timeline sequencesForType:kSpineSequenceTypeBonesRotate][0] time] != 0) {
		CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
		[actions addObject:[SKAction rotateToAngle:radians duration:poseDelay shortestUnitArc:YES]];
	}
	if ( ![sequenceTypes containsObject:kSpineSequenceTypeBonesScale] || [[timeline sequencesForType:kSpineSequenceTypeBonesScale][0] time] != 0) {
		[actions addObject:[SKAction scaleXTo:geometry.scale.x y:geometry.scale.y duration:poseDelay]];
	}
	
	if ( [self isTraceOnForType:@"bones" part:boneName]) {
		[actions addObject:[SKAction runBlock:^{
			NSLog(@"After Pose for bone:%@", boneName);
		}]];
	}
	poseGroup = [SKAction group:actions];
	[actions removeAllObjects];
	
	for( NSString *sequenceType in sequenceTypes) {
		NSArray *sequences = [timeline sequencesForType:sequenceType];
		SKAction *action = [self skActionsForBone:bone sequences:sequences sequenceType:sequenceType];
		[actions addObject:action];
	}
	
	
	NSMutableArray *mainActions = [NSMutableArray array];
	if ( poseGroup ) {
		[mainActions addObject:poseGroup];
	}
	if ( actions.count > 0) {
		[mainActions addObject:[SKAction group:actions]];
	}
	
	SKAction *action = nil;
	if ( mainActions.count > 0 ) {
		if ( [self isTraceOnForType:@"bones" part:boneName]) {
			[mainActions addObject:[SKAction runBlock:^{
				NSLog(@"End of sequence for bone:%@ totalDuration:%2.3f", boneName, duration);
			}]];
		}
		
		[actions removeAllObjects];
		[actions addObject:[SKAction sequence:mainActions]];
		
		// Synchronize the whole duration of the part animation
		[actions addObject:[SKAction waitForDuration:duration]];
		action = [SKAction group:actions];
	}
	return action;
}

@end
