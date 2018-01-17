//
//  PlayerView.m
//  PlayTest
//
//  Created by hc on 2018/1/11.
//  Copyright © 2018年 hc. All rights reserved.
//

#import "PlayerView.h"
#include <OpenGL/gl.h>
#import <CoreImage/CoreImage.h>

@interface PlayerView(){
    CVPixelBufferRef _displayBuffer;
    CIContext* _ciContext;
    BOOL _needsReshape;
    NSRect _bounds;
}

@end

@implementation PlayerView

- (void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    _needsReshape = YES;
    _bounds = [self bounds];
}

- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [super initWithCoder:decoder]){
        
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFADepthSize, 24,
            // Must specify the 3.2 Core Profile to use OpenGL 3.2
#if ESSENTIAL_GL_PRACTICES_SUPPORT_GL3
            NSOpenGLPFAOpenGLProfile,
            NSOpenGLProfileVersion3_2Core,
#endif
            0
        };
        
        NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        
        [self setPixelFormat:pf];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _ciContext = [CIContext contextWithCGLContext:(CGLContextObj)[[self openGLContext] CGLContextObj]
                                          pixelFormat:(CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj]
                                           colorSpace:colorSpace
                                              options:nil];
        CGColorSpaceRelease(colorSpace);
    }
    
    return self;
}

- (void)display:(CVPixelBufferRef)pixelBuffer{
    if (_displayBuffer){
        CFRelease(_displayBuffer);
    }
    
    _displayBuffer = pixelBuffer;
    CFRetain(_displayBuffer);
    
    [self drawRect:NSZeroRect];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[self openGLContext] lock];
    [[self openGLContext] makeCurrentContext];
    if (_displayBuffer){
        CVPixelBufferLockBaseAddress(_displayBuffer, 0);
        
        if (_needsReshape){
            _needsReshape = NO;
            glViewport(0, 0, _bounds.size.width ,_bounds.size.height);
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity();
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glOrtho(0, _bounds.size.width, 0, _bounds.size.height, -1.0, 1.0);
        }
        
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        size_t width = CVPixelBufferGetWidth(_displayBuffer);
        size_t height = CVPixelBufferGetHeight(_displayBuffer);

        float src = (float)width / (float)height;
        float dst = _bounds.size.width / _bounds.size.height;
        
        if (src > dst){
            width = _bounds.size.width;
            height = width / src;
        }else{
            height = _bounds.size.height;
            width = height*src;
        }
        
        CIImage *inputImage = [CIImage imageWithCVImageBuffer:_displayBuffer];
        
        NSRect imageRect = [inputImage extent];
        [_ciContext drawImage:inputImage inRect:NSMakeRect((_bounds.size.width - width) / 2, (_bounds.size.height - height) / 2, width, height) fromRect:imageRect];
        CVPixelBufferUnlockBaseAddress(_displayBuffer, 0);
    }else{
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT);
    }

    [self.openGLContext flushBuffer];
    [[self openGLContext] unlock];
}

@end
