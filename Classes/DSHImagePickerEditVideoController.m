//
//  DSHImagePickerEditVideoController.m
//  IPicker
//
//  Created by 路 on 2020/5/14.
//  Copyright © 2020 路. All rights reserved.
//

#import "DSHImagePickerEditVideoController.h"
#import <Masonry.h>
#import "DSHImagePickerVideoPlayer.h"
#import "UIImage+DSHImagePicker.h"
#import "DSHImagePicker.h"
#import "DSHImagePickerEditVideoTimeRangeView.h"

@interface DSHImagePickerEditVideoController () <DSHImagePickerVideoPlayerDelegate>

@property (strong ,nonatomic) AVAsset *asset;
@property (strong ,nonatomic) UIView *topBar;
@property (strong ,nonatomic) UIView *bottomBar;
@property (strong ,nonatomic) DSHImagePickerEditVideoTimeRangeView *timeRangeView;
@property (strong ,nonatomic) DSHImagePickerVideoPlayer *videoPlayer;
@property (strong ,nonatomic) UIButton *playButton;
@property (assign ,nonatomic) NSTimeInterval videoSeconds;
@end

@implementation DSHImagePickerEditVideoController

- (id)initWithAVAsset:(AVAsset *)asset; {
    self = [super init];
    if (self) {
        _asset = asset;
        _videoMinimumDuration = 10.f;
        _videoMaximumDuration = 60.f;
        _videoSeconds = CMTimeGetSeconds(_asset.duration); // 视频总长度
    } return self;
}

- (void)viewDidLoad; {
    [super viewDidLoad];
    __weak typeof(self) _self = self;
    
    if ([self.navigationController isKindOfClass:[DSHImagePicker class]]) {
        _videoMinimumDuration = [(DSHImagePicker *)self.navigationController videoMinimumDuration];
        _videoMaximumDuration = [(DSHImagePicker *)self.navigationController videoMaximumDuration];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    UIColor *textColor = [UIColor colorWithRed:153 / 255.f green:153 / 255.f blue:153 / 255.f alpha:1];
    // 创建顶部导航条
    _topBar = [[UIView alloc] init];
    [self.view addSubview:_topBar]; {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage dsh_X] forState:0];
        [closeButton addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:closeButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = textColor;
        titleLabel.text = @"编辑视频";
        [_topBar addSubview:titleLabel];
        
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downButton setTitle:@"完成" forState:0];
        [downButton setTitleColor:[UIColor colorWithRed:255 / 255.f green:40 / 255.f blue:103 / 255.f alpha:1] forState:0];
        downButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [downButton addTarget:self action:@selector(clickedDownButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:downButton];
        
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topBar);
            make.left.equalTo(self.topBar).offset(20.f);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topBar);
        }];
        
        [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topBar);
            make.right.equalTo(self.topBar).offset(-20.f);
        }];
    }
    
    // 创建底部编辑条
    _bottomBar = [[UIView alloc] init];
    [self.view addSubview:_bottomBar]; {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = textColor;
        titleLabel.text = @"选取视频段落";
        [_bottomBar addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomBar).offset(20.f);
            make.top.equalTo(self.bottomBar);
            make.height.equalTo(@(17.f));
        }];
        
        _timeRangeView = [[DSHImagePickerEditVideoTimeRangeView alloc] init];
        [_bottomBar addSubview:_timeRangeView];
        [_timeRangeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.bottomBar);
            make.top.equalTo(titleLabel.mas_bottom).offset(17.f);
            make.bottom.equalTo(self.bottomBar);
            make.height.equalTo(@(70.f));
        }];
        [_timeRangeView setRangeDidChangeBlock:^(CGFloat start, CGFloat width) {
            _self.videoPlayer.start = _self.videoSeconds * start;
            _self.videoPlayer.duration = _self.videoSeconds * width;
        }];
    }
    
    // 创建视频播放器
    _videoPlayer = [[DSHImagePickerVideoPlayer alloc] init];
    _videoPlayer.asset = _asset;
    _videoPlayer.delegate = self;
    [self.view addSubview:_videoPlayer];
    
    // 创建播放按钮
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage dsh_playImage] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage dsh_pauseImage] forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(clickedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([UIApplication sharedApplication].statusBarFrame.size.height);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.f));
    }];
    [_videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topBar.mas_bottom).offset(2.f);
    }];
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoPlayer.mas_bottom).offset(12.f);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-10.f);
    }];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.videoPlayer);
    }];
    
    // 拆分视频帧
    NSInteger totalFrames = 10; // 一共分出多少张图片
    CGFloat timeSpacing = _videoSeconds / (totalFrames - 1);
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:totalFrames];
    for (int i = 0; i < totalFrames; i ++) {
        NSTimeInterval frameSeconds = i * timeSpacing;
        CMTime time = CMTimeMake(frameSeconds, 1);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    NSMutableArray <UIImage *>*frameImages = [NSMutableArray arrayWithCapacity:totalFrames];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    __block NSInteger count = 0;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            [frameImages addObject:[UIImage imageWithCGImage:image]];
        }
        count ++;
        if (count >= totalFrames) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.timeRangeView setBackgroundImages:frameImages];
                [_self VIDEO_DID_LOAD];
            });
        }
    }];
}

