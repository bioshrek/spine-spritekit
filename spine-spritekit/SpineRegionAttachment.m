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
	SKTexture *texture = [SKTexture textureWithRect:self.rectInAtlas inTexture:textureAtlas];
	return texture;
}

- (void)applyToSpriteNode:(SKSpriteNode *)node
{
	SKTexture *texture = [self toTextTure];
	node.texture = texture;
	node.size = texture.size;
	node.position = self.geometry.origin;
	node.zRotation = [self calculateZRotation];
	node.xScale = self.geometry.scale.x * self.scaleSkeleton;
	node.yScale = self.geometry.scale.y * self.scaleSkeleton;
}

- (CGFloat)calculateZRotation
{
	CGFloat radians = (CGFloat)(self.geometry.rotation * M_PI / 180);
	radians += self.regionRotated ? -M_PI_2 : 0;
	return radians;
}

@end
