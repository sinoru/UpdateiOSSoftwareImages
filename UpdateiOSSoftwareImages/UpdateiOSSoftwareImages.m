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
        NSString *lastSoftwareFirmwareSHA1Hash = lastSotftwareRestore[@"FirmwareSHA1"];
        
        if (lastSoftwareFirmwareURL) {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            
            if ([fileManager fileExistsAtPath:[directoryPath stringByAppendingPathComponent:[lastSoftwareFirmwareURL lastPathComponent]]]) {
                if (![[FileHashManager fileSHA1HashCreateWithPath:[directoryPath stringByAppendingPathComponent:[lastSoftwareFirmwareURL lastPathComponent]] chunkSizeForReadingData:FileHashDefaultChunkSizeForReadingData] isEqualToString:lastSoftwareFirmwareSHA1Hash]) {
                    NSLog(@"You have already iOS %@ (%@) Software Image for %@. But, It looks like broken. Do you want to re-download? (Y/N)", lastSoftwareProductVersion, lastSoftwareBuildVersion, iOSModelName);
                    
                    char string[4];
                    scanf("%3s", &string);
                    
                    if (![[NSString stringWithUTF8String:string] isEqualToString:@"Y"] && ![[NSString stringWithUTF8String:string] isEqualToString:@"Yes"] && ![[NSString stringWithUTF8String:string] isEqualToString:@"y"] && ![[NSString stringWithUTF8String:string] isEqualToString:@"yes"]) {
                        continue;
                    }
                }
                else {
                    NSLog(@"Already Downloaded! Skip to Download iOS %@ (%@) Software Image for %@!", lastSoftwareProductVersion, lastSoftwareBuildVersion, iOSModelName);
                    continue;
                }
            }
            
            DownloadiOSSoftwareImageOperation *downloadiOSSoftwareImageOperation = [[DownloadiOSSoftwareImageOperation alloc] initWithSoftwareImageURL:lastSoftwareFirmwareURL softwareImageSHA1Hash:lastSoftwareFirmwareSHA1Hash destinationDirectoryPath:directoryPath modelName:iOSModelName productVersion:lastSoftwareProductVersion buildVersion:lastSoftwareBuildVersion];
            
            [self.softwareDownloadingQueue addOperation:downloadiOSSoftwareImageOperation];
        }
    }
    
    while (self.softwareDownloadingQueue.operationCount && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

@end
