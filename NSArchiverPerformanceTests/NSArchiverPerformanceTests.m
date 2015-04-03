//
//  NSArchiverPerformanceTests.m
//  NSArchiverPerformanceTests
//
//  Created by Michael Chinen on 4/3/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface NSArchiverPerformanceTests : XCTestCase

@end

@implementation NSArchiverPerformanceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
