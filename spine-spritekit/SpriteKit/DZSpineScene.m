//
//  DZSpineScene.m
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import "DZSpineScene.h"
#import "DZSpineLoader.h"
#import "DZSpineTexturePool.h"
#import "DZSpineSceneBuilder.h"
#import "NSArray+F.h"
#import "DZSpineAnimationManager.h"
#import "DZSpineSkinManager.h"

@interface DZSpineScene()
@property (nonatomic) BOOL contentCreated;
@property (nonatomic, strong) DZSpineSceneBuilder *builder;
@property (nonatomic, strong) DZSpineAnimationManager *animationManager;
@property (nonatomic, strong) DZSpineSkinManager *skinManager;

@property (nonatomic, strong) NSString *skeletonName;
@property (nonatomic, strong) NSString *animationName;
@property (nonatomic) CGFloat scaleSkeleton;
@property (nonatomic) BOOL debugNodes;

@end

@implementation DZSpineScene
@synthesize rootNode = _rootNode;

- (id) initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if ( self ) {
        self.scaleSkeleton = 1;
        self.debugNodes = NO;
        self.builder = nil;
        self.skeletonName = nil;
        self.animationName = nil;
    }
    return self;
}

- (id) initWithSize:(CGSize)size skeletonName:(NSString *) skeletonName animationName:(NSString *) animationName scale:(CGFloat) scale
{
    self = [self initWithSize:size];
    if ( self ) {
        self.scaleSkeleton = scale;
        self.skeletonName = skeletonName;
        self.animationName = animationName;
        self.debugNodes = YES;
        self.builder = [DZSpineSceneBuilder builder];
        self.builder.debug = self.debugNodes;
    }
    return self;
}

- (SKNode *) rootNode
{
    if ( _rootNode == nil ) {
        _rootNode = [SKNode node];
        CGPoint center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) /*/2 */);
        _rootNode.position = center;
        [self addChild:_rootNode];
    }
    return _rootNode;
}

#pragma mark - Overrides
- (void) didMoveToView:(SKView *)view
{
    if( !self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
		[self notifyContentFinishLoading];
    }
}

- (void)notifyContentFinishLoading
{
	if (self.contentFinishLoadingBlock) {
		self.contentFinishLoadingBlock(self);
	}
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self signatureLabelNode]];
    
    if ( self.skeletonName ) {
        SpineSkeleton *skeleton = [DZSpineSceneBuilder loadSkeletonName:self.skeletonName scale:self.scaleSkeleton];
        if ( skeleton ) {
            [self.rootNode addChild:[self.builder nodeWithSkeleton:skeleton animationName:self.animationName loop:YES]];
			[self createAnimationManagerWithSkeleton:skeleton];
			self.skinManager = [[DZSpineSkinManager alloc] initWithSkins:skeleton.skins currentSkin:skeleton.currentSkin];
        }
    }
}

- (void)createAnimationManagerWithSkeleton:(SpineSkeleton *)skeleton
{
	self.animationManager = [[DZSpineAnimationManager alloc] initWithSkeleton:skeleton
																	  builder:self.builder];
}

- (void)setAttachment:(NSString *)attachmentName forSlot:(NSString *)slotName
{
	[self.builder setAttachmentName:attachmentName forSlotName:slotName];
	[self renderAttachment:attachmentName forSlot:slotName];
}

- (void)renderAttachment:(NSString *)attachmentName forSlot:(NSString *)slotName
{
	SpineRegionAttachment *attachment = [self.skinManager attachmentForName:attachmentName slotName:slotName];
	if (nil == attachment) {
		return;
	}
	attachment.scaleSkeleton = self.scaleSkeleton;
	
	SKSpriteNode *node = [self.builder findNodeBySlotName:slotName];
	if (nil == node) {
		return;
	}
	
	[attachment applyToSpriteNode:node];
}

- (void)playAnimationWithName:(NSString *)animationName repeat:(BOOL)repeat
{
	[self.animationManager playAnimation:animationName repeat:repeat];
}

- (void)setSkinName:(NSString *)skinName
{
	[self.skinManager setSkinNamed:skinName];
	[self.builder enumerateSlotsWithAttachments:^(NSString *slotName, NSString *attachmentName, BOOL *stop) {
		[self renderAttachment:attachmentName forSlot:slotName];
	}];
}

- (CGRect)rectForSlot:(NSString *)slotName
{
	SKSpriteNode *node = [self.builder findNodeBySlotName:slotName];
	if (nil == node) {
		return CGRectZero;
	}
	
	const CGPoint locationInScene = [node.scene convertPoint:node.position fromNode:node.parent];
	const CGPoint locationInView = [self convertPointToView:locationInScene];
	const CGSize size = node.size;
	return CGRectMake(locationInView.x - size.width / 2.0,
					  locationInView.y - size.height / 2.0f,
					  size.width,
					  size.height);
}

- (void) didEvaluateActions
{

}

#pragma mark -
- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect forAttachmentName:(NSString *)attachmentName
{
    [self.builder setTextureName:textureName rect:rect forAttachmentName:attachmentName];
}

#pragma mark - Misc.
- (SKLabelNode *)signatureLabelNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.text = @"Spine-SpriteKit Demo";
    helloNode.fontSize = 26;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
    helloNode.fontColor = [UIColor darkGrayColor];
    
    helloNode.name = @"signatureLabel";
    return helloNode;
}

#pragma mark - Actions

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (self.touchBeganBlock) {
		self.touchBeganBlock(self, touches, event);
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	if (self.touchMovedBlock) {
		self.touchMovedBlock(self, touches, event);
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	if (self.touchEndedBlock) {
		self.touchEndedBlock(self, touches, event);
	}
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	if (self.touchCancelledBlock) {
		self.touchCancelledBlock(self, touches, event);
	}
}

@end

