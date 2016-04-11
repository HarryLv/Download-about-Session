//
//  LLDownloadManager.m
//  test
//
//  Created by ll on 16/4/11.
//  Copyright © 2016年 ll. All rights reserved.
//

#import "LLDownloadManager.h"

@interface LLDownloadManager ()<NSURLSessionDownloadDelegate>

@property(nonatomic,copy)progressBlock progress;

@property(nonatomic ,copy) NSString *filePath;

@end

@implementation LLDownloadManager

-(NSURLSession *)session
{
    if (!_session) {
        
        NSURLSessionConfiguration *cgf = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session= [NSURLSession sessionWithConfiguration:cgf delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}


-(void)downloadFileWithUrlString:(NSString *)urlString filePath:(NSString *)filePath Progress:(progressBlock)progressBlock
{
    self.filePath = filePath;
    self.progress = progressBlock;
    
    if (urlString != self.urlString) { //如果两个 下载地址不同.就下载新的内容
        // 2. 实例化下载任务
        self.urlString = urlString;
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
        self.task = task;
        // 3. 开启网络任务
        [self.task resume];
        
    }else // 两个下载地址相同
    {
        // 者就是断点续传的开始方法
        self.task = [self.session downloadTaskWithResumeData:self.resumeData];
        [self.task resume];
        
        // 下载获取新的暂停数据!
        self.resumeData = nil;
    }
    
}

// 对于单个任务下载,不需要 UrlString
// 对于多个任务下载:需要自己判断暂停哪一个下载
-(void)cancalDownloadWithUrlString:(NSString *)urlString
{
    if (self.resumeData) {  // 如果 有值,说明之前暂停过.
        return;
    }
    
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        self.resumeData = resumeData;
        [resumeData writeToFile:@"/Users/apple/Desktop/123" atomically:YES];
        // 暂停任务之后,就将网络任务清空一下.
        // session 对网络任务有一个强引用.
        self.task = nil;
    }];
}

+(instancetype)sharedManager
{
    static id _instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma NSURLSessionDownloadDelegate

// 网络下载完成之后的回调/这个方法是必须实现的.
// location : 文件下载之后,在本地保存的路径.
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"location:%@",location.path);
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:self.filePath error:NULL];
}

// 监听下载进度的方法:
// bytesWritten : 本次写入的数据量
// totalBytesWritten :已经写入的数据量
// totalBytesExpectedToWrite :总共需要写入的数据量.
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float) totalBytesWritten/totalBytesExpectedToWrite;
    
    NSLog(@"progress:%f %@",progress,[NSThread currentThread]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.progress) {
            self.progress(progress);
        }
        
    });
    
    
}

// 断点续传的方法: 目前这个方法已经废了!
// iOS 7 的时候,三个方法都是必须实现的!
// iOS 8 以后,只有一个必须实现的方法!
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

@end