- (void)VIDEO_DID_LOAD; {
    // 初始化裁剪框
    _timeRangeView.start = 0;
    _timeRangeView.maximumWidth = _videoMaximumDuration / _videoSeconds;
    _timeRangeView.minimumWidth = _videoMinimumDuration / _videoSeconds;
    _timeRangeView.width = MIN(_videoSeconds, _videoMaximumDuration) / _videoSeconds;
    [_timeRangeView set];
    
    CAKeyframeAnimation *opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.duration = .25;
    opacityAnim.values = @[@(0) ,@(1)];
    [_timeRangeView.layer addAnimation:opacityAnim forKey:nil];
}

- (void)viewWillAppear:(BOOL)animated; {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated; {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLayoutSubviews; {
    [super viewDidLayoutSubviews];
}

#pragma mark -
- (void)clickedCloseButton:(UIButton *)sender; {
    if (_clickedCloseButtonBlock) {
        _clickedCloseButtonBlock();
    }
}
- (void)clickedDownButton:(UIButton *)sender; {
    __weak typeof(self) _self = self;
    [_videoPlayer.player pause];
    [DSHImagePickerHUD showMessage:@"正在导出视频..."];
    NSInteger timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4" ,@(timeStamp)];
    NSString *output = [NSString stringWithFormat:@"%@/%@" ,NSTemporaryDirectory() ,fileName];
    NSURL *outputURL = [NSURL fileURLWithPath:output];
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(_videoPlayer.start, 1), CMTimeMake(_videoPlayer.duration, 1));
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:_asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.timeRange = timeRange;
    exportSession.outputURL = [NSURL fileURLWithPath:output];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.videoComposition = [self videoComposition:_asset];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [DSHImagePickerHUD hide];
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                if (_self.exportCompletedBlock) {
                    _self.exportCompletedBlock(outputURL);
                }
            } else {
                NSLog(@"导出视频失败");
            }
        });
    }];
}
- (void)clickedPlayButton:(UIButton *)sender; {
    BOOL isPlaying = _playButton.selected;
    if (isPlaying) {
        [_videoPlayer.player pause];
    } else {
        [_videoPlayer.player play];
    }
}

#pragma mark -
// 开始播放
- (void)imagePickerVideoPlayerDidStart:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer; {
    _playButton.selected = YES;
}
// 暂停播放
- (void)imagePickerVideoPlayerDidPause:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer; {
    _playButton.selected = NO;
}
// 播放结束
- (void)imagePickerVideoPlayerDidPlayToEndTime:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer; {
    _playButton.selected = NO;
}
// 播放进度
- (void)imagePickerVideoPlayer:(DSHImagePickerVideoPlayer *)imagePickerVideoPlayer videoPlayProgress:(CGFloat)progress; {
    [_timeRangeView setProgress:progress];
}

