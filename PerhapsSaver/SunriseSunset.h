//
//  SunriseSunset.h
//  PerhapsThereIsSomethingLeftToSave
//
//  Created by Eric Li on 12/27/18.
//  Copyright © 2018 O-R-G. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SunriseSunset : NSObject {
    int sunriseValue;
    int sunsetValue;
    
    // VARIABLES FOR SUNRISE SUNSET
    double pie;
    double tpi;
    double degs;
    double rads;
    double L,g,daylen;
    double SunDia;
    double AirRefr;
    long gmtDelta;
    int longitude;
    int latitude;
}

- (int) checkTime;
- (void) start;

@end

NS_ASSUME_NONNULL_END
