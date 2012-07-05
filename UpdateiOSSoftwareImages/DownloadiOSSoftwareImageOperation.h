//
//  DownloadiOSSoftwareImageOperation.h
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 3..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileHashManager.h"

@interface DownloadiOSSoftwareImageOperation : NSOperation <NSURLDownloadDelegate>

- (id)initWithSoftwareImageURL:(NSURL *)softwareImageURL softwareImageSHA1Hash:(NSString *)softwareImageSHA1Hash destinationDirectoryPath:(NSString *)destinationDirectoryPath modelName:(NSString *)modelName productVersion:(NSString *)productVersion buildVersion:(NSString *)buildVersion;

@property (strong, nonatomic, readonly) NSURL *softwareImageURL;
@property (strong, nonatomic, readonly) NSString *destinationDirectoryPath;
@property (strong, nonatomic, readonly) NSString *modelName;
@property (strong, nonatomic, readonly) NSString *productVersion;
@property (strong, nonatomic, readonly) NSString *buildVersion;
@property (strong, nonatomic, readonly) NSURLDownload *download;
@property (strong, nonatomic, readonly) NSHTTPURLResponse *receivedHTTPURLResponse;
@property (strong, nonatomic, readonly) NSError *error;

@end
