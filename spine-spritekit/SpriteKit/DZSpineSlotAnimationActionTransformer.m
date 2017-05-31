//
//  DZSpineSlotAnimationActionTransformer.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 31/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "DZSpineSlotAnimationActionTransformer.h"
#import "DZSpineTexturePool.h"
#import "SpineSequence.h"
#import "SpineGeometry.h"

#define GEOMETRY_FOR_ATTACHMENT(attachment) (SpineGeometryMake((attachment)->x, (attachment)->y, (attachment)->scaleX, (attachment)->scaleY, (attachment)->rotation))

@interface DZSpineSlotAnimationActionTransformer ()

@property (nonatomic, strong) SpineSkeleton *skeleton;
@property (nonatomic, strong) DZSpineSceneBuilder *builder;

@property (nonatomic, strong) NSMutableDictionary *mapTraceSettings;

- (void) setTraceOn:(BOOL) on type:(NSString *) type part:(NSString *) part;
- (BOOL) isTraceOnForType:(NSString *) type part:(NSString *) part;

@end

@implementation DZSpineSlotAnimationActionTransformer

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

#pragma mark - Slot Animation

- (NSDictionary *)mapActionsFromSlotAnimations:(NSArray<SpineAnimation *> *)animations
{
	// Slot Animations
	CGFloat delay = 0;  // delay between animations
	
	NSMutableDictionary *mapSlotToAction = [[NSMutableDictionary alloc] init];
	for( NSString *slotName in [self.builder allSlotNames]) {
		SKSpriteNode *sprite = [self.builder findNodeBySlotName:slotName];
		NSMutableArray *timeLineActions = [NSMutableArray array];
		CGFloat totalDuration = 0;
		BOOL hasAction = NO;
		
		if ( [self isTraceOnForType:@"slots" part:slotName]) {
			[timeLineActions addObject:[SKAction runBlock:^{
				NSLog(@"Beginning of sequence for sprite:%@", sprite.name);
			}]];
		}
		
		for( SpineAnimation *animation in animations) {
			SpineTimeline *timeline = [animation timelineForType:@"slots" forPart:slotName];
			CGFloat time = 0;
			if ( timeline ) {
				NSLog(@"timeline for slots.%@: %@", slotName, timeline);
				
				NSArray *sequences = [timeline sequencesForType:@"attachment"];
				
				// Setup Pose
				SKAction *action = [self skActionForSlotName:slotName attachmentName:nil duration:0 sprite:sprite];
				[timeLineActions addObject:action];
				
				if ( sequences.count > 0 ) {
					for( SpineSequenceSlot *sequence in sequences ) {
						CGFloat duration = sequence.time - time;
						SKAction *action = [self skActionForSlotName:slotName attachmentName:sequence.attachment duration:duration sprite:sprite];
						[timeLineActions addObject:action];
						
						time = sequence.time;
					}
				}
				hasAction = YES;
			}
			[timeLineActions addObject:[SKAction waitForDuration:animation.duration - time + delay]];
			totalDuration += animation.duration;
		}
		if ( [self isTraceOnForType:@"slots" part:slotName]) {
			[timeLineActions addObject:[SKAction runBlock:^{
				NSLog(@"End of sequence for sprite:%@ totalDuration:%2.3f", sprite.name, totalDuration);
			}]];
		}
		
		if ( hasAction > 0 ) {
			SKAction *slotAction = [SKAction sequence:timeLineActions];
			mapSlotToAction[slotName] = slotAction;
		}
	}
	return mapSlotToAction;
}

