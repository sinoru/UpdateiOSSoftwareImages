//
//  main.m
//  UpdateiOSSoftwareImages
//
//  Created by Sinoru on 12. 7. 3..
//  Copyright (c) 2012년 Sinoru. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UpdateiOSSoftwareImages.h"

int main(int argc, const char *argv[])
{
    
    @autoreleasepool {
        // insert code here...
        NSMutableArray *arguments = [NSMutableArray new];
        NSMutableDictionary *options = [NSMutableDictionary new];
        while (--argc)
        {
            const char *arg = *++argv;
            if (strncmp(arg, "--", 2) == 0) {
                if (*++argv)
                    options[@(arg + 2)] = @(*argv);  // --key value
                else {
                    [arguments addObject:@(arg)];
                }
            } else {
                [arguments addObject:@(arg)];            // positional argument
            }
        }
        
        if ([arguments indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
            if ([obj isEqualToString:@"-h"] || [obj isEqualToString:@"--help"]) {
                *stop = YES;
                return YES;
            }
            else
                return NO;
        }] != NSNotFound) {
            printf("Usage: UpdateiOSSoftwareImages (path)\n");
            return 0;
        }
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *folderPath = nil;
        
        if (arguments.count) {
            BOOL isDirectory;
            
            if (![fileManager fileExistsAtPath:[arguments[0] stringByExpandingTildeInPath] isDirectory:&isDirectory] || !isDirectory) {
                printf("Please enter correct path.\n");
                return 1;
            }
            else {
                folderPath = arguments[0];
            }
        }
        else
            folderPath = [fileManager currentDirectoryPath];
        
        UpdateiOSSoftwareImages *updateiOSSoftwareImages = [[UpdateiOSSoftwareImages alloc] init];
        [updateiOSSoftwareImages startUpdateiOSSoftwareImages:folderPath];
        
    }
    return 0;
}

