//
//  SSZipArchive+GlSSzipArchive.h
//  Wi-Fi_Disk
//
//  Created by dsw on 16/7/20.
//  Copyright © 2016年 LiuMaoWen. All rights reserved.
//

#import "SSZipArchive.h"

@interface SSZipArchive (GlSSzipArchive)
//gl自定义方法,自动识别文件夹或文件
+ (BOOL)createZipFileAtPath:(NSString *)path withContents:(NSArray *)filesPath withPassword:(NSString *)password ;
@end
