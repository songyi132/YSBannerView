//
//  ViewController.m
//  YSBannerView
//
//  Created by 宋屹 on 2021/7/22.
//

#import "ViewController.h"
#import "YSBannerView.h"
@interface ViewController ()<YSBannerViewDelegate>
@property(nonatomic,strong)NSArray * dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[@"1.jpeg",@"2.jpeg",@"3.jpeg",@"4.jpeg"];
    YSBannerView * bannerView = [[YSBannerView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 100) placeholderBGImage:nil currentPage:0 showDataArr:_dataArray timeInterval:3 direction:(YSBannerViewLandscape) tag:1000 delegate:self];
    [self.view addSubview:bannerView];
    
    

    bannerView = [[YSBannerView alloc] initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, 30) placeholderBGImage:nil currentPage:0 showDataArr:_dataArray timeInterval:3 direction:(YSBannerViewPortrait) tag:1000 delegate:self];
    [self.view addSubview:bannerView];

    // Do any additional setup after loading the view.
}

-(UIView*)YSBannerViewChildViewWithFrame:(CGRect)bounds data:(id)data tag:(NSInteger)tag index:(NSInteger)index{
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:data];
    imageView.bounds = bounds;
    return imageView;
}

-(void)YSBannerViewDidSelectedViewIndex:(NSInteger)index data:(id)data tag:(NSInteger)tag{
    NSLog(data);
}
@end
