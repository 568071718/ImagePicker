//
//  DSHImagePickerPreviewController.m
//  IPicker
//
//  Created by 路 on 2020/1/14.
//  Copyright © 2020年 路. All rights reserved.
//

#import "DSHImagePickerPreviewController.h"
#import "DSHImageScrollView.h"
#import "DSHImagePickerProgressView.h"
#import "DSHImagePickerImageManager.h"
#import "UIImage+DSHImagePicker.h"
#import "DSHImagePicker.h"
#import <Masonry.h>

@interface _DSHImagePickerCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat distanceBetweenPages;
@end

@implementation _DSHImagePickerCollectionViewLayout
- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _distanceBetweenPages = 20;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = self.collectionView.bounds.size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttsArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat halfWidth = self.collectionView.bounds.size.width / 2.0;
    CGFloat centerX = self.collectionView.contentOffset.x + halfWidth;
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.center = CGPointMake(obj.center.x + (obj.center.x - centerX) / halfWidth * self.distanceBetweenPages / 2, obj.center.y);
    }];
    return layoutAttsArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end

@interface DSHImagePickerPreviewController ()
- (DSHImagePicker *)imagePicker;
@end

@implementation DSHImagePickerPreviewController
- (DSHImagePicker *)imagePicker; {
    DSHImagePicker *result = (DSHImagePicker *)self.navigationController;
    if ([result isKindOfClass:[DSHImagePicker class]]) {
        return result;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"已选图片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickedDownItem)];
    
    // Do any additional setup after loading the view.
    _DSHImagePickerCollectionViewLayout *layout = [[_DSHImagePickerCollectionViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark -
- (void)clickedDownItem; {
    [self.imagePicker completImages:self.imagePicker.selectPhotos];
}
#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView; {
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return self.imagePicker.selectPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    __weak typeof(self) _self = self;
    DSHPhotoResult *rowData = self.imagePicker.selectPhotos[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIView *subview = [cell viewWithTag:827];
    if (!subview) {
        subview = [[UIView alloc] init];
        subview.tag = 827;
        [cell addSubview:subview];
    }
    subview.frame = cell.bounds;
    [subview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    DSHImageScrollView *imageView = [[DSHImageScrollView alloc] initWithImage:rowData.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [subview addSubview:imageView];
    imageView.frame = subview.bounds;
    [imageView resetZoomScale];
    [imageView setSingleClickActionBlock:^BOOL(DSHImageScrollView * _Nonnull scrollView) {
        [_self.navigationController setNavigationBarHidden:!_self.navigationController.navigationBarHidden animated:YES];
        [_self.navigationController setToolbarHidden:_self.navigationController.navigationBarHidden animated:YES];
        [_self setNeedsStatusBarAppearanceUpdate];
        return NO;
    }];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    return collectionView.bounds.size;
}

#pragma mark -
- (BOOL)prefersStatusBarHidden; {
    return self.navigationController.navigationBarHidden;
}
@end
