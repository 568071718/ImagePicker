//
//  ViewController.m
//  DSHImagePicker
//
//  Created by 路 on 2020/6/2.
//  Copyright © 2020 路. All rights reserved.
//

#import "ViewController.h"
#import "DSHImagePicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)runDSHImagePickerModeImage; {
    DSHImagePicker *imagePicker = [[DSHImagePicker alloc] init];
    imagePicker.mode = DSHImagePickerModeImage;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)runDSHImagePickerModeMultipleImage; {
    DSHImagePicker *imagePicker = [[DSHImagePicker alloc] init];
    imagePicker.mode = DSHImagePickerModeMultipleImage;
    imagePicker.column = 3;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self runDSHImagePickerModeImage];
}
@end
