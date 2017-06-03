//
//  SpineRegionAttachment.m
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 27/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import "SpineRegionAttachment.h"
#import "DZSpineTexturePool.h"

@implementation SpineRegionAttachment

+ (instancetype)attachmentWithCAttachment:(spAttachment *)attachment
{
	
	if ( attachment
		&& attachment->name
		&& attachment->type == SP_ATTACHMENT_REGION) {
		
		spRegionAttachment *rattach = (spRegionAttachment *) attachment;
		NSString *name = @(attachment->name);
		NSString *atlasName = (__bridge NSString *) ((spAtlasRegion*)rattach->rendererObject)->page->rendererObject;
		BOOL regionRotated = NO;
		CGRect rectInAtlas = spine_uvs2rect(rattach->uvs, &regionRotated);
		rectInAtlas.origin.y = 1 - rectInAtlas.origin.y;
		SpineGeometry geometry = SpineGeometryMake(rattach->x, rattach->y, rattach->scaleX, rattach->scaleY, rattach->rotation);
		
		return [[self alloc] initWithName:name
								atlasName:atlasName
							  rectInAtlas:rectInAtlas
							regionRotated:regionRotated
								 geometry:geometry];
	} else {
		return nil;
	}
}

- (instancetype)initWithName:(NSString *)name
				   atlasName:(NSString *)atlasName
				 rectInAtlas:(CGRect)rectInAtlas
			   regionRotated:(BOOL)regionRotated
					geometry:(SpineGeometry)geometry
{
	if (self = [super init]) {
		_name = [name copy];
		_atlasName = [atlasName copy];
		_rectInAtlas = rectInAtlas;
		_regionRotated = regionRotated;
		_geometry = geometry;
	}
	return self;
}

- (SKTexture *)toTextTure
{
	SKTexture *textureAtlas = [[DZSpineTexturePool sharedPool] textureAtlasWithName:self.atlasName];
	return [SKTexture textureWithRect:self.rectInAtlas inTexture:textureAtlas];
}

- (void)applyToSpriteNode:(SKSpriteNode *)node
{
	node.texture = [self toTextTure];
	node.zRotation = 0;
	[[self class] applyGeometry:self.geometry toNode:node];
	node.zRotation += self.regionRotated ? -M_PI/2 : 0;
}

+ (void)applyGeometry:(SpineGeometry)geometry toNode:(SKNode *)node
{
	node.position = geometry.origin;
	node.xScale = geometry.scale.x;
	node.yScale = geometry.scale.y;
	CGFloat radians = (CGFloat)(geometry.rotation * M_PI / 180);
	node.zRotation = radians;
}

@end
