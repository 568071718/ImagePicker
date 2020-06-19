//
//  DSHPhotoThumbnailController.m
//  IPicker
//
//  Created by 路 on 2020/1/13.
//  Copyright © 2020年 路. All rights reserved.
//

#import "DSHImagePickerPhotosController.h"
#import "DSHImagePicker.h"
#import "DSHImagePickerPreviewController.h"
#import "DSHImagePickerImageManager.h"
#import "DSHImagePickerEditVideoController.h"
#import "DSHImagePickerEditImageController.h"
#import "UIImage+DSHImagePicker.h"

#import <Photos/Photos.h>

static const NSNotificationName _DSHImagePickerPhotosControllerCollectionPopupDidDismissNotification = @"_DSHImagePickerPhotosControllerCollectionPopupDidDismissNotification";

@interface _DSHImagePickerPhotosControllerTitleView : UIControl
@property (strong ,nonatomic ,readonly) UILabel *label;
@property (strong ,nonatomic ,readonly) UIImageView *imageView;
@end
@implementation _DSHImagePickerPhotosControllerTitleView
- (id)init; {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        
        UIColor *triangleColor = [UIColor darkGrayColor];
        CGRect rect = CGRectMake(0, 0, 10, 10);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, rect.size.width, 0);
        CGContextAddLineToPoint(context, rect.size.width * .5, rect.size.height);
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, triangleColor.CGColor);
        CGContextDrawPath(context, kCGPathFill);
        
        UIImage *triangleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _imageView = [[UIImageView alloc] initWithImage:triangleImage];
        [self addSubview:_imageView];
    } return self;
}
- (CGSize)intrinsicContentSize; {
    CGSize result = {0};
    result.height = 44.f;
    {[_label sizeToFit];CGRect frame = _label.frame;frame.size.height = result.height;_label.frame = frame;}
    {CGRect frame = _imageView.frame; frame.origin.x = CGRectGetMaxX(_label.frame) + 3.f; frame.origin.y = (result.height - frame.size.height) * .5; _imageView.frame = frame;};
    result.width = CGRectGetMaxX(_imageView.frame);
    return result;
}
@end

@interface _DSHImagePickerPhotosControllerCollectionPopup : UIViewController <UIPopoverPresentationControllerDelegate ,UITableViewDelegate ,UITableViewDataSource>
@property (strong ,nonatomic ,readonly) UITableView *tableView;
@property (weak ,nonatomic ,readonly) NSMutableArray <PHAssetCollection *>*assetCollections;
@property (weak ,nonatomic ,readonly) PHAssetCollection *currentAssetCollection;
@property (strong ,nonatomic) void(^choosePHAssetCollection)(PHAssetCollection *assetCollection);
@end
@implementation _DSHImagePickerPhotosControllerCollectionPopup
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (id)initWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect assetCollections:(NSMutableArray *)assetCollections currentAssetCollection:(PHAssetCollection *)currentAssetCollection; {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
        self.popoverPresentationController.delegate = self;
        self.popoverPresentationController.canOverlapSourceViewRect = NO;
        self.popoverPresentationController.sourceRect = sourceRect;
        self.popoverPresentationController.sourceView = sourceView;
        _assetCollections = assetCollections;
        _currentAssetCollection = currentAssetCollection;
        CGSize preferredContentSize = {0};
        for (PHAssetCollection *object in _assetCollections) {
            NSString *localizedTitle = [NSString stringWithFormat:@"%@" ,object.localizedTitle];
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:localizedTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
            preferredContentSize.width = MAX(preferredContentSize.width, string.size.width);
        }
        preferredContentSize.width += 40.f;
        preferredContentSize.height = MIN(assetCollections.count * 45, 300);
        self.preferredContentSize = preferredContentSize;
    } return self;
}
- (void)viewDidLoad; {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.rowHeight = 44.f;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}
- (void)viewWillLayoutSubviews; {
    [super viewWillLayoutSubviews];
    if (_assetCollections.count > 0 && [_assetCollections containsObject:_currentAssetCollection]) {
        NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:[_assetCollections indexOfObject:_currentAssetCollection] inSection:0];
        [_tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}
#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _assetCollections.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"test_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    PHAssetCollection *rowData = _assetCollections[indexPath.row];
    cell.textLabel.text = rowData.localizedTitle;
    if (rowData == _currentAssetCollection) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_choosePHAssetCollection) {
        _choosePHAssetCollection(_assetCollections[indexPath.row]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
- (void)viewWillDisappear:(BOOL)animated; {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:_DSHImagePickerPhotosControllerCollectionPopupDidDismissNotification object:nil];
}
@end

@interface _DSHImagePickerPhotosControllerCell : UICollectionViewCell
@property (strong ,nonatomic ,readonly) UIImageView *imageView;
@property (strong ,nonatomic ,readonly) UILabel *timeLabel;
@property (strong ,nonatomic ,readonly) UIButton *selectButton;
@property (strong ,nonatomic) dispatch_block_t selectButtonActionBlock;
@end
@implementation _DSHImagePickerPhotosControllerCell
- (id)initWithFrame:(CGRect)frame; {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
        
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton addTarget:self action:@selector(clickActions:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectButton];
    } return self;
}
- (void)layoutSubviews; {
    [super layoutSubviews];
    {
        CGRect frame = _timeLabel.frame;
        frame.origin.x = 0.f;
        frame.size.width = self.frame.size.width - 5.f;
        frame.size.height = 17.f;
        frame.origin.y = self.frame.size.height - frame.size.height - 5.f;
        _timeLabel.frame = frame;
    }
    {
        CGRect frame = _selectButton.frame;
        frame.size = CGSizeMake(33, 33);
        frame.origin.y = 0.f;
        frame.origin.x = self.frame.size.width - frame.size.width;
        _selectButton.frame = frame;
    }
}
#pragma mark - action
- (IBAction)clickActions:(UIView *)sender {
    if (_selectButtonActionBlock) {
        _selectButtonActionBlock();
    }
}
@end

