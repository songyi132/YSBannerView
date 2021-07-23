//
//  AppDelegate.m
//  YSBannerView
//
//  Created by 宋屹 on 2021/7/22.
//

#import "YSBannerView.h"
@interface YSBannerView ()<UIScrollViewDelegate>
{
    NSArray* _viewArr;
    NSInteger _currentPage; //从 1 开始
    NSInteger _totalPage;
    NSTimeInterval _timeInterval;
    UIImageView *aPlaceholderBGImageView;
}


@property(nonatomic,strong)    NSTimer* timer;
@property(nonatomic,strong)    NSArray* dataArr;
@property(nonatomic)    YSBannerViewDirection direction;
@property(nonatomic,strong)    UIScrollView* scrollView;
@property(nonatomic,strong)UIView* singleView;

@end
@implementation YSBannerView
///可刷新加载数据
- (instancetype)initWithFrame:(CGRect)frame placeholderBGImage:(UIImage *)aPlaceholderBGImage currentPage:(NSInteger)currentPage showDataArr:(NSArray*)dataArray timeInterval:(NSTimeInterval)timeInterval direction:(YSBannerViewDirection)direction tag:(NSInteger)tag delegate:(id<YSBannerViewDelegate>)delegate{
    self=[super initWithFrame:frame];
    if (self) {
        _currentPage=currentPage;
        _totalPage=dataArray.count;
        _dataArr=dataArray;
        _delegate=delegate;
        _direction=direction;
        _timeInterval=timeInterval;
        self.tag=tag;
        
        if (dataArray.count > 0) {
            [self setScrollViewData:dataArray];
        }else if (aPlaceholderBGImage){
            aPlaceholderBGImageView = [[UIImageView alloc] initWithImage:aPlaceholderBGImage];
            aPlaceholderBGImageView.frame = self.bounds;
            [self addSubview:aPlaceholderBGImageView];
        }
    }
    return self;
}
- (void)refreshData:(NSArray*)dataArray{
    if (dataArray.count < 1) {
        return;
    }
    if (_scrollView) {
        [_scrollView removeFromSuperview];
        _scrollView = nil;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _viewArr = nil;
    _totalPage = dataArray.count;
    _dataArr = dataArray;
    _currentPage=0;
    
    [self setScrollViewData:dataArray];
}


-(void)setScrollViewData:(NSArray*)dataArray{
    [self.singleView removeFromSuperview];
    if (_dataArr.count==1) {
        self.singleView=[self.delegate YSBannerViewChildViewWithFrame:self.bounds data:_dataArr[0] tag:self.tag index:0];
        self.singleView.tag=0;//必须为零
        self.singleView.userInteractionEnabled=YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.singleView addGestureRecognizer:singleTap];
        [self insertSubview:self.singleView atIndex:0];
        
        _pageC.hidden=YES;
        
        if (aPlaceholderBGImageView) {
            [aPlaceholderBGImageView removeFromSuperview];
            aPlaceholderBGImageView = nil;
        }
        
        return;
    }
    if (_currentPage<0 || _currentPage>=_dataArr.count) {
        return;
    }

    self.scrollView=[[UIScrollView alloc]initWithFrame:self.bounds];
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.delegate=self;
    _scrollView.pagingEnabled=YES;
    _scrollView.scrollsToTop=NO;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    [self insertSubview:_scrollView atIndex:0];
    
    if (self.direction ==  YSBannerViewLandscape) {
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width*3, 0)];
        
        if (!_pageC) {
            _pageC=[[UIPageControl alloc]initWithFrame:CGRectZero];
            _pageC.numberOfPages=_totalPage;
            _pageC.currentPage=_currentPage;
            _pageC.enabled=NO;
            _pageC.currentPageIndicatorTintColor=[UIColor whiteColor];
            _pageC.pageIndicatorTintColor= [_pageC.currentPageIndicatorTintColor colorWithAlphaComponent:0.2];
            [self addSubview:_pageC];
        }

        CGSize size = [_pageC sizeForNumberOfPages:_pageC.numberOfPages];
        size.height=25;
        _pageC.frame=CGRectMake(self.frame.size.width-size.width-13, self.frame.size.height-size.height, size.width, size.height);
    }else if (self.direction ==  YSBannerViewPortrait){
        [_scrollView setContentSize:CGSizeMake(0, _scrollView.frame.size.height*3)];
        _scrollView.scrollEnabled=NO;
    }

    [self createTimer];
    [self refreshScrollView];
}

