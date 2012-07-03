//
//  DownloadiOSSoftwareImageOperation.m
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 3..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import "DownloadiOSSoftwareImageOperation.h"

@interface DownloadiOSSoftwareImageOperation () {
    BOOL _isExecuting;
    BOOL _isFinished;
    BOOL _isReady;
    NSTimeInterval _startedTimeInteval;
    NSUInteger _bytesReceived;
    BOOL _needToBeRemoveConsoleLastLine;
}

@property (strong, nonatomic, readwrite) NSURL *softwareImageURL;
@property (strong, nonatomic, readwrite) NSString *destinationDirectoryPath;
@property (strong, nonatomic, readwrite) NSString *modelName;
@property (strong, nonatomic, readwrite) NSString *productVersion;
@property (strong, nonatomic, readwrite) NSString *buildVersion;
@property (strong, nonatomic, readwrite) NSURLDownload *download;
@property (strong, nonatomic, readwrite) NSHTTPURLResponse *receivedHTTPURLResponse;
@property (strong, nonatomic, readwrite) NSError *error;
@property (strong, nonatomic) NSMutableURLRequest *request;

@end

@implementation DownloadiOSSoftwareImageOperation

- (id)initWithSoftwareImageURL:(NSURL *)softwareImageURL destinationDirectoryPath:(NSString *)destinationDirectoryPath modelName:(NSString *)modelName productVersion:(NSString *)productVersion buildVersion:(NSString *)buildVersion
{
    self = [super init];
    if (self) {
        // Initialization code
        self.destinationDirectoryPath = destinationDirectoryPath;
        self.modelName = modelName;
        self.productVersion = productVersion;
        self.buildVersion = buildVersion;
        
        self.request = [[NSMutableURLRequest alloc] initWithURL:softwareImageURL];
        self.request.HTTPMethod = @"GET";
        
        [self willChangeValueForKey:@"isReady"];
        _isReady = YES;
        [self didChangeValueForKey:@"isReady"];
    }
    return self;
}

- (void)start
{
    if (![self isCancelled]) {
        _startedTimeInteval = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"Start to download iOS %@ (%@) software image for %@!", self.productVersion, self.buildVersion, self.modelName);
        self.download = [[NSURLDownload alloc] initWithRequest:self.request delegate:self];
        
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        while (_isExecuting && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
    else {
        [self willChangeValueForKey:@"isFinished"];
        _isFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (BOOL)isReady
{
    return _isReady;
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    [download setDestination:[self.destinationDirectoryPath stringByAppendingPathComponent:filename] allowOverwrite:NO];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    _bytesReceived = 0;
    _needToBeRemoveConsoleLastLine = NO;
    
    self.receivedHTTPURLResponse = (NSHTTPURLResponse *)response;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
    _bytesReceived += length;
    
    NSString *speedString;
    double byteSpeed = _bytesReceived / ([NSDate timeIntervalSinceReferenceDate] - _startedTimeInteval);
    double kiloByteSpeed = roundf(byteSpeed / 100) / 10;
    double megaByteSpeed = roundf(kiloByteSpeed / 100) / 10;
    double gigaByteSpeed = roundf(megaByteSpeed / 100) / 10;
    
    if (byteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%f B/s", byteSpeed];
    }
    else if (kiloByteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%0.1f KB/s", kiloByteSpeed];
    }
    else if (megaByteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%0.1f MB/s", megaByteSpeed];
    }
    else {
        speedString = [NSString stringWithFormat:@"%0.1f GB/s", gigaByteSpeed];
    }
    
    printf("%0.1f%% Downloaded (%s)     \r", ((float)_bytesReceived / (float)self.receivedHTTPURLResponse.expectedContentLength) * 100, speedString.UTF8String);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSString *speedString;
    double byteSpeed = _bytesReceived / ([NSDate timeIntervalSinceReferenceDate] - _startedTimeInteval);
    double kiloByteSpeed = roundf(byteSpeed / 100) / 10;
    double megaByteSpeed = roundf(kiloByteSpeed / 100) / 10;
    double gigaByteSpeed = roundf(megaByteSpeed / 100) / 10;
    
    if (byteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%f B/s", byteSpeed];
    }
    else if (kiloByteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%0.1f KB/s", kiloByteSpeed];
    }
    else if (megaByteSpeed < 1000) {
        speedString = [NSString stringWithFormat:@"%0.1f MB/s", megaByteSpeed];
    }
    else {
        speedString = [NSString stringWithFormat:@"%0.1f GB/s", gigaByteSpeed];
    }
    
    printf("100%% Downloaded (%s)     ", speedString.UTF8String);
    printf("\n\r");
    
    self.download = nil;
    
    NSLog(@"iOS %@ (%@) software image for %@ downloading done.", self.productVersion, self.buildVersion, self.modelName);
    
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    NSLog(@"Error occured while downloading iOS %@ (%@) software image for %@", self.productVersion, self.buildVersion, self.modelName);
    NSLog(@"%@", error);
    self.error = error;
    self.download = nil;
    
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

@end
