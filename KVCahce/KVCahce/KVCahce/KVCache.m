//
//  KVCache.m
//  KVCahce
//
//  Created by qianjianeng on 16/3/12.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "KVCache.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const TBCacheIDMMediaName = @"KVCache";

@implementation KVCache


+ (instancetype)sharedInstance
{
    static id cache;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        cache = [[self alloc] initWithName:TBCacheIDMMediaName];
    });
    return cache;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        
        // 最大300M，时间为一周
        self.diskCache.byteLimit = 1024 * 1024 * 300;
        self.diskCache.ageLimit = 3600 * 24 * 7;
    }
    
    return self;
}


- (NSString *)cachedFileNameForUrlKey:(NSURL *)urlKey extension:(NSString *)extension  {
    
    NSString *key;
    if ([[urlKey absoluteString] hasPrefix:@"http://"]) {
        // 为了防止更换host导致缓存失效，使用url的path计算文件名
        key = urlKey.path;
    } else {
        // 不是http头的url则使用url计算key，assets-library的path的值都一样
        key = [urlKey absoluteString];
    }
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    if (extension) {
        return [filename stringByAppendingString:extension];
    } else {
        return filename;
    }
}

- (NSString *)extensionForCacheType:(KVCacheType)cacheType
{
    switch (cacheType) {
        case KVCahceTypeUnKnow:
            return @"unknow";
            break;
        case KVCahceTypeImage:
            return @".jpg";
            break;
        case KVCahceTypeGif:
            return @".gif";
            break;
        case KVCahceTypeMp4:
            return @".mp4";
            break;
    }
}

#pragma mark - 异步

- (void)setData:(NSData *)data forUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType block:(PINCacheObjectBlock)block
{
    
    [self setRaw:data forKey:[self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:cacheType]] block:^(PINCache *cache, NSString *key, id object) {
        
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, object);
            });
        }
        
    }];
}

- (void)dataForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType block:(PINCacheObjectBlock)block
{
    [self rawForKey:[self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:cacheType]] block:^(PINCache *cache, NSString *key, id object) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, object);
            });
        }
    }];
}

- (void)mp4URLForUrlKey:(NSURL *)urlKey block:(PINDiskCacheObjectBlock)block
{
    [self.diskCache fileURLForKey:[self cachedFileNameForUrlKey:urlKey extension:@".mp4"] block:^(PINDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, object, fileURL);
            });
        }
    }];
}

- (void)videoURLForUrlKey:(NSURL *)urlKey block:(PINDiskCacheObjectBlock)block
{
    [self.diskCache fileURLForKey:[self cachedFileNameForUrlKey:urlKey extension:@".mp4"] block:^(PINDiskCache *cache, NSString *key, id<NSCoding> object, NSURL *fileURL) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, object, fileURL);
            });
        }
    }];
}

- (void)setImage:(UIImage *)image forUrlKey:(NSURL *)urlKey block:(PINCacheObjectBlock)block
{
    [self setData:UIImageJPEGRepresentation(image, 0.5f) forUrlKey:urlKey cacheType:KVCahceTypeImage block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
        if (block) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, object);
            });
        }
    }];
}


- (void)imageForUrlKey:(NSURL *)urlKey block:(void (^)(PINCache *, NSString *, UIImage *))block
{
    [self rawForKey:[self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:KVCahceTypeImage]] block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
        if (block) {
            UIImage *image = [UIImage imageWithData:object];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cache, key, image);
            });
        }
    }];

}


#pragma mark - 同步

- (void)setData:(NSData *)data forUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType
{
    [self setRaw:data forKey:[self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:cacheType]]];
}

- (NSData *)dataForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType
{
    return [self rawForKey:[self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:cacheType]]];
}

- (NSURL *)mp4URLForUrlKey:(NSURL *)urlKey
{
    return [self.diskCache fileURLForKey:[self cachedFileNameForUrlKey:urlKey extension:@".mp4"]];
}

- (void)setImage:(UIImage *)image forUrlKey:(NSURL *)urlKey
{
    [self setData:UIImageJPEGRepresentation(image, 0.5f) forUrlKey:urlKey cacheType:KVCahceTypeImage];
}

- (UIImage *)imageForUrlKey:(NSURL *)urlKey
{
    NSData *data = [self dataForUrlKey:urlKey cacheType:KVCahceTypeImage];
    if (data) {
        return [UIImage imageWithData:data];
    } else {
        return nil;
    }
}


//获取存储文件名
- (NSString *)getFileNameForUrlKey:(NSURL *)urlKey cacheType:(KVCacheType)cacheType
{
    return [self cachedFileNameForUrlKey:urlKey extension:[self extensionForCacheType:cacheType]];
}

- (void)removeObjectForKey:(NSString *)key
{
    [[PINCache sharedCache] removeObjectForKey:key];
}
- (void)removeAllObjects:(PINCacheBlock)block
{
    [[PINCache sharedCache] removeAllObjects:^(PINCache * _Nonnull cache) {
        block (cache);
    }];
}
- (void)removeAllObjects
{
    [[PINCache sharedCache] removeAllObjects];
}
@end

