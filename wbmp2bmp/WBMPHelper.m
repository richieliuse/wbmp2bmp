//
//  WBMPHelper.m
//  WbmpDemo
//
//  Created by Richie Liu on 14/10/25.
//  Copyright (c) 2014年 Richie Liu. All rights reserved.
//

#import "WBMPHelper.h"

const unsigned long commonHeaderSize = 54 + 256 * 4;
const unsigned long miniHeaderSize = 54 + 2 * 4;
const unsigned long wbmpHeaderSize = 4;

unsigned long convertWbmp2ScaledBmp(const Byte *wbmpBytes, Byte *bmpBytes, unsigned long scale) {
    if (scale == 0 || wbmpBytes == NULL || bmpBytes == NULL) {
        return 0;
    }
    
    unsigned long wbmpWidth = (unsigned long)wbmpBytes[2];
    unsigned long wbmpHeight = (unsigned long)wbmpBytes[3];
    unsigned long wbmpBytesPerLine = (wbmpWidth + 7) / 8;
    
    unsigned long bmpWidth = wbmpWidth * scale;
    unsigned long bmpHeight = wbmpHeight * scale;
    unsigned long bmpBytesPerLine = (((bmpWidth * 8) + 31) >> 5) << 2;
    unsigned long bmpFileSize = bmpBytesPerLine * bmpHeight + commonHeaderSize;
    
    Byte header[commonHeaderSize] = { 0 };
    //  文件类型
    header[0] = 0x42;
    header[1] = 0x4d;
    //  文件大小
    header[2] = (Byte)bmpFileSize;
    header[3] = (Byte)(bmpFileSize >> 8);
    header[4] = (Byte)(bmpFileSize >> 16);
    header[5] = (Byte)(bmpFileSize >> 24);
    //  到图像数据的偏移量
    header[10] = 0x36;
    header[11] = 0x04;
    //  保留
    header[14] = 0x28;
    //  保留
    //  图像宽度
    header[18] = (Byte)bmpWidth;
    header[19] = (Byte)(bmpWidth >> 8);
    header[20] = (Byte)(bmpWidth >> 16);
    header[21] = (Byte)(bmpWidth >> 24);
    //  图像高度
    header[22] = (Byte)bmpHeight;
    header[23] = (Byte)(bmpHeight >> 8);
    header[24] = (Byte)(bmpHeight >> 16);
    header[25] = (Byte)(bmpHeight >> 24);
    //  保留
    header[26] = 0x01;
    //  bits per pixel
    header[28] = 0x08;
    //  调色板数
    header[46] = 0x00;
    header[47] = 0x01;
    //  调色板
    header[58] = 0xff;
    header[59] = 0xff;
    header[60] = 0xff;
    
    Byte *bmpBytesPointer = bmpBytes;
    memcpy(bmpBytesPointer, (Byte *)&header, commonHeaderSize);
    bmpBytesPointer += commonHeaderSize;
    
    const Byte *wbmpBytesPointer = wbmpBytes + wbmpHeaderSize;
    
    for (unsigned long h = 0; h < bmpHeight; h++) {
        for (unsigned long w = 0; w < bmpWidth; ++w) {
            unsigned long minW = w / scale;
            unsigned long minH = h / scale;
            Byte pixelByte = (Byte)((*(wbmpBytesPointer + (wbmpHeight - minH - 1) * wbmpBytesPerLine + minW / 8)) >> (8 - minW % 8 - 1)) & 0x01;
            *(bmpBytesPointer + bmpBytesPerLine * h + w) = pixelByte;
        }
    }
    
    return bmpFileSize;
}

