//
//  ViewController.m
//  UNNotification
//
//  Created by apple on 2017/10/17.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import "ViewController.h"
#import "JPUSHService.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface ViewController ()<UNUserNotificationCenterDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@",NSHomeDirectory());

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [JPUSHService setBadge:10];
    //清空角标
//    [JPUSHService resetBadge];
//    [JPUSHService setBadge:0];
    //关闭日志打印,发布时需关闭
//    [JPUSHService setLogOFF];
    NSString * localPath = [NSString stringWithFormat:@"%@/myAttachment.jpg", NSTemporaryDirectory()];
    
    UIImage *image = [UIImage imageNamed:@"2.jpg"];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
    
    [imgData writeToFile:localPath atomically:YES];
    
}


@end
