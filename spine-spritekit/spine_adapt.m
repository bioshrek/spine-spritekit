//
//  spine_adapt.c
//  PZTool
//
//  Created by Simon Kim on 13. 10. 9..
//  Copyright (c) 2013 DZPub.com. All rights reserved.
//

#include <stdio.h>
#include <spine/spine.h>
#include <spine/extension.h>
#include "spine_adapt.h"
#import <SpriteKit/SpriteKit.h>
#import "SpineRegionAttachment.h"

static spine_adapt_createtexture_t _callback_createTexture = 0;
static spine_adapt_disposetexture_t _callback_disposeTexture = 0;

extern void spine_logUVS( float *uvs, int atlas_width, int atlas_height);

int spine_load_test(char *skeletonname, char *atlasname, float scale, char *animationName)
{
    struct spinecontext ctx;
    spine_load(&ctx, skeletonname, atlasname, scale, animationName);
    spine_dump_animation(&ctx, animationName);
    spine_dispose(&ctx);
    return 0;
}

int spine_load(struct spinecontext *ctx, const char *skeletonname, const char *atlasname, float scale, const char *animationName)
{
    int result = -1;
    spAtlas *atlas = spAtlas_createFromFile(atlasname, 0);
    if ( atlas ) {
        printf("First region name: %s, x: %d, y: %d\n", atlas->regions->name, atlas->regions->x, atlas->regions->y);
        printf("First page name: %s, size: %d, %d\n", atlas->pages->name, atlas->pages->width, atlas->pages->height);
        
        spSkeletonJson *json = spSkeletonJson_create(atlas);
        json->scale = scale;
        
        spSkeletonData *skeletonData = spSkeletonJson_readSkeletonDataFile(json, skeletonname);
        if (!skeletonData) {
            printf("Error: %s\n", json->error);
            return -1;
        }
        
        printf("Default skin name: %s\n", skeletonData->defaultSkin->name);
        
        spSkeleton* skeleton = spSkeleton_create(skeletonData);
        if ( animationName == 0 && skeletonData->animationsCount > 0) {
            animationName = skeletonData->animations[0]->name;
            printf("spine: Selecting the first animation as a default:%s\n", animationName);
        }
        
        // animation
        spAnimation* animation = spSkeletonData_findAnimation(skeletonData, animationName);
        if (animation) {
            printf("Animation timelineCount: %d\n", animation->timelinesCount);
            printf("Animation duration: %2.2f\n", animation->duration);
        } else {
            printf("animation not found witt name:%s\n", animationName);
            return result;
        }
        
        
        spAnimationState *state;
        state = spAnimationState_create(spAnimationStateData_create(skeleton->data));
        
        spAnimationState_setAnimationByName(state, 0, animationName, 0);
        
        ctx->atlas = atlas;
        ctx->json = json;
        ctx->skeletonData = skeletonData;
        ctx->skeleton = skeleton;
        ctx->state = state;
        result = 0;
    } else {
        printf("spine: error opening atlas:%s\n", atlasname);
        
    }
	return result;
}

