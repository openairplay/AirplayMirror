//
//  ViewController.m
//  PlayTest
//
//  Created by hc on 2017/12/29.
//  Copyright © 2017年 hc. All rights reserved.
//

#import "ViewController.h"
#import "VideoDecoder.h"
#import "airplay_mirror.h"

@interface ViewController ()

@property (weak) IBOutlet PlayerView* playerView;
@property (strong) VideoDecoder* videoDecoder;

- (void)displayFrame:(CVPixelBufferRef)pixelBuffer;

@end


void airplay_data_receive(unsigned char* buffer, long buflen, int payload,void* ref){
    
    @autoreleasepool{
        ViewController* vc = (__bridge ViewController*)ref;
        if (payload == 1){
            //sps
            long sps_size = buffer[6] << 8 | buffer[7];
            NSMutableData* sps = [NSMutableData dataWithCapacity:sps_size];
            [sps appendBytes:&buffer[8] length:sps_size];
            
            //pps
            long pps_size = buffer[9+sps_size] << 8 | buffer[10+sps_size];
            NSMutableData* pps = [NSMutableData dataWithCapacity:pps_size];
            [pps appendBytes:&buffer[11+sps_size] length:pps_size];
            
            if (vc.videoDecoder == nil)
                vc.videoDecoder = [VideoDecoder new];
            
            [vc.videoDecoder setupWithSPS:sps pps:pps];
            
            __weak typeof(vc) weakVC = vc;
            vc.videoDecoder.newFrameAvailable = ^(CVPixelBufferRef pixelBuffer) {
                if (pixelBuffer)
                    [weakVC displayFrame:pixelBuffer];
            } ;
        }else{
            [vc.videoDecoder decodeFrame:buffer bufferLen:buflen];
        }
    }
}


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)startOrStop:(id)sender{
    NSButton* button = (NSButton*)sender;
    if (button.tag == 0){
        button.tag = 1;
        [button setTitle:@"Stop"];
        mirror_context context;
        context.video_data_receive = airplay_data_receive;
        context.audio_data_receive = 0;
        context.airplay_did_stop = 0;
        strcpy(context.name, "AirPlay");
        context.width = 1280;
        context.height = 720;
        context.ref = (__bridge void*)self;
        
        start_mirror(&context);
    }else{
        button.tag = 0;
        [button setTitle:@"Start"];
        stop_mirror();
    }
}

- (void)displayFrame:(CVPixelBufferRef)pixelBuffer{
    [_playerView display:pixelBuffer];
}
@end
