//
//  VideoDecoder.m
//  PlayTest
//
//  Created by hc on 2018/1/11.
//  Copyright © 2018年 hc. All rights reserved.
//

#import "VideoDecoder.h"
#include <VideoToolbox/VideoToolbox.h>
#import <CoreImage/CoreImage.h>
#import <AppKit/AppKit.h>

static void outputCallback(void * decompressionOutputRefCon, void * sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef imageBuffer, CMTime presentationTimeStamp, CMTime presentationDuration)
{
    
    VideoDecoder* decoder = (__bridge  VideoDecoder*)decompressionOutputRefCon;
    decoder.newFrameAvailable(imageBuffer);
}

@interface VideoDecoder (){
    VTDecompressionSessionRef _vt_session;
    CMFormatDescriptionRef _formatDescription;
}

@end

@implementation VideoDecoder
- (void)dealloc{
    [self clean];
}    
    
- (void)setupWithSPS:(NSData*)sps pps:(NSData*)pps{
    [self clean];
    
    VTDecompressionOutputCallbackRecord outputCallbackRecord;
    outputCallbackRecord.decompressionOutputCallback = outputCallback;
    outputCallbackRecord.decompressionOutputRefCon = (__bridge void *)self;
    
    const uint8_t* const parameterSetPointers[2] = { (const uint8_t*)[sps bytes], (const uint8_t*)[pps bytes] };
    const size_t parameterSetSizes[2] = { [sps length], [pps length] };
    CMVideoFormatDescriptionCreateFromH264ParameterSets(NULL,2,parameterSetPointers,                                                             parameterSetSizes,4,&_formatDescription);
    
//    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(_formatDescription);
    
    NSDictionary* destinationPixelBufferAttributes = @{
                    (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                    (__bridge NSString*)kCVPixelBufferOpenGLCompatibilityKey : @(YES),
                    
                    (__bridge NSString*)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary],
                    };
    
    OSStatus status = VTDecompressionSessionCreate(kCFAllocatorDefault, _formatDescription, NULL, (__bridge CFDictionaryRef)destinationPixelBufferAttributes, &outputCallbackRecord, &_vt_session);
    
    if (status != noErr) {

    }
}

- (void)clean{
    if (_vt_session) {
        VTDecompressionSessionWaitForAsynchronousFrames(_vt_session);
        VTDecompressionSessionInvalidate(_vt_session);
        CFRelease(_vt_session);
        _vt_session = NULL;
    }
    
    if (_formatDescription){
        CFRelease(_formatDescription);
    }
}

- (void)decodeFrame:(unsigned char*)buffer bufferLen:(long)len{
    CMBlockBufferRef blockBuffer = NULL;
    CMBlockBufferCreateWithMemoryBlock(NULL, buffer, len, kCFAllocatorNull, NULL, 0, len, FALSE, &blockBuffer);
    
    CMSampleBufferRef sampleBuffer = NULL;
    CMSampleBufferCreate( NULL, blockBuffer, TRUE, 0, 0, _formatDescription, 1, 0, NULL, 0, NULL, &sampleBuffer);
    
    VTDecompressionSessionDecodeFrame(_vt_session, sampleBuffer, 0, NULL, 0);
    
    CFRelease(blockBuffer);
    CFRelease(sampleBuffer);
}
@end