int spine_dump_animation(struct spinecontext *ctx, const char *animationName)
{
    float time = 0;
    int trackIndex = 0;
    int loop = 0;
    
    spAnimationState *state = ctx->state;
    spSkeleton *skeleton = ctx->skeleton;
    spAtlas *atlas = ctx->atlas;
    
    if ( animationName == 0 && ctx->skeletonData->animationsCount > 0) {
        animationName = ctx->skeletonData->animations[0]->name;
        printf("spine: Selecting the first animation as a default:%s\n", animationName);
    }
    
	spAnimation* animation = spSkeletonData_findAnimation(ctx->skeletonData, animationName);
    if ( animation == 0 ) {
        printf("spine: animation '%s' not found\n", animationName);
        return -1;
    }
    
	spSkeleton_update(skeleton, time);
	spAnimationState_setAnimationByName(state, trackIndex, animationName, loop);
    
    // slots
    do {
        printf( "time:%2.2f\n", time);
        
        spAnimationState_update(state, time);
        spAnimationState_apply(state, skeleton);
        spSkeleton_updateWorldTransform(skeleton);
        
        for (int i = 0, n = skeleton->slotsCount; i < n; i++) {
            spSlot* slot = skeleton->drawOrder[i];
            if (!slot->attachment || slot->attachment->type != SP_ATTACHMENT_REGION) continue;
            spRegionAttachment* attachment = (spRegionAttachment*)slot->attachment;
            float vertices[8];
            spRegionAttachment_computeWorldVertices(attachment, slot->bone, vertices);            // 	float x, y, scaleX, scaleY, rotation, width, height;
            printf("%s:\n -attachment (%2.2f, %2.2f, %2.2f, %2.2f) scale: (%2.2f, %2.2f) rotation:%2.2f\n",
                   attachment->super.name,
                   attachment->x, attachment->y, attachment->width, attachment->height,
                   attachment->scaleX, attachment->scaleY, attachment->rotation);
            printf("- bone (%2.2f, %2.2f) scale: (%2.2f, %2.2f) rotation:%2.2f\n",
                   slot->bone->worldX, slot->bone->worldY,
                   spBone_getWorldScaleX(slot->bone),
				   spBone_getWorldScaleY(slot->bone),
                   spBone_getWorldRotation(slot->bone));
            
            printf("- vertices: (%2.1f, %2.1f), (%2.1f, %2.1f), (%2.1f, %2.1f), (%2.1f, %2.1f)\n" \
                   "- uvs:(%2.2f, %2.2f), (%2.2f, %2.2f), (%2.2f, %2.2f), (%2.2f, %2.2f)\n" \
                   "- offset:(%2.2f, %2.2f), (%2.2f, %2.2f), (%2.2f, %2.2f), (%2.2f, %2.2f)\n",
                   vertices[SP_VERTEX_X1], vertices[SP_VERTEX_Y1],vertices[SP_VERTEX_X2], vertices[SP_VERTEX_Y2],
                   vertices[SP_VERTEX_X3], vertices[SP_VERTEX_Y3], vertices[SP_VERTEX_X4],vertices[SP_VERTEX_Y4],
                   attachment->uvs[SP_VERTEX_X1], attachment->uvs[SP_VERTEX_Y1], attachment->uvs[SP_VERTEX_X2], attachment->uvs[SP_VERTEX_Y2],
                   attachment->uvs[SP_VERTEX_X3], attachment->uvs[SP_VERTEX_Y3], attachment->uvs[SP_VERTEX_X4],attachment->uvs[SP_VERTEX_Y4],
                   attachment->offset[SP_VERTEX_X1], attachment->offset[SP_VERTEX_Y1],
                   attachment->offset[SP_VERTEX_X2], attachment->offset[SP_VERTEX_Y2],
                   attachment->offset[SP_VERTEX_X3], attachment->offset[SP_VERTEX_Y3],
                   attachment->offset[SP_VERTEX_X4],attachment->offset[SP_VERTEX_Y4]
                   );
            spine_logUVS(attachment->uvs, atlas->pages->width, atlas->pages->height);
            
        }
        time += 1;
    } while(time < animation->duration);
    return 0;
}

int spine_dispose( struct spinecontext *ctx)
{
    spAnimationState_dispose(ctx->state);
	spSkeleton_dispose(ctx->skeleton);
	spSkeletonData_dispose(ctx->skeletonData);
	spSkeletonJson_dispose(ctx->json);
	spAtlas_dispose(ctx->atlas);
    
    return 0;
}


