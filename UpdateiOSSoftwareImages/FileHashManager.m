//
//  FileHashManager.m
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 4..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import "FileHashManager.h"

@implementation FileHashManager

+ (NSString *)fileSHA1HashCreateWithPath:(NSString *)filePath chunkSizeForReadingData:(size_t)chunkSizeForReadingData
{
    // Declare needed variables
    CFStringRef result = NULL;
    CFURLRef fileURL = NULL;
    CFReadStreamRef readStream = NULL;
    
    void (^cleaning) () = ^(){
        if (readStream) {
            CFReadStreamClose(readStream);
            CFRelease(readStream);
        }
        if (fileURL) {
            CFRelease(fileURL);
        }
    };
    
    // Get the file URL
    fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL)
        return nil;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) {
        cleaning();
        return nil;
    }
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) {
        cleaning();
        return nil;
    }
    
    // Initialize the hash object
    CC_SHA1_CTX hashObject;
    CC_SHA1_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_SHA1_Update(&hashObject,
                       (const void *)buffer,
                       (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) {
        cleaning();
        return nil;
    }
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
    cleaning();
    
    return (NSString *)CFBridgingRelease(result);
}

@end
