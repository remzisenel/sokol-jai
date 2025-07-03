/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated April 5, 2025. Replaces all prior versions.
 *
 * Copyright (c) 2013-2025, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software
 * or otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#ifndef SPINE_SKELETONBINARY_H_
#define SPINE_SKELETONBINARY_H_

#include "dll.h"
#include "Attachment.h"
#include "AttachmentLoader.h"
#include "SkeletonData.h"
#include "Atlas.h"

#ifdef __cplusplus
extern "C" {
#endif

struct spAtlasAttachmentLoader;

typedef struct spSkeletonBinary {
	float scale;
	spAttachmentLoader *attachmentLoader;
	char *error;
} spSkeletonBinary;

SP_API spSkeletonBinary *spSkeletonBinary_createWithLoader(spAttachmentLoader *attachmentLoader);

SP_API spSkeletonBinary *spSkeletonBinary_create(spAtlas *atlas);

SP_API void spSkeletonBinary_dispose(spSkeletonBinary *self);

SP_API spSkeletonData *
spSkeletonBinary_readSkeletonData(spSkeletonBinary *self, const unsigned char *binary, const int length);

SP_API spSkeletonData *spSkeletonBinary_readSkeletonDataFile(spSkeletonBinary *self, const char *path);

#ifdef __cplusplus
}
#endif

#endif /* SPINE_SKELETONBINARY_H_ */
