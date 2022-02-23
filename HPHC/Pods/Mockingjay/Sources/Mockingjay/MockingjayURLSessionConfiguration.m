//
//  MockingjayURLSessionConfiguration.m
//  Mockingjay
//
//  Created by Kyle Fuller on 10/05/2016.
//  Copyright © 2016 Cocode. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Mockingjay/Mockingjay-Swift.h>

#if __has_include("Mockingjay-Swift.h")
    #import "Mockingjay-Swift.h"
#else
    #import <Mockingjay-Swift.h/Mockingjay-Swift.h>
#endif

@interface MockingjayURLConfiguration : NSObject

@end

@implementation MockingjayURLConfiguration

+ (void)load {
    [NSURLSessionConfiguration mockingjaySwizzleDefaultSessionConfiguration];
}

@end