@interface DSHImagePickerPhotosController ()

@property (strong ,nonatomic ,readonly) DSHImagePickerImageManager *imageManager;
@property (strong ,nonatomic ,readonly) UICollectionView *collectionView;
@property (strong ,nonatomic ,readonly) NSMutableArray <PHAsset *>*listData;
@property (strong ,nonatomic ,readonly) NSMutableArray <PHAssetCollection *>*assetCollections;
@property (weak ,nonatomic ,readonly) PHAssetCollection *currentAssetCollection;
@property (readonly) DSHImagePicker *imagePicker;

@property (strong ,nonatomic ,readonly) UIBarButtonItem *previewButtonItem;
@end

@implementation DSHImagePickerPhotosController
- (DSHImagePicker *)imagePicker; {
    DSHImagePicker *result = (DSHImagePicker *)self.navigationController;
    if ([result isKindOfClass:[DSHImagePicker class]]) {
        return result;
    }
    return nil;
}

#pragma mark - controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonItemAction:)];
    if (self.imagePicker.mode == DSHImagePickerModeMultipleImage) {
        [self.navigationController setToolbarHidden:NO animated:NO];
        _previewButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(clickedPreviewButton:)];
        UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *downButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickedDownItem)];
        [self setToolbarItems:@[_previewButtonItem ,spacing ,downButton]];
    }
    
    _imageManager = [[DSHImagePickerImageManager alloc] init];
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize targetSize = CGSizeZero;
    targetSize.width = mainScreen.bounds.size.width / self.imagePicker.column * mainScreen.scale;
    targetSize.height = targetSize.width;
    _imageManager.targetSize = targetSize;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = self.imagePicker.minimumLineSpacing;
    layout.minimumInteritemSpacing = self.imagePicker.minimumInteritemSpacing;
    layout.sectionInset = self.imagePicker.sectionInset;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_collectionView registerClass:[_DSHImagePickerPhotosControllerCell class] forCellWithReuseIdentifier:@"_DSHImagePickerPhotosControllerCell"];
    [self.view addSubview:_collectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionPopupDidDismissNotification:) name:_DSHImagePickerPhotosControllerCollectionPopupDidDismissNotification object:nil];
    
    /**
     PHAssetCollectionTypeAlbum -------
     PHAssetCollectionSubtypeAlbumRegular: An album created in the Photos app. (自定义相册)
     PHAssetCollectionSubtypeAlbumSyncedEvent: An Event synced to the device from iPhoto.
     PHAssetCollectionSubtypeAlbumSyncedFaces: A Faces group synced to the device from iPhoto.
     PHAssetCollectionSubtypeAlbumSyncedAlbum: An album synced to the device from iPhoto.
     PHAssetCollectionSubtypeAlbumImported: An album imported from a camera or external storage.
     PHAssetCollectionSubtypeAlbumMyPhotoStream: The user’s personal iCloud Photo Stream.
     PHAssetCollectionSubtypeAlbumCloudShared: An iCloud Shared Photo Stream.
     
     PHAssetCollectionTypeSmartAlbum -------
     PHAssetCollectionSubtypeSmartAlbumGeneric: This subtype applies to smart albums synced to the iOS device from the macOS Photos app.
     PHAssetCollectionSubtypeSmartAlbumPanoramas: 全景照片
     PHAssetCollectionSubtypeSmartAlbumVideos: 视频
     PHAssetCollectionSubtypeSmartAlbumFavorites: 个人收藏
     PHAssetCollectionSubtypeSmartAlbumTimelapses: 延时摄影
     PHAssetCollectionSubtypeSmartAlbumAllHidden: 已隐藏
     PHAssetCollectionSubtypeSmartAlbumRecentlyAdded: 最近添加
     PHAssetCollectionSubtypeSmartAlbumBursts: 连拍快照
     PHAssetCollectionSubtypeSmartAlbumSlomoVideos: 慢动作
     PHAssetCollectionSubtypeSmartAlbumUserLibrary: 相机胶卷
     PHAssetCollectionSubtypeSmartAlbumSelfPortraits: 自拍
     PHAssetCollectionSubtypeSmartAlbumScreenshots: 屏幕快照
     PHAssetCollectionSubtypeSmartAlbumDepthEffect: 人像 (10.2)
     PHAssetCollectionSubtypeSmartAlbumLivePhotos: 实况照片 (10.3)
     PHAssetCollectionSubtypeSmartAlbumAnimated: 动图 (11.0)
     PHAssetCollectionSubtypeSmartAlbumLongExposures: 长曝光 (11.0)
     */
    
    [self addAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary];
    [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots];
    if (@available(iOS 10.3, *)) {
        [self addAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumLivePhotos];
    }
    [self reloadAssetCollection:_assetCollections.firstObject];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self selectItemsDidChange];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_listData.count > 0) {
        NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:_listData.count - 1 inSection:0];
        [_collectionView scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action
- (void)leftBarButtonItemAction:(UIBarButtonItem *)sender {
    [self.imagePicker cancel];
}
- (void)showAssetCollections; {
    _DSHImagePickerPhotosControllerTitleView *titleView = (_DSHImagePickerPhotosControllerTitleView *)self.navigationItem.titleView;
    if ([titleView isKindOfClass:[_DSHImagePickerPhotosControllerTitleView class]]) {
        titleView.imageView.transform = CGAffineTransformMakeScale(1, -1);
    }
    __weak typeof(self) _self = self;
    _DSHImagePickerPhotosControllerCollectionPopup *vc = [[_DSHImagePickerPhotosControllerCollectionPopup alloc] initWithSourceView:self.navigationItem.titleView sourceRect:self.navigationItem.titleView.bounds assetCollections:_assetCollections currentAssetCollection:_currentAssetCollection];
    [self presentViewController:vc animated:YES completion:nil];
    [vc setChoosePHAssetCollection:^(PHAssetCollection *assetCollection) {
        [_self reloadAssetCollection:assetCollection];
    }];
}
- (void)collectionPopupDidDismissNotification:(NSNotification *)noti; {
    _DSHImagePickerPhotosControllerTitleView *titleView = (_DSHImagePickerPhotosControllerTitleView *)self.navigationItem.titleView;
    if ([titleView isKindOfClass:[_DSHImagePickerPhotosControllerTitleView class]]) {
        titleView.imageView.transform = CGAffineTransformMakeScale(1, 1);
    }
}

#pragma mark -
- (void)addAssetCollectionsWithType:(PHAssetCollectionType)type subtype:(PHAssetCollectionSubtype)subtype; {
    if (!_assetCollections) {
        _assetCollections = [NSMutableArray array];
    }
    BOOL showEmptyFolder = YES ,useEstimatedAssetCount = YES;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subtype options:nil];
    for (int i = 0; i < result.count; i ++) {
        PHAssetCollection *object = result[i];
        BOOL addObject = showEmptyFolder ?: ({
            BOOL ir = NO;
            if (useEstimatedAssetCount && object.estimatedAssetCount != NSNotFound) {
                ir = (object.estimatedAssetCount > 0); // ???
            } else {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
                options.fetchLimit = 1;
                ir = ([PHAsset fetchAssetsInAssetCollection:object options:options].count > 0);
            }
            ir;
        });
        if (addObject) {
            if (object.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [_assetCollections insertObject:object atIndex:0]; // 相机胶卷放第一位
            } else {
                [_assetCollections addObject:object];
            }
        }
    }
}
- (void)reloadAssetCollection:(PHAssetCollection *)assetCollection; {
    if (_currentAssetCollection == assetCollection) {
        return;
    }
    _currentAssetCollection = assetCollection;
    _DSHImagePickerPhotosControllerTitleView *titleView = (_DSHImagePickerPhotosControllerTitleView *)self.navigationItem.titleView;
    if (![titleView isKindOfClass:[_DSHImagePickerPhotosControllerTitleView class]]) {
        titleView = [[_DSHImagePickerPhotosControllerTitleView alloc] init];
        [titleView addTarget:self action:@selector(showAssetCollections) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleView;
    }
    titleView.label.text = assetCollection.localizedTitle;
    [titleView invalidateIntrinsicContentSize];
    
    if (!_listData) {
        _listData = [NSMutableArray array];
    }
    [_listData removeAllObjects];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    PHFetchResult *listData = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    for (PHAsset *asset in listData) {
        if (self.imagePicker.mode == DSHImagePickerModeVideo) {
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                [_listData addObject:asset];
            }
        } else {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [_listData addObject:asset];
            }
        }
    }
    [_imageManager cachingAssets:_listData];
    [_collectionView reloadData];
    if (_listData.count > 0) {
        NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:_listData.count - 1 inSection:0];
        [_collectionView scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return _listData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    __weak typeof(self) _self = self;
    _DSHImagePickerPhotosControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"_DSHImagePickerPhotosControllerCell" forIndexPath:indexPath];
    cell.selectButton.hidden = YES;
    PHAsset *rowData = _listData[indexPath.row];
    [_imageManager imageFromAsset:rowData resultBlock:^(UIImage * _Nonnull resultImage) {
        cell.imageView.image = resultImage;
    }];
    if (self.imagePicker.mode == DSHImagePickerModeVideo) {
        // 获取视频时长
        NSTimeInterval duration = rowData.duration;
        int mm = (int)duration / 60;
        int ss = (int)duration % 60;
        NSString *timeString = [NSString stringWithFormat:@"%02d:%02d" ,mm ,ss];
        cell.timeLabel.text = timeString;
        cell.layer.cornerRadius = 4.f;
        cell.layer.masksToBounds = YES;
    }
    if (self.imagePicker.mode == DSHImagePickerModeMultipleImage) {
        cell.selectButton.hidden = NO;
        cell.selectButton.userInteractionEnabled = NO; // 点击事件关掉，去 didSelectItem 方法统一处理
        // 检查是否选中
        BOOL selected = [self.imagePicker isSelect:rowData];
        UIImage *image = selected ? [UIImage dsh_ring_full] : [UIImage dsh_ring];
        [cell.selectButton setImage:image forState:0];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat width = (collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing * (self.imagePicker.column - 1)) / self.imagePicker.column;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath; {
    __weak typeof(self) _self = self;
    PHAsset *rowData = _listData[indexPath.row];
    if (self.imagePicker.mode == DSHImagePickerModeSquare) {
        [DSHImagePickerHUD show];
        [DSHImagePickerImageManager requestImageDataWithPHAsset:rowData progressBlock:nil successBlock:^(NSData * _Nonnull imageData) {
            [DSHImagePickerHUD hide];
            DSHImagePickerEditImageController *vc = [[DSHImagePickerEditImageController alloc] initWithImage:[UIImage imageWithData:imageData]];
            [vc setClickedCancelButtonBlock:^{
                [_self.navigationController popViewControllerAnimated:YES];
            }];
            [vc setClickedDownButtonBlock:^(UIImage * _Nonnull image) {
                DSHPhotoResult *result = [[DSHPhotoResult alloc] init];
                result.asset = rowData;
                result.image = image;
                [_self.imagePicker completImages:@[result]];
            }];
            [_self.navigationController pushViewController:vc animated:YES];
        } failureBlock:^(NSError * _Nonnull error) {
            [DSHImagePickerHUD hide];
            NSString *reason = error.userInfo[NSLocalizedDescriptionKey]?:@"未知错误";
            [_self.imagePicker show_error_alert:reason];
        }];
    } else if (self.imagePicker.mode == DSHImagePickerModeImage) {
        [self.imagePicker.selectPhotos removeAllObjects];
        [DSHImagePickerHUD show];
        [self.imagePicker addAsset:rowData complet:^{
            [DSHImagePickerHUD hide];
            DSHImagePickerPreviewController *vc = [[DSHImagePickerPreviewController alloc] init];
            [_self.navigationController pushViewController:vc animated:YES];
        }];
    } else if (self.imagePicker.mode == DSHImagePickerModeVideo) {
        if (rowData.duration < self.imagePicker.videoMinimumDuration) {
            NSString *reason = [NSString stringWithFormat:@"请选择不小于%@秒的视频" ,@(self.imagePicker.videoMinimumDuration)];
            [_self.imagePicker show_error_alert:reason];
        } else {
            [DSHImagePickerHUD show];
            [DSHImagePickerImageManager requestAVAssetWithPHAsset:rowData progressBlock:nil successBlock:^(AVAsset * _Nonnull asset) {
                [DSHImagePickerHUD hide];
                DSHImagePickerEditVideoController *vc = [[DSHImagePickerEditVideoController alloc] initWithAVAsset:asset];
                [vc setClickedCloseButtonBlock:^{
                    [_self.navigationController popViewControllerAnimated:YES];
                }];
                [vc setExportCompletedBlock:^(NSURL * _Nonnull outputFileURL) {
                    if (_self.imagePicker.customVideoCoverSupported) {
                        // 去选封面
                        DSHImagePickerVideoCoverController *cover_vc = [[DSHImagePickerVideoCoverController alloc] initWithVideoURL:outputFileURL];
                        [cover_vc setClickedDownButtonBlock:^(UIImage * _Nonnull image, NSURL * _Nonnull fileURL, NSInteger imageTime) {
                            DSHVideoResult *result = [[DSHVideoResult alloc] init];
                            result.fileURL = fileURL;
                            result.cover = image;
                            result.coverTime = imageTime;
                            result.asset = rowData;
                            [_self.imagePicker completVideo:result];
                        }];
                        [_self.navigationController pushViewController:cover_vc animated:YES];
                    } else {
                        DSHVideoResult *result = [[DSHVideoResult alloc] init];
                        result.fileURL = outputFileURL;
                        [_self.imagePicker completVideo:result];
                    }
                }];
                [_self.navigationController pushViewController:vc animated:YES];
            } failureBlock:^(NSError * _Nonnull error) {
                [DSHImagePickerHUD hide];
                NSString *reason = error.userInfo[NSLocalizedDescriptionKey]?:@"未知错误";
                [_self.imagePicker show_error_alert:reason];
            }];
        }
    } else if (self.imagePicker.mode == DSHImagePickerModeMultipleImage) {
        // 检查是否选中
        BOOL selected = [self.imagePicker isSelect:rowData];
        if (selected) {
            [_self.imagePicker removeAsset:rowData];
            [_self selectItemsDidChange];
        } else {
            [_self.imagePicker addAsset:rowData complet:^{
                [_self selectItemsDidChange];
            }];
        }
    }
}

#pragma mark - MultipleImage
- (void)selectItemsDidChange; {
    [_collectionView reloadData];
    [_previewButtonItem setTitle:[NSString stringWithFormat:@"预览(%@)" ,@(self.imagePicker.selectPhotos.count)]];
}
- (void)clickedPreviewButton:(id)sender; {
    if (self.imagePicker.selectPhotos.count > 0) {
        DSHImagePickerPreviewController *vc = [[DSHImagePickerPreviewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.imagePicker show_error_alert:@"请先选择要预览的照片"];
    }
}
- (void)clickedDownItem {
    [self.imagePicker completImages:self.imagePicker.selectPhotos];
}
@end
