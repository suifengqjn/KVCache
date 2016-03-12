//
//  ViewController.m
//  KVCahce
//
//  Created by qianjianeng on 16/3/12.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "ViewController.h"
#import "KVCache.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     NSURL *mageURL = [[NSURL alloc] initWithString:@"http://img1.cache.netease.com/catchpic/0/09/091F3F78A45BD8CFB388E9B0699E4044.jpg"];
    
    
    
    [[KVCache sharedInstance] objectForKey:[mageURL absoluteString]
 block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
     
     if (object) {
         [self setImageOnMainThread:(UIImage *)object];
         return;
     }
     
     NSURLResponse *response = nil;
     NSURLRequest *request = [NSURLRequest requestWithURL:mageURL];
     NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
     
     UIImage *image = [[UIImage alloc] initWithData:data scale:[[UIScreen mainScreen] scale]];
     [self setImageOnMainThread:image];
     
     [[KVCache sharedCache] setData:data forUrlKey:mageURL cacheType:KVCahceTypeImage block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
         
     }];
 }];
    
 
    [self location];
    
}


- (void)location
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    NSLog(@"--%@", document);
}

- (void)setImageOnMainThread:(UIImage *)image
{
    if (!image)
        return;
    
    NSLog(@"setting view image %@", NSStringFromCGSize(image.size));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageview.image = image;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