#pragma mark - Spine Adaptation
void _spAtlasPage_createTexture (spAtlasPage* self, const char* path) {
    if ( _callback_createTexture != 0 ) {
        printf("%s[%d]: Creating a Texture at path='%s'\n", __FUNCTION__, __LINE__, path);
        self->rendererObject = _callback_createTexture(path, &self->width, &self->height);
    } else {
        printf("%s[%d]: Error did call spine_set_handler_createtexture()?\n", __FUNCTION__, __LINE__);
    }
}

void _spAtlasPage_disposeTexture (spAtlasPage* self) {
    if ( _callback_disposeTexture != 0) {
        _callback_disposeTexture(self->rendererObject);
        self->rendererObject = 0;
    } else {
        printf("%s[%d]: Error did call spine_set_handler_disposetexture()?\n", __FUNCTION__, __LINE__);
    }
}

char* _spUtil_readFile (const char* path, int* length) {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@(path) ofType:nil];
	return _readFile([bundlePath UTF8String], length);
}

void spine_set_handler_createtexture(spine_adapt_createtexture_t handler)
{
    _callback_createTexture = handler;
}
void spine_set_handler_disposetexture(spine_adapt_disposetexture_t handler)
{
    _callback_disposeTexture = handler;
}

CGRect spine_uvs2rect(float *uvs, BOOL *protated)
{
    CGRect region;
    if ( (uvs[SP_VERTEX_X3] - uvs[SP_VERTEX_X2]) == 0 ) {
        region.origin = CGPointMake(uvs[SP_VERTEX_X2], uvs[SP_VERTEX_Y2]);    // bottom-left
        region.size = CGSizeMake((uvs[SP_VERTEX_X4] - uvs[SP_VERTEX_X3]),(uvs[SP_VERTEX_Y1] - uvs[SP_VERTEX_Y4]));
        *protated = YES;
    } else {
        region.origin = CGPointMake(uvs[SP_VERTEX_X1], uvs[SP_VERTEX_Y1]);    // bottom-left
        region.size = CGSizeMake((uvs[SP_VERTEX_X3] - uvs[SP_VERTEX_X2]),(uvs[SP_VERTEX_Y1] - uvs[SP_VERTEX_Y2]));
        *protated = NO;
    }
    return region;
}

float spBone_getWorldRotation (spBone* self) {
	return ATAN2(self->c, self->d);
}

NSDictionary<NSString *, NSDictionary<NSString *, SpineRegionAttachment *> *> * spSkin_mapSlotToAttachmentMap(const spSkin* self, spSkeleton* skeleton) {
	NSMutableDictionary *mapSlotToAttachmentMap = [[NSMutableDictionary alloc] init];
	const _Entry* entry = SUB_CAST(_spSkin, self)->entries;
	while (entry) {
		spSlot *slot = skeleton->slots[entry->slotIndex];
		NSString *slotName = @(slot->data->name);
		NSMutableDictionary<NSString *, SpineRegionAttachment *> *mapNameToAttachment = mapSlotToAttachmentMap[slotName];
		if (nil == mapNameToAttachment) {
			mapNameToAttachment = [[NSMutableDictionary alloc] init];
			mapSlotToAttachmentMap[slotName] = mapNameToAttachment;
		}
		
		spAttachment *cAttachment = entry->attachment;
		SpineRegionAttachment *attachment = [SpineRegionAttachment attachmentWithCAttachment:cAttachment];
		if (attachment) {
			mapNameToAttachment[@(entry->name)] = attachment;
		}
		
		entry = entry->next;
	}
	return mapSlotToAttachmentMap;
}

#pragma mark - Spine Resource Loading Test

void spine_logUVS( float *uvs, int atlas_width, int atlas_height)
{

    BOOL rotated = NO;
    CGRect rect = spine_uvs2rect(uvs, &rotated);

    rect.origin.x *= atlas_width;
    rect.origin.y *= atlas_height;
    rect.size.width *= atlas_width;
    rect.size.height *= atlas_height;
    
    NSLog(@"%@ rotated:%@", NSStringFromCGRect(rect), rotated ? @"YES" : @"NO");
}