- (SKTexture *) textureForAttachment:(spAttachment *) attachment
							 rotated:(BOOL *) protated
{
	NSString *atlasName = nil;
	CGRect rect;
	SKTexture *texture = nil;
	*protated = NO;
	
	if ( attachment && attachment->name && attachment->type == ATTACHMENT_REGION) {
		
		// Try attachment
		if ( atlasName == nil) {
			spRegionAttachment *rattach = (spRegionAttachment *) attachment;
			
			atlasName = (__bridge NSString *) ((spAtlasRegion*)rattach->rendererObject)->page->rendererObject;
			rect = spine_uvs2rect(rattach->uvs, protated);
			rect.origin.y = 1 - rect.origin.y;
		}
		
		if ( atlasName ) {
			SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:atlasName];
			
			// Texture
			texture = [SKTexture textureWithRect:rect inTexture:textureAtlas];
			if (texture == nil) {
				NSLog(@"sprite: texture missing for %s atlas:%@ rect:%@", attachment->name, atlasName, NSStringFromCGRect(rect));
			}
		}
	}
	return texture;
}

- (spAttachment *) attachmentForSlotName:(NSString *) slotName attachmentName:(NSString *) attachmentName
{
	const char *slotname = [slotName UTF8String];
	const char *attachmentname = [attachmentName UTF8String];
	spAttachment *attachment = 0;
	spSlot *cslot;
	
	cslot = spSkeleton_findSlot(self.skeleton.spineContext->skeleton, slotname);
	if (attachmentname) {
		attachment = spSkeleton_getAttachmentForSlotName(self.skeleton.spineContext->skeleton, slotname, attachmentname);
	} else if ( cslot ) {
		attachment = cslot->attachment;
	}
	if ( attachment && attachment->type != ATTACHMENT_REGION) {
		attachment = 0;
	}
	
	return attachment;
}

- (SKAction *) skActionForSlotName:(NSString *) slotName
					attachmentName:(NSString *) attachmentName
						  duration:(CGFloat) duration
							sprite:(SKSpriteNode *) sprite;
{
	SKAction *action = nil;
	spAttachment *attachment = [self attachmentForSlotName:slotName attachmentName:attachmentName];
	NSMutableArray *subActions = [NSMutableArray array];
	SKAction *actionWaitFirst = nil;
	
	CGFloat minDuration = 0.1;
	if ( duration > minDuration) {
		actionWaitFirst = [SKAction waitForDuration:duration - minDuration];
		[subActions addObject:[SKAction waitForDuration:minDuration]];
	} else {
		[subActions addObject:[SKAction waitForDuration:duration]];
	}
	
	if ( attachment && attachment->name) {
		BOOL rotated;
		
		SKTexture *texture = [self textureForAttachment:attachment rotated:&rotated];
		[subActions addObject:[SKAction setTexture:texture]];
		
		SpineGeometry geometry = GEOMETRY_FOR_ATTACHMENT((spRegionAttachment *)attachment);
		geometry.scale.x *= self.skeleton.scale;
		geometry.scale.y *= self.skeleton.scale;
		
		CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
		CGSize size = texture.size;
		if ( rotated ) {
			radians += (-M_PI/2);
			size.width = texture.size.width;
			size.height = texture.size.height;
		}
		/*
		 * Workaround: actual size does not take xScale/yScale into account if a texture of a different size is set
		 * Thus, we scale the size explicitly
		 */
		size.width *= geometry.scale.x;
		size.height *= geometry.scale.y;
		
		[subActions addObject:[SKAction rotateToAngle:radians duration:0 shortestUnitArc:YES]];
		[subActions addObject:[SKAction moveTo:geometry.origin duration:0]];
		[subActions addObject:[SKAction resizeToWidth:size.width height:size.height duration:0]];
		[subActions addObject:[SKAction scaleXTo:geometry.scale.x y:geometry.scale.y duration:0]];
	} else {
		[subActions addObject:[SKAction runBlock:^{
			sprite.texture = nil;
		}]];
	}
	if ( [self isTraceOnForType:@"slots" part:slotName]) {
		NSString *attachmentName = attachment && attachment->name ? @(attachment->name) : @"";
		[subActions addObject:[SKAction runBlock:^{
			NSLog(@"slots.%@.attachment:%@ duration:%2.4f", slotName, attachmentName, duration);
		}]];
	}
	
	if ( actionWaitFirst ) {
		action = [SKAction sequence:@[actionWaitFirst, [SKAction group:subActions]]];
	} else {
		action = [SKAction group:subActions];
	}
	return action;
}


@end
