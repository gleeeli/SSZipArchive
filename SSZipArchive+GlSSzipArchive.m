//
//  SSZipArchive+GlSSzipArchive.m
//  Wi-Fi_Disk
//
//  Created by dsw on 16/7/20.
//  Copyright © 2016年 LiuMaoWen. All rights reserved.
//

#import "SSZipArchive+GlSSzipArchive.h"

@implementation SSZipArchive (GlSSzipArchive)
//+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination delegate:(id<SSZipArchiveDelegate>)delegate
//{
//    return [SSZipArchive unzipFileAtPath:path toDestination:destination overwrite:YES password:nil error:nil delegate:delegate progressHandler:nil completionHandler:nil];
//}
//gl自定义方法
+ (BOOL)createZipFileAtPath:(NSString *)path withContents:(NSArray *)filesPath withPassword:(NSString *)password {
    BOOL success = NO;
    
    NSFileManager *fileManager = nil;
    SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
    
    if ([zipArchive open]) {
        
        fileManager = [[NSFileManager alloc] init];
        //NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:directoryPath];
        NSString *fileName;
        for (NSString *fullFilePath in filesPath)
        {
            fileName = [fullFilePath lastPathComponent];
            
            BOOL isDir;
            [fileManager fileExistsAtPath:fullFilePath isDirectory:&isDir];
            if (!isDir) {
                [zipArchive writeFileAtPath:fullFilePath withFileName:fileName withPassword:password];
            }
            else
            {
                //[zipArchive writeFolderAtPath:fullFilePath withFolderName:fileName withPassword:nil];
                [self toCreateDirWithFileManager:fileManager withContentsOfDirectory:fullFilePath zipArchive:zipArchive keepParentDirectory:YES withPassword:password];
                
            }
        }
        success = [zipArchive close];
    }
    
#if !__has_feature(objc_arc)
    [fileManager release];
    [zipArchive release];
#endif
    
    return success;
}
+ (void)toCreateDirWithFileManager:(NSFileManager *)fileManager withContentsOfDirectory:(NSString *)directoryPath zipArchive:(SSZipArchive *)zipArchive keepParentDirectory:(BOOL)keepParentDirectory withPassword:(NSString *)password 
{
    fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:directoryPath];
    NSString *fileName;
    while ((fileName = [dirEnumerator nextObject])) {
        BOOL isDir;
        NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
        [fileManager fileExistsAtPath:fullFilePath isDirectory:&isDir];
    
        if (keepParentDirectory)
        {
            fileName = [[directoryPath lastPathComponent] stringByAppendingPathComponent:fileName];
        }
        
        if (!isDir) {
            [zipArchive writeFileAtPath:fullFilePath withFileName:fileName withPassword:password];
        }
        else
        {
            if([[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fullFilePath error:nil].count == 0)
            {
                 NSString *tempFilePath = [self temporaryPathForDiscardableFile];
                NSString *tempFileFilename = [fileName stringByAppendingPathComponent:tempFilePath.lastPathComponent];
                [zipArchive writeFileAtPath:tempFilePath withFileName:tempFileFilename withPassword:password];
            }
        }
    }
}
+ (NSString *)temporaryPathForDiscardableFile
{
    static NSString *discardableFileName = @".DS_Store";
    static NSString *discardableFilePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *temporaryDirectoryName = [[NSUUID UUID] UUIDString];
        NSString *temporaryDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryDirectoryName];
        BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:temporaryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        discardableFilePath = directoryCreated ? [temporaryDirectory stringByAppendingPathComponent:discardableFileName] : nil;
        [@"" writeToFile:discardableFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    });
    return discardableFilePath;
}
@end
