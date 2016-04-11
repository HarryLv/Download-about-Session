//
//  LLDownloadManager.h
//  test
//
//  Created by ll on 16/4/11.
//  Copyright © 2016年 ll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//下载进度
typedef void(^progressBlock)(float progress);

@interface LLDownloadManager : NSObject

@property (nonatomic,strong)NSURLSession*session;

@property (nonatomic,strong)NSURLSessionDownloadTask*task;

@property(nonatomic ,copy) NSString *urlString;

// 断点续传需要的参数
@property (nonatomic,strong)NSData*resumeData;

// 获取单例对象
+(instancetype)sharedManager;
// 下载网络任务
-(void)downloadFileWithUrlString:(NSString *)urlString filePath:(NSString *)filePath Progress:(progressBlock)progressBlock;
// 取消下载
- (void)cancalDownloadWithUrlString:(NSString *)urlString;



@end