-(void)startTimer{
    _timer.fireDate=[NSDate dateWithTimeIntervalSinceNow:_timeInterval];

}
-(void)stopTimer{
    _timer.fireDate=[NSDate distantFuture];

}

-(void)createTimer{
    if (_timer == nil) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{
        [self startTimer];
    }
}
-(void)timerEvent{
    if (self.direction ==  YSBannerViewLandscape) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:YES];
    }else if (self.direction ==  YSBannerViewPortrait){
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.frame.size.height*2) animated:YES];
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.direction ==  YSBannerViewLandscape) {
        NSInteger x=(NSInteger)scrollView.contentOffset.x;
        NSInteger w=(NSInteger)(2*_scrollView.frame.size.width);
        if(x >= w) {
            _currentPage=[self validPageValue:_currentPage+1];
            [self refreshScrollView];
        }else if(x <= 0) {
            _currentPage=[self validPageValue:_currentPage-1];
            [self refreshScrollView];
        }
    }else if (self.direction ==  YSBannerViewPortrait){
        NSInteger y=(NSInteger)scrollView.contentOffset.y;
        NSInteger h=(NSInteger)(2*_scrollView.frame.size.height);
        if(y >= h) {
            _currentPage=[self validPageValue:_currentPage+1];
            [self refreshScrollView];
        }else if(y <= 0) {
            _currentPage=[self validPageValue:_currentPage-1];
            [self refreshScrollView];
        }
    }
}
-(void)refreshScrollView{
    for (UIView* view in _viewArr) {
        [view removeFromSuperview];
    }
    NSInteger pre = [self validPageValue:_currentPage-1];
    NSInteger last = [self validPageValue:_currentPage+1];
    _pageC.currentPage=_currentPage;
//    NSLog(@"%ld %d %d",(long)pre,_currentPage,last);
    
    if ([self.delegate respondsToSelector:@selector(YSBannerViewChildViewWithFrame:data:tag:index:)]) {
        UIView* leftView=[self.delegate YSBannerViewChildViewWithFrame:self.bounds data:_dataArr[pre] tag:self.tag index:pre];
        leftView.tag=pre;
        
        UIView* midView=[self.delegate YSBannerViewChildViewWithFrame:self.bounds data:_dataArr[_currentPage] tag:self.tag index:_currentPage];
        midView.tag=_currentPage;

        UIView* rightView=[self.delegate YSBannerViewChildViewWithFrame:self.bounds data:_dataArr[last] tag:self.tag index:last];
        rightView.tag=last;

        _viewArr=@[leftView,midView,rightView];
    }
    for (int i = 0; i < 3; i++) {
        UIView * view = [_viewArr objectAtIndex:i];
        if (self.direction ==  YSBannerViewLandscape) {
            view.frame = CGRectMake(_scrollView.frame.size.width*i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        }else if (self.direction ==  YSBannerViewPortrait){
            view.frame = CGRectMake(0, _scrollView.frame.size.height*i, _scrollView.frame.size.width, _scrollView.frame.size.height);
        }
        view.userInteractionEnabled=YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [view addGestureRecognizer:singleTap];
        [_scrollView addSubview:view];
    }

    if (self.direction ==  YSBannerViewLandscape) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }else if (self.direction ==  YSBannerViewPortrait){
        [_scrollView setContentOffset:CGPointMake(0, _scrollView.frame.size.height)];
    }
    
    if (aPlaceholderBGImageView) {
        [aPlaceholderBGImageView removeFromSuperview];
        aPlaceholderBGImageView = nil;
    }
}
-(void)handleTap:(UITapGestureRecognizer*)tap{
    if ([self.delegate respondsToSelector:@selector(YSBannerViewDidSelectedViewIndex:data:tag:)]) {
        [self.delegate YSBannerViewDidSelectedViewIndex:tap.view.tag data:_dataArr[tap.view.tag] tag:self.tag];
    }
}
-(NSInteger)validPageValue:(NSInteger)value{
    if (value >= _totalPage) value=0;
    if (value<0) value=_totalPage-1;
    return value;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}
- (void)willMoveToSuperview:(nullable UIView *)newSuperview{
    if (newSuperview==nil && self.superview) {
        self.delegate = nil;
        self.scrollView.delegate = nil;
        [_timer invalidate];
        _timer=nil;
    }
    [super willMoveToSuperview:newSuperview];

}
-(void)dealloc{
    [self qingli];
    
}
-(void)qingli{
    [_timer invalidate];
    _timer=nil;
    self.delegate = nil;
    self.scrollView.delegate = nil;
    self.scrollView = nil;
}
@end