#pragma mark - 处理视频方向
// @https://www.jianshu.com/p/4a6149c6087e
- (NSUInteger)degressFromAsset:(AVAsset *)asset {
    NSUInteger degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
       if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
   }
   return degress;
}
- (AVMutableVideoComposition *)videoComposition:(AVAsset *)asset {
    NSInteger trackDegress = [self degressFromAsset:asset];
    
    NSLog(@"trackDegress: %@" ,@(trackDegress));
    
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGSize videoSize = videoTrack.naturalSize;
     
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if((t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) ||
           (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)){
            videoSize = CGSizeMake(videoSize.height, videoSize.width);
        }
    }
    composition.naturalSize = videoSize;
    videoComposition.renderSize = videoSize;
    videoComposition.frameDuration = CMTimeMakeWithSeconds( 1 / videoTrack.nominalFrameRate, 600);
    
    AVMutableCompositionTrack *compositionVideoTrack;
    compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    AVMutableVideoCompositionLayerInstruction *layerInst;
    layerInst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInst setTransform:[self transformFromDegress:trackDegress natureSize:videoTrack.naturalSize] atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *inst = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    inst.layerInstructions = [NSArray arrayWithObject:layerInst];
    videoComposition.instructions = [NSArray arrayWithObject:inst];
    return videoComposition;
}
- (CGAffineTransform)transformFromDegress:(float)degress natureSize:(CGSize)natureSize {
    // x = ax1 + cy1 + tx,y = bx1 + dy2 + ty
    if (degress == 90) {
        return CGAffineTransformMake(0, 1, -1, 0, natureSize.height, 0);
    } else if (degress == 180) {
        return CGAffineTransformMake(-1, 0, 0, -1, natureSize.width , natureSize .height);
    } else if (degress == 270) {
        return CGAffineTransformMake(0, -1, 1, 0, -natureSize.height, 2 * natureSize.width);
    } else {
        return CGAffineTransformIdentity;
    }
}
@end


#pragma mark -
@interface DSHImagePickerVideoCoverController () <UICollectionViewDelegateFlowLayout ,UICollectionViewDataSource>

@property (strong ,nonatomic) AVAsset *asset;
@property (strong ,nonatomic) UIView *topBar;
@property (strong ,nonatomic) UIView *bottomBar;
@property (strong ,nonatomic) UIImageView *imageView;

@property (strong ,nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong ,nonatomic) UICollectionView *collectionView;
@property (strong ,nonatomic) NSMutableDictionary <NSNumber *,UIImage *>*images; // 视频帧缓存 (key是时间(秒),value是时间对应的图片)
@property (assign ,nonatomic) NSInteger seconds; // 视频一共多少秒
@property (assign ,nonatomic) NSInteger selectSecond; // 选中的封面
@end

@implementation DSHImagePickerVideoCoverController {
    BOOL _navigation_bar_hidden;
}

- (id)initWithVideoURL:(NSURL *)videoURL; {
    self = [super init];
    if (self) {
        _images = [NSMutableDictionary dictionary];
        _videoURL = videoURL;
        _asset = [AVAsset assetWithURL:videoURL];
        _seconds = CMTimeGetSeconds(_asset.duration);
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    } return self;
}

