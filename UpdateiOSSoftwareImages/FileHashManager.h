//
//  FileHashManager.h
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 4..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import <Foundation/Foundation.h>

// Cryptography
#include <CommonCrypto/CommonDigest.h>

// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096

@interface FileHashManager : NSObject

+ (NSString *)fileSHA1HashCreateWithPath:(NSString *)filePath chunkSizeForReadingData:(size_t)chunkSizeForReadingData;

@end
