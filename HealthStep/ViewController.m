//
//  ViewController.m
//  HealthStep
//
//  Created by 刘东 on 16/4/11.
//  Copyright © 2016年 刘东. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
@interface ViewController ()
@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong)  UILabel *totalLabel;
@property (nonatomic, strong)  UILabel *stepsLabel;
@property (nonatomic, strong)  UILabel *statusLabel;
@property (nonatomic, strong)  UILabel *confidenceLabel;

@end


@implementation ViewController

/*
 关于m7协处理器 http://www.yangfei.me/post/2013-10-23-what-is-new-for-m7
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, 200, 30)];
    self.totalLabel.textAlignment = 1;
    [self.view addSubview:self.totalLabel];
    
    self.stepsLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 150, 200, 30)];
    self.stepsLabel.textAlignment = 1;
    [self.view addSubview:self.stepsLabel];
    
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 200, 200, 30)];
    self.statusLabel.textAlignment = 1;
    [self.view addSubview:self.statusLabel];
    
    self.confidenceLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 250, 200, 30)];
    self.confidenceLabel.textAlignment = 1;
    [self.view addSubview:self.confidenceLabel];
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    if (!([CMStepCounter isStepCountingAvailable] || [CMMotionActivityManager isActivityAvailable])) {
        
        NSString *msg = @"sorry，不能运行哦,这demo只支持iPhone5s以上机型.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Opps!"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        [self getMomentStep];
        [self getTodayStep];
        [self getActivity];
    }
}
/*
 计步 第一种方法
 
 startStepCountingUpdatesToQueue:updateOn:withHandler:
 开始分发当前步数计数数据到第三方应用
 
 - (void)startStepCountingUpdatesToQueue:(NSOperationQueue *)queue updateOn:(NSInteger)stepCounts withHandler:(CMStepUpdateHandler)handler
 Parameters
 
 queue
 
 被指定执行特定的handler块的操作队列。第三方可以指定一个定制队列或者使用操作队列协助app的主线程。该参数不能为nil
 
 stepCounts
 
 记录的步伐数据，达到该数值去执行handler块。该数值必须大于0
 
 handler
 
 该块在步伐计数达到或超出数值时会被执行，该参数不能为nil。更多块方法信息参考CMStepQueryHandler。
 
 Discussion
 
 该方法实现对用户步伐数据的追踪，并周期性地唤起块方法去分发结果。当第三方调用了该方法，步伐计数器会重置当前步伐数为0，并开始计数。每次计数到达指定的步伐数时，会执行指定的handler块方法。比如，当设定stepCounts为100时，会在100，200，300等数目时发送更新，激活该块方法。每次发送到该块方法的步伐数目都是从你调用该方法开始的步伐数目总和。
 
 每次超过设定步数值时，指定的处理程序块handler会被执行。如果当超过设定值时第三方应用处在被挂起的状态，那程序块也不会被执行。当第三方应用被唤醒，程序块也不会执行，直到再次超过设定步数值。
 
 可以调用stopStepCountingUpdates方法去停止分发步数计数，当然当步数计数对像被销毁的时候，分发过程也会被停止
 
 */

-(void)getMomentStep{
    __weak ViewController *weakSelf = self;
    
    if ([CMStepCounter isStepCountingAvailable]) {
        
        self.stepCounter = [[CMStepCounter alloc] init];
        [self.stepCounter startStepCountingUpdatesToQueue:self.operationQueue
                                                 updateOn:1
                                              withHandler:
         ^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [error show];
                 }
                 else {
                     
                     NSString *text = [NSString stringWithFormat:@"当前步数: %ld", (long)numberOfSteps];
                     //这里是步数
                     weakSelf.stepsLabel.text = text;
                 }
             });
         }];
    }
}

