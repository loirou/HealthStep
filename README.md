# HealthStep
CMStepCounter获取健康数据今天的步数

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

查询当前步数
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

获取运动状态

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
