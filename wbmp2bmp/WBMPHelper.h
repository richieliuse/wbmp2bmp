//
//  WBMPHelper.h
//  WbmpDemo
//
//  Created by Richie Liu on 14/10/25.
//  Copyright (c) 2014年 Richie Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBMPHelper : NSObject

/**
 *  wbmp2bmp转换函数(等尺寸转换)
 *
 *  @param wbmpDate 需要转换的wbmp数据
 *  @param bmpData  转换后的bmp数据
 *
 *  @return 转换后bmp的数据大小
 */
+ (NSUInteger)convertWBMP:(const Byte *)wbmpBytes toBMP:(Byte *)bmpBytes;

/**
 *  wbmp2bmp转换函数(等比例放大转换)
 *
 *  @param wbmpDate 需要转换的wbmp数据
 *  @param bmpData  转换后的bmp数据
 *  @param scale    转换成bmp的放大倍数, >=1
 *
 *  @return 转换后bmp的数据大小
 */
+ (NSUInteger)convertWBMP:(const Byte *)wbmpBytes toBMP:(Byte *)bmpBytes scale:(NSUInteger)scale;

/**
 *  wbmp2bmp转换函数(等比例放大转换)
 *
 *  @param wbmpData 需要转换的wbmp数据
 *  @param scale    转换成bmp的放大倍数, >=1
 *
 *  @return 转换后的bmp数据, 无压缩
 */
+ (NSData *)BMPDataFromWBMPData:(NSData *)wbmpData scale:(NSUInteger)scale;

@end
