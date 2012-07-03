//
//  UpdateiOSSoftwareImages.m
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 3..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import "UpdateiOSSoftwareImages.h"

#import "DownloadiOSSoftwareImageOperation.h"

NSString const* AppleiOSUpdateURLString = @"http://phobos.apple.com/version";

@interface UpdateiOSSoftwareImages ()

@property (strong, nonatomic) NSOperationQueue *softwareDownloadingQueue;

@end

@implementation UpdateiOSSoftwareImages

- (void)startUpdateiOSSoftwareImages:(NSString *)directoryPath
{
    NSDictionary *iOSUpdatePropertyList = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:AppleiOSUpdateURLString]];
    self.softwareDownloadingQueue = [[NSOperationQueue alloc] init];
    self.softwareDownloadingQueue.maxConcurrentOperationCount = 1;
    
    NSDictionary *iOSSoftwareVersionsByVersion = iOSUpdatePropertyList[@"MobileDeviceSoftwareVersionsByVersion"];
    id iOSSoftwareVersionsByLastVersionKey = [[[iOSSoftwareVersionsByVersion allKeys] sortedArrayUsingSelector:@selector(compare:)] lastObject];
    
    NSDictionary *iOSSoftwareVersions = iOSSoftwareVersionsByVersion[iOSSoftwareVersionsByLastVersionKey][@"MobileDeviceSoftwareVersions"];
    
    NSLog(@"%@", [[iOSSoftwareVersions allKeys] sortedArrayUsingSelector:@selector(compare:)]);
    
    for (id iOSModelName in [[iOSSoftwareVersions allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSDictionary *iOSSoftwareBuildVersionListByModel = iOSSoftwareVersions[iOSModelName];
        
        NSMutableArray *iOSSoftwareBuildVersionKeys = [[[iOSSoftwareBuildVersionListByModel allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        for (NSString *iOSSoftwareBuildVersionKey in iOSSoftwareBuildVersionKeys) {
            if ([iOSSoftwareBuildVersionKey isEqualToString:@"Unknown"])
                [iOSSoftwareBuildVersionKeys removeObject:iOSSoftwareBuildVersionKey];
        }
        
        NSString *lastSoftwareBuildVersion = [iOSSoftwareBuildVersionKeys lastObject];
        
        if (iOSSoftwareBuildVersionListByModel[lastSoftwareBuildVersion][@"SameAs"]) {
            lastSoftwareBuildVersion = iOSSoftwareBuildVersionListByModel[lastSoftwareBuildVersion][@"SameAs"];
        }
        
        NSDictionary *lastSotftwareRestore = iOSSoftwareBuildVersionListByModel[lastSoftwareBuildVersion][@"Restore"];
        
        NSString *lastSoftwareProductVersion = lastSotftwareRestore[@"ProductVersion"];
        NSURL *lastSoftwareFirmwareURL = [NSURL URLWithString:lastSotftwareRestore[@"FirmwareURL"]];
        
        if (lastSoftwareFirmwareURL) {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            
            if (![fileManager fileExistsAtPath:[directoryPath stringByAppendingPathComponent:[lastSoftwareFirmwareURL lastPathComponent]]]) {
                DownloadiOSSoftwareImageOperation *downloadiOSSoftwareImageOperation = [[DownloadiOSSoftwareImageOperation alloc] initWithSoftwareImageURL:lastSoftwareFirmwareURL destinationDirectoryPath:directoryPath modelName:iOSModelName productVersion:lastSoftwareProductVersion buildVersion:lastSoftwareBuildVersion];
                
                [self.softwareDownloadingQueue addOperation:downloadiOSSoftwareImageOperation];
            }
            else {
                NSLog(@"Skip to download iOS %@ (%@) software image for %@!", lastSoftwareProductVersion, lastSoftwareBuildVersion, iOSModelName);
            }
        }
    }
    
    while (self.softwareDownloadingQueue.operationCount && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

@end
