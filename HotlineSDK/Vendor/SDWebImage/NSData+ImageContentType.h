/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "FDWebImageCompat.h"

typedef NS_ENUM(NSInteger, FDImageFormat) {
    FDImageFormatUndefined = -1,
    FDImageFormatJPEG = 0,
    FDImageFormatPNG,
    FDImageFormatGIF,
    FDImageFormatTIFF,
    FDImageFormatWebP
};

@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (FDImageFormat)fd_imageFormatForImageData:(nullable NSData *)data;

@end