unsigned long convertWbmp2Bmp(const Byte *wbmpBytes, Byte *bmpBytes) {
    if (wbmpBytes == NULL || bmpBytes == NULL) {
        return 0;
    }
    
    Byte header[miniHeaderSize] = {
        0x42, 0x4d,     //  文件类型
        0, 0, 0, 0,     //  位图大小
        0, 0,           //  保留
        0, 0,           //  保留
        0x3e, 0, 0, 0,  //  从文件头开始到实际像素数据的字节的偏移量
        0x28, 0, 0, 0,  //  BITMAPINFOHEADER所需要的字节
        0, 0, 0, 0,     //  图像的宽度
        0, 0, 0, 0,     //  图像的高度
        1, 0,           //  颜色平面数，必须为1
        1, 0,           //  bit数/像素
        0, 0, 0, 0,     //  压缩类型
        0, 0, 0, 0,     //  图像的大小
        0, 0, 0, 0,     //  水平分辨率
        0, 0, 0, 0,     //  垂直分辨率
        0, 0, 0, 0,     //  图像实际使用的颜色索引数
        0, 0, 0, 0,     //  对图像重要的颜色索引数
        0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00 //  调色板
    };
    
    unsigned long wbmpWidth, wbmpHeight, wbmpBytesPerLine, bmpBytesPerLine, bmpFileSize;
    wbmpWidth = wbmpBytes[2];
    wbmpHeight = wbmpBytes[3];
    wbmpBytesPerLine = (unsigned long)((wbmpWidth + 7) / 8);
    bmpBytesPerLine =  ((unsigned long)((wbmpBytesPerLine + 3) / 4)) * 4;
    bmpFileSize = bmpBytesPerLine * wbmpHeight + miniHeaderSize;
    
    header[2] = (Byte)bmpFileSize;
    header[3] = (Byte)(bmpFileSize >> 8);
    header[4] = (Byte)(bmpFileSize >> 16);
    header[5] = (Byte)(bmpFileSize >> 24);
    header[18] = (Byte)wbmpWidth;
    header[19] = (Byte)(wbmpWidth >> 8);
    header[20] = (Byte)(wbmpWidth >> 16);
    header[21] = (Byte)(wbmpWidth >> 24);
    header[22] = (Byte)wbmpHeight;
    header[23] = (Byte)(wbmpHeight >> 8);
    header[24] = (Byte)(wbmpHeight >> 16);
    header[25] = (Byte)(wbmpHeight >> 24);
    
    Byte *bmpBytesPointer = bmpBytes;
    memcpy(bmpBytesPointer, (Byte *)&header, miniHeaderSize);
    bmpBytesPointer += miniHeaderSize;
    
    const Byte *wbmpBytesPointer = wbmpBytes + wbmpHeaderSize;
    
    for (unsigned long h = 0; h < wbmpHeight; h++) {
        memcpy(bmpBytesPointer, wbmpBytesPointer + wbmpBytesPerLine * (wbmpHeight - h - 1), wbmpBytesPerLine);
        bmpBytesPointer += bmpBytesPerLine;
    }
    return bmpFileSize;
}

@implementation WBMPHelper

+ (NSUInteger)convertWBMP:(const Byte *)wbmpBytes toBMP:(Byte *)bmpBytes {
    return convertWbmp2Bmp(wbmpBytes, bmpBytes);
}

+ (NSUInteger)convertWBMP:(const Byte *)wbmpBytes toBMP:(Byte *)bmpBytes scale:(NSUInteger)scale {
    return convertWbmp2ScaledBmp(wbmpBytes, bmpBytes, scale);
}

+ (NSData *)BMPDataFromWBMPData:(NSData *)wbmpData scale:(NSUInteger)scale {
    if (!wbmpData.length) {
        return nil;
    }
    
    NSUInteger wbmpDataLength = wbmpData.length;
    Byte *bmpBytes = (Byte *)calloc(wbmpDataLength * scale * scale * 8 + 2048, sizeof(Byte));
    const Byte *wbmpBytes = (const Byte *)wbmpData.bytes;
    NSUInteger bmpBytesLength = 0;
    if (scale == 1) {
        //  不放大时有优化的转换方法，得到的bmp也会相对较小一些
        bmpBytesLength = convertWbmp2Bmp(wbmpBytes, bmpBytes);
    }
    else {
        bmpBytesLength = convertWbmp2ScaledBmp(wbmpBytes, bmpBytes, scale);
    }
    
    if (!bmpBytesLength) {
        free(bmpBytes);
        return nil;
    }
    
    NSData *bmpData = [NSData dataWithBytesNoCopy:bmpBytes length:bmpBytesLength freeWhenDone:YES];
    
    return bmpData;
}

@end