/*
 计步 第二种方法
 
 queryStepCountStartingFrom:to:toQueue:withHandler:
 
 收集并返回某一时间段内的历史步数数据
 
 - (void)queryStepCountStartingFrom:(NSDate *)start to:(NSDate *)end toQueue:(NSOperationQueue *)queuewithHandler:(CMStepQueryHandler)handler
 Parameters
 
 start
 
 收集步数数据的开始时间，该参数不能为 nil.
 
 end
 
 收集步数数据的停止时间，该参数不能为nil.
 
 queue
 
 执行指定handler块的操作队列，第三方可以指定一个定制队列或者使用操作队列协助app的主线程。该参数不能为nil
 
 handler
 
 执行处理结果的块方法，该参数不能为nil。更多块方法信息参考CMStepQueryHandler。
 
 Discussion
 
 该方法为异步方法，会立即返回并且把结果分发到指定的handler块中处理。系统最多仅存储最近7天内的有效步数数据。如果在指定时间范围内没有数据，则会传递一个0值到handler块中。
 */

-(void)getTodayStep{
    
    __weak ViewController *weakSelf = self;
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    // 开始日期
    NSDate *startDate = [calendar dateFromComponents:components];
    // 结束日期
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        //只走一遍,不会实时刷新
        [self.stepCounter  queryStepCountStartingFrom:startDate to:endDate toQueue:self.operationQueue withHandler:^(NSInteger numberOfSteps, NSError * _Nullable error) {
            NSLog(@"%ld",numberOfSteps);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Opps!" message:@"error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [error show];
                }
                else {
                    weakSelf.totalLabel.text = [NSString stringWithFormat:@"今日总步数%ld",numberOfSteps];
                }
            });
        }];
    }
    
}

/*
 
 CMMotionActivity
 
 此对象包含了运动事件的数据。在支持动作识别的设备上，你可以使用 CMMotionActivityManager 去查询当前运动状态的改变。当运动状态改变发生时，更新的信息会被打包成 CMMotionActivity 对象，并发给到你的 app。
 
 运动类型：
 
 stationary 静止
 walking 走路
 running 跑步
 automotive 开车
 unknown 未知
 
 运动数据:
 
 startDate 运动的开始时间
 confidence 运动强度
 
 */

-(void)getActivity{
    __weak ViewController *weakSelf = self;
    
    if ([CMMotionActivityManager isActivityAvailable]) {
        
        self.activityManager = [[CMMotionActivityManager alloc] init];
        
        [self.activityManager startActivityUpdatesToQueue:self.operationQueue
                                              withHandler:
         ^(CMMotionActivity *activity) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSString *status = [weakSelf statusForActivity:activity];
                 NSString *confidence = [weakSelf stringFromConfidence:activity.confidence];
                 
                 weakSelf.statusLabel.text = [NSString stringWithFormat:@"状态: %@", status];
                 weakSelf.confidenceLabel.text = [NSString stringWithFormat:@"速度: %@", confidence];
             });
         }];
    }
    
    
}

- (NSString *)statusForActivity:(CMMotionActivity *)activity {
    
    NSMutableString *status = @"".mutableCopy;
    
    if (activity.stationary) {
        
        [status appendString:@"not moving"];
    }
    
    if (activity.walking) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a walking person"];
    }
    
    if (activity.running) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"on a running person"];
    }
    
    if (activity.automotive) {
        
        if (status.length) [status appendString:@", "];
        
        [status appendString:@"in a vehicle"];
    }
    
    if (activity.unknown || !status.length) {
        
        [status appendString:@"unknown"];
    }
    
    return status;
}

- (NSString *)stringFromConfidence:(CMMotionActivityConfidence)confidence {
    
    switch (confidence) {
            
        case CMMotionActivityConfidenceLow:
            
            return @"Low";
            
        case CMMotionActivityConfidenceMedium:
            
            return @"Medium";
            
        case CMMotionActivityConfidenceHigh:
            
            return @"High";
            
        default:
            
            return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
