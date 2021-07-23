//
//  AppDelegate.m
//  YSBannerView
//
//  Created by 宋屹 on 2021/7/22.
//

#import <UIKit/UIKit.h>
@protocol YSBannerViewDelegate <NSObject>
@required
-(UIView*)YSBannerViewChildViewWithFrame:(CGRect)bounds data:(id)data tag:(NSInteger)tag index:(NSInteger)index;
@optional
-(void)YSBannerViewDidSelectedViewIndex:(NSInteger)index data:(id)data tag:(NSInteger)tag;
@end

@interface YSBannerView : UIView

typedef NS_ENUM(NSUInteger, YSBannerViewDirection) {
    YSBannerViewLandscape,   //横的s
    YSBannerViewPortrait     //竖的
};
@property (nonatomic, strong)    UIPageControl* pageC;
@property (nonatomic, weak)      id<YSBannerViewDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame placeholderBGImage:(UIImage *)aPlaceholderBGImage currentPage:(NSInteger)currentPage showDataArr:(NSArray*)dataArray timeInterval:(NSTimeInterval)timeInterval direction:(YSBannerViewDirection)direction tag:(NSInteger)tag delegate:(id<YSBannerViewDelegate>)delegate;

//刷新数据
-(void)refreshData:(NSArray*)dataArray;
-(void)startTimer;  //打开定时器
-(void)stopTimer;   //关闭定时器
@end
