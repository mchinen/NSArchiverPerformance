//
//  RootCodingObject.m
//  NSArchiverPerformance
//
//  Created by Michael Chinen on 4/3/15.
//
//

#import <Foundation/Foundation.h>

#import "RootCodingObject.h"

#define kNumInts 20000

@implementation RootCodingObject

- (void)encodeWithCoder:(NSCoder *)encoder
{
    for (int i = 0; i < kNumInts; i++) {
        [encoder encodeValueOfObjCType:@encode(int) at:&i];
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        int temp;
        for (int i = 0; i < kNumInts; i++) {
            [decoder decodeValueOfObjCType:@encode(int) at:&temp];
            if (i != temp) {
                NSLog(@"ERROR: %i int did not match - decoded value was %i", i, temp);
                return nil;
            }
        }
        
    }
    return self;
}

@end