- (void)viewDidLoad; {
    self.view.backgroundColor = [UIColor blackColor];
    UIColor *textColor = [UIColor colorWithRed:153 / 255.f green:153 / 255.f blue:153 / 255.f alpha:1];
    // 创建顶部导航条
    _topBar = [[UIView alloc] init];
    [self.view addSubview:_topBar]; {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage dsh_X] forState:0];
        [closeButton addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:closeButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = textColor;
        titleLabel.text = @"选封面";
        [_topBar addSubview:titleLabel];
        
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downButton setTitle:@"完成" forState:0];
        [downButton setTitleColor:[UIColor colorWithRed:255 / 255.f green:40 / 255.f blue:103 / 255.f alpha:1] forState:0];
        downButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [downButton addTarget:self action:@selector(clickedDownButton:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:downButton];
        
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topBar);
            make.left.equalTo(self.topBar).offset(20.f);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topBar);
        }];
        
        [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topBar);
            make.right.equalTo(self.topBar).offset(-20.f);
        }];
    }
    
    _imageView = [[UIImageView alloc] initWithImage:nil];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    // 创建底部编辑条
    _bottomBar = [[UIView alloc] init];
    [self.view addSubview:_bottomBar]; {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = textColor;
        titleLabel.text = @"已选封面";
        [_bottomBar addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomBar).offset(20.f);
            make.top.equalTo(self.bottomBar);
            make.height.equalTo(@(20.f));
        }];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        [_bottomBar addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.bottomBar);
            make.height.equalTo(@(70.f));
        }];
    }
    
    [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([UIApplication sharedApplication].statusBarFrame.size.height);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.f));
    }];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-10.f);
        make.height.equalTo(@(107));
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom).offset(10.f);
        make.left.equalTo(self.view).offset(10.f);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.bottomBar.mas_top).offset(-10.f);
    }];
    
    __weak typeof(self) _self = self;
    [self imageWithSecond:_selectSecond completBlock:^(UIImage *image, BOOL fromCache) {
        _self.imageView.image = image;
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        anim.values = @[@(0) ,@(1)];
        anim.duration = .25;
        [_self.imageView.layer addAnimation:anim forKey:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated; {
    [super viewWillAppear:animated];
    _navigation_bar_hidden = self.navigationController.navigationBarHidden;
    if (!_navigation_bar_hidden) {
        self.navigationController.navigationBarHidden = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated; {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:_navigation_bar_hidden animated:YES];
}

#pragma mark -
- (void)clickedCloseButton:(UIButton *)sender; {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickedDownButton:(UIButton *)sender; {
    if (_clickedDownButtonBlock) {
        _clickedDownButtonBlock(_imageView.image ,_videoURL ,_selectSecond);
    }
}
#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return _seconds;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    UIImageView *imageView = [cell viewWithTag:98];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.tag = 98;
        [cell addSubview:imageView];
    }
    imageView.frame = cell.bounds;
    NSInteger second = indexPath.row;
    [self imageWithSecond:second completBlock:^(UIImage *image, BOOL fromCache) {
        imageView.image = image;
        if (!fromCache) {
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            anim.values = @[@(0) ,@(1)];
            anim.duration = .25;
            [imageView.layer addAnimation:anim forKey:nil];
        }
    }];
    if (second == _selectSecond) {
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.layer.borderWidth = 2.f;
    } else {
        cell.layer.borderWidth = 0.f;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; {
    _selectSecond = indexPath.row;
    [collectionView reloadData];
    __weak typeof(self) _self = self;
    [self imageWithSecond:_selectSecond completBlock:^(UIImage *image, BOOL fromCache) {
        _self.imageView.image = image;
    }];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    return CGSizeMake(47.f, collectionView.frame.size.height);
}
- (void)imageWithSecond:(NSInteger)second completBlock:(void(^)(UIImage *image ,BOOL fromCache))completBlock; {
    if (!completBlock) {
        return;
    }
    NSNumber *key = @(second);
    UIImage *image = _images[key];
    if (image) {
        completBlock(image ,YES);
        return;
    }
    
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CMTime time = CMTimeMake(second, 1);
        NSError *error;
        CGImageRef imageRef = [_self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
        UIImage *result = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        if (!error && result) {
            self.images[key] = result;
        } else {
            NSLog(@"%@ %@" ,error ,result);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completBlock(result ,NO);
        });
    });
}
@end
