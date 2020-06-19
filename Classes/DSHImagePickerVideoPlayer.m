//
//  DSHImagePickerVideoPlayer.m
//  IPicker
//
//  Created by 路 on 2020/5/15.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerVideoPlayer.h"

@interface DSHImagePickerVideoPlayer ()

@property (strong ,nonatomic) NSArray <NSString *>*playerObserverKeys;
@property (strong ,nonatomic) id timeObserver;

@property (assign ,nonatomic) BOOL isSeeking;
@property (assign ,nonatomic) CMTime startTime;
@end

@implementation DSHImagePickerVideoPlayer
+ (Class)layerClass; {
    return [AVPlayerLayer class];
}
- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _player = [[AVPlayer alloc] init];
        [(AVPlayerLayer *)self.layer setPlayer:_player];
        // 监听暂停/播放状态
        _playerObserverKeys = @[@"rate" ,@"currentItem"];
        for (NSString *key in _playerObserverKeys) {
            [_player addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
        }
        // 监听播放进度
        __weak typeof(self) _self = self;
        CMTime interval = CMTimeMakeWithSeconds(1.f / 20, NSEC_PER_SEC);
        _timeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            NSTimeInterval seconds = CMTimeGetSeconds(time);
            NSTimeInterval playedSeconds = (seconds - _self.start);
            CGFloat progress = (_self.duration > 0) ? (playedSeconds / _self.duration) : 0;
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;
            if ([_self.delegate respondsToSelector:@selector(imagePickerVideoPlayer:videoPlayProgress:)]) {
                [_self.delegate imagePickerVideoPlayer:_self videoPlayProgress:progress];
            }
            if (progress >= 1) {
                [_self _resetItem];
                if ([_self.delegate respondsToSelector:@selector(imagePickerVideoPlayerDidPlayToEndTime:)]) {
                    [_self.delegate imagePickerVideoPlayerDidPlayToEndTime:_self];
                }
            }
        }];
    } return self;
}
#pragma mark -
- (void)setAsset:(AVAsset *)asset; {
    _asset = asset;
    [self _resetItem];
}
- (void)setStart:(NSTimeInterval)start; {
    if (_start == start) return;
    _start = start;
    [self _resetItem];
}
- (void)setDuration:(NSTimeInterval)duration; {
    if (duration == _duration) return;
    _duration = duration;
}
#pragma mark -
- (void)_resetItem; {
    if (_player.currentItem.asset != _asset) {
        AVPlayerItem *newItem = [[AVPlayerItem alloc] initWithAsset:_asset];
        [_player replaceCurrentItemWithPlayerItem:newItem];
    }
    [_player pause];
    _startTime = CMTimeMake(_start, 1);
    [self _trySeekToStart];
}
- (void)_trySeekToStart; {
    if (!_isSeeking) {
        [self _seekToStart];
    }
}
- (void)_seekToStart; {
    if (_player.status != AVPlayerItemStatusReadyToPlay) {
        return;
    }
    _isSeeking = YES;
    __weak typeof(self) _self = self;
    CMTime time = _startTime;
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (CMTIME_COMPARE_INLINE(time, ==, _self.startTime)) {
            _self.isSeeking = NO;
        } else {
            [_self _seekToStart]; // 跳最新的
        }
    }];
}
#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context; {
    if (object == _player) {
        if ([keyPath isEqualToString:@"rate"]) {
            if (_player.rate == 0) {
                if ([_delegate respondsToSelector:@selector(imagePickerVideoPlayerDidPause:)]) {
                    [_delegate imagePickerVideoPlayerDidPause:self];
                }
            } else {
                if ([_delegate respondsToSelector:@selector(imagePickerVideoPlayerDidStart:)]) {
                    [_delegate imagePickerVideoPlayerDidStart:self];
                }
            }
        }
    }
}
- (void)dealloc; {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSString *key in _playerObserverKeys) {
        [_player removeObserver:self forKeyPath:key];
    }
    [_player removeTimeObserver:_timeObserver];
    _player = nil;
}
@end
