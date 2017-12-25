//
//  NotificationService.m
//  PushServiceTest
//
//  Created by apple on 2017/10/19.
//  Copyright © 2017年 zjbojin. All rights reserved.
//

#import "NotificationService.h"
#import "JPushNotificationExtensionService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    NSURLSession * session = [NSURLSession sharedSession];
    NSString * attachmentPath = self.bestAttemptContent.userInfo[@"my-attachment"];
    //if exist
    if (attachmentPath && [attachmentPath hasSuffix:@"png"]) {
        //download
        NSURLSessionTask * task = [session dataTaskWithURL:[NSURL URLWithString:attachmentPath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSString * localPath = [NSString stringWithFormat:@"%@/myAttachment.png", NSTemporaryDirectory()];
                if ([data writeToFile:localPath atomically:YES]) {
                    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"myAttachment" URL:[NSURL fileURLWithPath:localPath] options:nil error:nil];
                    self.bestAttemptContent.attachments = @[attachment];
                }
            }
            [self apnsDeliverWith:request];
        }];
        [task resume];
    }else{
        [self apnsDeliverWith:request];
    }
}

- (void)apnsDeliverWith:(UNNotificationRequest *)request {
    //service extension sdk
    //upload to calculate delivery rate
    //please set the same AppKey as your JPush
    [JPushNotificationExtensionService jpushSetAppkey:@"AppKey copied from JiGuang Portal application"];
    [JPushNotificationExtensionService jpushReceiveNotificationRequest:request with:^ {
        NSLog(@"apns upload success");
        self.contentHandler(self.bestAttemptContent);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
