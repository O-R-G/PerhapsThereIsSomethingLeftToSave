//
//  MachineLocation.h
//  Perhaps There is Something Left to Save
//
//  Created by Eric Li on 8/11/19.
//  Copyright © 2019 O-R-G inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceLocation : NSObject {
    double longDouble;
    double latDouble;
}

- (void) start;
- (double) getLong;
- (double) getLat;

@end

NS_ASSUME_NONNULL_END
