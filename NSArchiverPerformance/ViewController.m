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

#define MIN(a, b)  (((a) < (b)) ? (a) : (b))
#define MAX(a,b) (((a) > (b)) ? (a) : (b))


#define kNumTestRuns (30)

static void archiverClassForIndex(int index, Class *outArchiver, Class *outUnarchiver)
{
    if (index % 3 == 0) {
        *outArchiver = [NSKeyedArchiver class];
        *outUnarchiver = [NSKeyedUnarchiver class];
    } else if (index % 3 == 1) {
        *outArchiver = [NSKeylessArchiver class];
        *outUnarchiver = [NSKeylessUnarchiver class];
    } else if (index % 3 == 2) {
        *outArchiver = [NSArchiver class];
        *outUnarchiver = [NSUnarchiver class];
    }
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
    // Get one and only document directory from that list
    NSString *docPath = [documentDirectories objectAtIndex:0];
    
    // first half of array is encoding time, second half is decoding
    float minTimes[6] = {INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX};
    float maxTimes[6] = {0};

    float totalTimes[6] = {0};
    int   countTimes[6] = {0};
    
    for (int i = 0; i < kNumTestRuns; i++) {
        // go back and forth between NSKeylessArchiver and NSKeyedArchiver
        Class archiverClass;
        Class unarchiverClass;
        archiverClassForIndex(i, &archiverClass, &unarchiverClass);
        
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
            
            int timesIndex = i % 3;
            minTimes[timesIndex + 0] = MIN(minTimes[timesIndex + 0], encodeSecs);
            minTimes[timesIndex + 3] = MIN(minTimes[timesIndex + 3], decodeSecs);
            
            maxTimes[timesIndex + 0] = MAX(maxTimes[timesIndex + 0], encodeSecs);
            maxTimes[timesIndex + 3] = MAX(maxTimes[timesIndex + 3], decodeSecs);
            
            totalTimes[timesIndex + 0] += encodeSecs;
            totalTimes[timesIndex + 3] += decodeSecs;

            countTimes[timesIndex + 0]++;
            countTimes[timesIndex + 3]++;
        } else {
            NSLog (@"%@ failed to decode", archiverClass);
        }
        
    }
    
    // use markdown table format for copy and paste into github readme
    NSLog(@"|               |encoding (min/max/avg secs)|decoding (min/max/avg secs)|");
    NSLog(@"|---------------|:-------------------------:|:-------------------------:|");
    // print out the stats
    for (int i = 0; i < 3; i ++) {
        Class archiverClass;
        Class unarchiverClass;
        archiverClassForIndex(i, &archiverClass, &unarchiverClass);
        float avgEnc = totalTimes[i + 0] / countTimes[i + 0];
        float avgDec = totalTimes[i + 3] / countTimes[i + 3];
        
        NSLog (@"|%@|  %.4f/%.4f/%.4f|  %.4f/%.4f/%.4f|", archiverClass, minTimes[i + 0], maxTimes[i + 0], avgEnc,
                                                                         minTimes[i + 3], maxTimes[i + 3], avgDec);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
