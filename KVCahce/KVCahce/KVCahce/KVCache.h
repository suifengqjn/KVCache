//
//  KVCache.h
//  KVCahce
//
//  Created by qianjianeng on 16/3/12.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "PINCache.h"
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    KVCahceTypeUnKnow = 0,
    KVCahceTypeImage,
    KVCahceTypeGif,
    KVCahceTypeMp4,
} KVCacheType;


#define KVCacheErrorReport @"KVCacheErrorReport"
@interface KVCache : PINCache

// 缓存图片、g
+ (instancetype)sharedInstance;

// 异步
- (void)setData:(NSData *)data forUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType block:(PINCacheObjectBlock)block;
- (void)dataForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType block:(PINCacheObjectBlock)block;
- (void)mp4URLForUrlKey:(NSURL *)urlKey block:(PINDiskCacheObjectBlock)block;
- (void)videoURLForUrlKey:(NSURL *)urlKey block:(PINDiskCacheObjectBlock)block;

- (void)setImage:(UIImage *)image forUrlKey:(NSURL *)urlKey block:(PINCacheObjectBlock)block;
- (void)imageForUrlKey:(NSURL *)urlKey block:(void(^)(PINCache *cache, NSString *key, UIImage *image))block;


// 同步

- (void)setData:(NSData *)data forUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType;
- (NSData *)dataForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType;
- (NSURL *)mp4URLForUrlKey:(NSURL *)urlKey;

- (void)setImage:(UIImage *)image forUrlKey:(NSURL *)urlKey;
- (UIImage *)imageForUrlKey:(NSURL *)urlKey;

//获取存储文件名
- (NSString *)getFileNameForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType;


- (void)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects:(PINCacheBlock)block;
- (void)removeAllObjects;



@end

