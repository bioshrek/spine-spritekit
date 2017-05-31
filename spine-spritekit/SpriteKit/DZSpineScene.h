//
//  DZSpineScene.h
//  PZTool
//
//  Created by Simon Kim on 13. 10. 6..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DZSpinePreloadAttachmentMetaInfo.h"

@class DZSpineScene;
typedef void (^DZSpineSceneTouchBlock)(DZSpineScene *scene, NSSet<UITouch *> * touches, UIEvent *event);
typedef void (^DZSpineSceneContentFinishLoadingBlock)(DZSpineScene *scene);

@interface DZSpineScene : SKScene
@property (nonatomic, readonly) SKNode *rootNode;

@property (nonatomic, copy) DZSpineSceneTouchBlock touchBeganBlock;
@property (nonatomic, copy) DZSpineSceneTouchBlock touchMovedBlock;
@property (nonatomic, copy) DZSpineSceneTouchBlock touchEndedBlock;
@property (nonatomic, copy) DZSpineSceneTouchBlock touchCancelledBlock;

@property (nonatomic, copy) DZSpineSceneContentFinishLoadingBlock contentFinishLoadingBlock;

- (id) initWithSize:(CGSize)size;
- (id) initWithSize:(CGSize)size
	   skeletonName:(NSString *)skeletonName
	  animationName:(NSString *)animationName
			  scale:(CGFloat) scale;

- (instancetype)initWithSize:(CGSize)size
				skeletonName:(NSString *)skeletonName
			   animationName:(NSString *)animationName
					   scale:(CGFloat) scale
	   preloadAttachmentInfo:(NSArray<DZSpinePreloadAttachmentMetaInfo *> *)preloadAttachmentInfo;

/*
 * Override texture for the attachment specified by 'attachmentName'
 * @textureName: bundle image name that contains texture to be used for the slot as attachment
 * @rect: parameter to textureWithRect of -textureWithRect:inTexture: of SKTexture class
 * @attachmentName: name of attachment in .JSON file to override texture image
 
 * Can be called before or after presenting this scene to an SKView
 */
- (void) setTextureName:(NSString *) textureName rect:(CGRect) rect forAttachmentName:(NSString *) attachmentName;

- (void)setAttachment:(NSString *)attachmentName forSlot:(NSString *)slotName;

@end
