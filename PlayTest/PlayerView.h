//
//  PlayerView.h
//  PlayTest
//
//  Created by hc on 2018/1/11.
//  Copyright © 2018年 hc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>


@interface PlayerView : NSOpenGLView

- (void)display:(CVPixelBufferRef)sampleBuffer;

@end
