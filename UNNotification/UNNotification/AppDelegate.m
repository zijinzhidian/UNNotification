//
//  AppDelegate.m
//  UNNotification
//
//  Created by apple on 2017/10/17.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "JPUSHService.h"
#import "JPushNotificationExtensionService.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //请求权限(iOS10.0+)
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert|UNAuthorizationOptionCarPlay completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if (granted && !error) {   //用户权限申请成功
            NSLog(@"允许");
        } else {      //申请失败,用户点不允许
            NSLog(@"不允许");
        }
        
    }];
    
    
    
    //获取推送通知权限(iOS10.0+)
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        NSLog(@"%@",settings);
        
    }];
    
    NSDictionary *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        NSLog(@"app是通过点击通知而启动的");
    }
    
    //注册推送通知
    [application registerForRemoteNotifications];
    
    //本地通知
    [self setupPush];

    
    //注册JPush
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert | JPAuthorizationOptionBadge | JPAuthorizationOptionSound;
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"ad1d96c9c086d11e345be505" channel:nil apsForProduction:NO];
    
    
    return YES;
}



- (void)setupPush {

    //通知内容的附件
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *gifURL = [NSURL URLWithString:@"http://s1.dwstatic.com/group1/M00/C3/6B/c46288245ddbd30b4bfcfb741354abaf.gif"];
    NSURLSessionDataTask *task = [session dataTaskWithURL:gifURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@att.%@",@([NSDate date].timeIntervalSince1970),@"gif"]];
            [data writeToFile:path atomically:YES];
            
            //创建触发器
            UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
            UNNotificationAttachment *achment = [UNNotificationAttachment attachmentWithIdentifier:@"这是附件标识" URL:[NSURL fileURLWithPath:path] options:@{UNNotificationAttachmentOptionsThumbnailClippingRectKey:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)]} error:nil];
                        
            //组合内容
            UNNotificationAction *sure = [UNNotificationAction actionWithIdentifier:@"确定标识" title:@"确定" options:UNNotificationActionOptionAuthenticationRequired];
            UNNotificationAction *cancel = [UNNotificationAction actionWithIdentifier:@"取消标识" title:@"取消" options:UNNotificationActionOptionForeground | UNNotificationActionOptionDestructive];
            
            UNTextInputNotificationAction *input = [UNTextInputNotificationAction actionWithIdentifier:@"输入标识" title:@"点击回复消息" options:UNNotificationActionOptionAuthenticationRequired textInputButtonTitle:@"发送" textInputPlaceholder:@"请输入内容"];
            
            UNNotificationCategory *choseCategory = [UNNotificationCategory categoryWithIdentifier:@"categotyID" actions:@[sure, cancel] intentIdentifiers:@[@"确定标识", @"取消标识"] options:UNNotificationCategoryOptionNone];
            UNNotificationCategory *inputCategory = [UNNotificationCategory categoryWithIdentifier:@"categotyID1" actions:@[input] intentIdentifiers:@[@"输入标识"] options:UNNotificationCategoryOptionNone];
            
            //添加组合内容
            [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:choseCategory, inputCategory, nil]];
            
            //创建推送的内容
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"退后,我要开始装逼了!!!";
            content.body = @"装逼大会总决赛时间到,欢迎您参加总决赛!希望您一统X界";
            content.badge = @4;
            content.sound = [UNNotificationSound defaultSound];
            content.attachments = @[achment];
            content.launchImageName = @"2.jpg";
            content.categoryIdentifier = @"categotyID";
            //    content.categoryIdentifier = @"categotyID1";
            
            
            //创建通知请求
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"这是请求标识" content:content trigger:timeTrigger];
            
            //添加通知请求
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
                if (!error) {
                    NSLog(@"添加通知成功");
                } else {
                    NSLog(@"添加通知失败");
                }
                
            }];
        }
        
    }];
    
    [task resume];
    
}

//iOS7.0 - iOS10.0 接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [JPUSHService handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

#pragma mark - UNUserNotificationCenterDelegate (iOS10.0+)
//前台接受到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSLog(@"接受到通知信息了");
    
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;

    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
    
}

//用户点击通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

    if ([response.actionIdentifier isEqualToString:@"确定标识"]) {
        NSLog(@"点击了确定");
    }
    
    if ([response.actionIdentifier isEqualToString:@"取消标识"]) {
        NSLog(@"点击了取消");
    }
    
    if ([response.actionIdentifier isEqualToString:@"输入标识"]) {
        
        NSLog(@"点击了发送");
    }
    
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        NSLog(@"哈哈哈哈😄");
    }
    
    NSLog(@"点击了通知");
    UIViewController *vc = self.window.rootViewController;
    [vc presentViewController:[[TestViewController alloc] init] animated:true completion:nil];
    
    completionHandler();
    
}



#pragma mark - JPUSH
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    NSLog(@"德玛西亚");
    
    //判断是否为远程推送
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:notification.request.content.userInfo];
    }
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:response.notification.request.content.userInfo];
    }
    
    
    completionHandler();
    
}



/**
 获取DeviceToken成功
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [JPUSHService registerDeviceToken:deviceToken];
    
}

/**
 获取DeviceToken失败
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
