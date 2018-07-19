//
//  MJExtensionExampleTests.m
//  MJExtensionExampleTests
//
//  Created by MJ Lee on 15/11/8.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MJExtension.h"

@interface TestModel : NSObject

@property (nonatomic) NSInteger p1;
@property (nonatomic) NSInteger p2;
@property (nonatomic) NSInteger p3;
@property (nonatomic) NSInteger p4;
@property (nonatomic) NSInteger p5;
@property (nonatomic) NSInteger p6;
@property (nonatomic) NSInteger p7;
@property (nonatomic) NSInteger p8;
@property (nonatomic) NSInteger p9;
@property (nonatomic) NSInteger p10;
@property (nonatomic) NSInteger p11;
@property (nonatomic) NSInteger p12;
@property (nonatomic) NSInteger p13;
@property (nonatomic) NSInteger p14;
@property (nonatomic) NSInteger p15;
@property (nonatomic) NSInteger p16;
@property (nonatomic) NSInteger p17;
@property (nonatomic) NSInteger p18;
@property (nonatomic) NSInteger p19;
@property (nonatomic) NSInteger p20;

@end

@implementation TestModel
@end

@interface MJExtensionExampleTests : XCTestCase
{
    NSArray* _testJsonArray;
}

@end

@implementation MJExtensionExampleTests

- (void)setUp {
    [super setUp];
    NSDictionary* dd = @{
                         @"p1":@"1",
                         @"p2":@"2",
                         @"p3":@"3",
                         @"p4":@"4",
                         @"p5":@"5",
                         @"p6":@"6",
                         @"p7":@"7",
                         @"p8":@"8",
                         @"p9":@"9",
                         @"p10":@"10",
                         @"p11":@"11",
                         @"p12":@"12",
                         @"p13":@"13",
                         @"p14":@"14",
                         @"p15":@"15",
                         @"p16":@"16",
                         @"p17":@"17",
                         @"p18":@"18",
                         @"p19":@"19",
                         @"p20":@"20"
                         };
    NSMutableArray* aa = [NSMutableArray arrayWithCapacity:2000];
    for (int i = 0; i < 2000; i++) {
        [aa addObject:dd];
    }
    _testJsonArray = aa;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFastPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [TestModel mj_objectArrayWithKeyValuesArray:_testJsonArray];
    }];
}

- (void)testSlowPerformance {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [TestModel mj_slowpath_objectArrayWithKeyValuesArray:_testJsonArray];
    }];
}

@end
