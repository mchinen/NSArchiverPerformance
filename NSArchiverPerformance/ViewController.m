//
//  ViewController.m
//  NSKeylessArchiverPerformance
//
//  Created by Michael Chinen on 4/3/15.
//
//

#import "NSKeylessArchiver.h"
#import "NSKeylessUnarchiver.h"

#import "RootCodingObject.h"
#import "ViewController.h"

// there is no NSArchiver header, because it's private, so fake it

@interface NSArchiver : NSCoder
@end

@interface NSUnarchiver : NSCoder
@end


@interface ViewController ()

@end

#define kNumTestRuns (20)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
    // Get one and only document directory from that list
    NSString *docPath = [documentDirectories objectAtIndex:0];

    float totalTimes[3] = {0};
    int   countTimes[3] = {0};
    
    for (int i = 0; i < kNumTestRuns; i++) {
        // go back and forth between NSKeylessArchiver and NSKeyedArchiver
        Class archiverClass;
        Class unarchiverClass;
        if (i % 3 == 0) {
            archiverClass = [NSKeyedArchiver class];
            unarchiverClass = [NSKeyedUnarchiver class];
        } else if (i % 3 == 1) {
            archiverClass = [NSKeylessArchiver class];
            unarchiverClass = [NSKeylessUnarchiver class];
        } else if (i % 3 == 2) {
            archiverClass = [NSArchiver class];
            unarchiverClass = [NSUnarchiver class];
        }
        
        NSString *filePath = [docPath stringByAppendingPathComponent:[archiverClass description]];
        RootCodingObject *root = [[RootCodingObject alloc] init];
        
        NSDate *encodeStartTime = [NSDate date];
        BOOL ret = [archiverClass archiveRootObject:root
                                             toFile:filePath];
        if (!ret) {
            NSLog (@"%@ failed to encode", archiverClass);
            continue;
        }
        
        NSDate *decodeStartTime = [NSDate date];
        RootCodingObject *outRoot = [unarchiverClass unarchiveObjectWithFile:filePath];
        
        if (outRoot) {
            NSTimeInterval decodeSecs = [[NSDate date] timeIntervalSinceDate:decodeStartTime];
            NSTimeInterval encodeSecs = [decodeStartTime timeIntervalSinceDate:encodeStartTime];
            NSLog (@"%@ encoding time %f decoding time %f", archiverClass, encodeSecs, decodeSecs);
        } else {
            NSLog (@"%@ failed to decode", archiverClass);
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
