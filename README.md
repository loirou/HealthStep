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
