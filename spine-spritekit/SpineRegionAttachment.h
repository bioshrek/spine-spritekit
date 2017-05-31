//
//  SpineRegionAttachment.h
//  Spine-Spritekit-Demo
//
//  Created by Huan WANG on 27/05/2017.
//  Copyright © 2017 DZPub.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "spine_adapt.h"
#import "SpineGeometry.h"
#import <SpriteKit/SKTexture.h>
#import <SpriteKit/SKSpriteNode.h>

@interface SpineRegionAttachment : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *atlasName;
@property (nonatomic, assign, readonly) CGRect rectInAtlas;
@property (nonatomic, assign, readonly) BOOL regionRotated;
@property (nonatomic, assign, readonly) SpineGeometry geometry;

+ (instancetype)attachmentWithCAttachment:(spAttachment *)attachment;

- (SKTexture *)toTextTure;

- (void)applyToSpriteNode:(SKSpriteNode *)node;

@end
