//
//  MyMusicPlayer.m
//  MusicPlayer
//
//  Created by Xiangjian Meng on 15/7/1.
//  Copyright (c) 2015年 Boya. All rights reserved.
//

#import "MyMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MyMusicPlayer ()
{
    NSInteger currentIndex;
    NSArray *musicArray;
    BOOL started;
    id progressObserver;
    BOOL stopped;
}

@property (nonatomic, strong) AVQueuePlayer *player;

@end

@implementation MyMusicPlayer

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];\
    if (self)
    {
        [self initSession];
        
        _player = [[AVQueuePlayer alloc] init];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
        
        currentIndex = 0; //默认从第一首曲子播放
        
        started = NO; // 默认不自动播放，第一次调用播放方法播放。
        stopped = NO; // 是否为停止状态
    }
    return self;
}

- (void)initSession
{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(audioSessionInterrupted:)
                                                 name:        AVAudioSessionInterruptionNotification
                                               object:      [AVAudioSession sharedInstance]];
    
    
    //set audio category with options - for this demo we'll do playback only
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&categoryError];
    
    if (categoryError) {
        NSLog(@"Error setting category! %@", [categoryError description]);
    }
    
    //activation of audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
        } else {
            NSLog(@"audio session could not be activated!");
        }
    }
    
}


- (void)audioSessionInterrupted:(id)sender
{
    // 音频被打断
    
}

- (void)playerItemDidReachEnd:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    // 播放完毕了。默认播放下一首。
    [self next];
}

- (void)playMusicWithMusics:(NSArray *)musics index:(NSInteger)index;
{
    [self clear];
    
    musicArray = musics;
    currentIndex = index;
    
    [self play];
}

#pragma mark - 播放控制
-(void) pause
{
    [_player pause];
}

-(void) play
{
    if (!started)
    {
        started = YES;
        
        if ([musicArray count] > 0 && currentIndex < [musicArray count])
        {
            [self playMusicAtIndex:currentIndex];
        }
    }
    else if (stopped)
    {
        stopped = NO;
        [self changeCurrentMusicToMusicWithIndex:currentIndex];
    }
    
    [_player play];
}

-(void) clear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    started = NO;
    stopped = NO;
    currentIndex = 0;
    [_player removeAllItems];
    
    if (progressObserver)
    {
        [_player removeTimeObserver:progressObserver];
    }
}

- (void)previous
{
    currentIndex --;
    [self playMusicAtIndex:currentIndex];
}

- (void)next
{
    currentIndex ++;
    [self playMusicAtIndex:currentIndex];
}

- (void)stop
{
    stopped = YES;
    [_player removeAllItems];
}

- (void)changeCurrentMusicToMusicWithIndex:(NSInteger)index
{
    if (index >= 0 && index < [musicArray count])
    {
        [self playMusicAtIndex:index];
    }
}

-(void) remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if (_player.rate > 0.0) {
                    [_player pause];
                } else {
                    [_player play];
                }
                
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [self play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [self pause];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self next];
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self previous];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark 播放某首音乐
- (void)playMusicAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [musicArray count])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:nil];
        
        MusicModel *music = musicArray[index];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:music.url]];
        if (item)
        {
//            [_player replaceCurrentItemWithPlayerItem:item];
            [_player removeAllItems];
            [_player insertItem:item afterItem:nil];
            
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle: music.name, MPMediaItemPropertyArtist: music.singer};
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[_player currentItem]];
            
            if (progressObserver)
            {
                [_player removeTimeObserver:progressObserver];
            }
            
            __weak AVQueuePlayer *player = _player;
            __weak typeof(self) weakSelf = self;
            progressObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time)
            {
                AVPlayerItem *item = [player currentItem];
                CGFloat currentTime = CMTimeGetSeconds(time);
                CGFloat duration = CMTimeGetSeconds(item.duration);
                NSLog(@"progress : %.2f",currentTime/duration);
                
                if ([weakSelf.delegate respondsToSelector:@selector(musicPlayerIsPlayingWithProgress:)])
                {
                    [weakSelf.delegate musicPlayerIsPlayingWithProgress:(currentTime/duration)];
                }
                if ([weakSelf.delegate respondsToSelector:@selector(musicPlayerIsPlayingAtSecond:)])
                {
                    [weakSelf.delegate musicPlayerIsPlayingAtSecond:currentTime];
                }
            }];
            
            
            [self play];
            
            if ([self.delegate respondsToSelector:@selector(musicPlayerIsPlayingMusicAtIndex:)])
            {
                [self.delegate musicPlayerIsPlayingMusicAtIndex:index];
            }
        }
    }
    else if (index < 0)
    {
        currentIndex = 0;
        [self playMusicAtIndex:currentIndex];
    }
    else
    {
        [self clear];
    }
}

@end
