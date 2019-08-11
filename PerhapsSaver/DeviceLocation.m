//
//  MachineLocation.m
//  Perhaps There is Something Left to Save
//
//  Created by Eric Li on 8/11/19.
//  Copyright © 2019 O-R-G inc. All rights reserved.
//

#import "DeviceLocation.h"
#import <CoreLocation/CoreLocation.h>

@implementation DeviceLocation

- (double) getLong {
    return longDouble;
}

- (double) getLat {
    return latDouble;
}

- (void) start
{
    MachineLocation loc;
    
    // READ MACHINE LOCATION FROM PRAM
    ReadLocation ( &loc );
    
    // GET LATITUDE AND LONGITUDE
    // CONVERT TO USEABLE DEGREE FORMAT
    // INTO AN INTEGER (ROUNDED) FORMAT
    // MULTIPLYING BY 900 IS MORE PRECISE
    Fixed latitudeFix = Frac2Fix(loc.latitude);
    Fixed longitudeFix = Frac2Fix(loc.longitude);
    latDouble = Fix2Long(latitudeFix*90);
    longDouble = Fix2Long(longitudeFix*90);
    
    // GET GMT OFFSET AND DAYLIGHT SAVINGS
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
//    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
//    [geoCoder reverseGeocodeLocation: location completionHandler:^(NSArray *placemarks, NSError *error)
//     {
//         CLPlacemark *placemark = [placemarks objectAtIndex:0];
//         // NSLog(@"Timezone -%@",placemark.timeZone);
//         self->gmtDelta = placemark.timeZone.secondsFromGMT/3600;
//
//         // THIS COMPUTES SUNRISE AND SUNSET
//         // NEED TO CAST LAT AND LONG TO DOUBLE
//         // NEEDS A POSITIVE VALUE FOR LAT, LONG, GMT
//         if (self->latitude < 0) self->latitude *= -1;
//         if (self->longitude < 0) self->longitude *= -1;
//         if (self->gmtDelta < 0) self->gmtDelta *= -1;
//
//         [self computeSunriseSunset: (double)self->latitude : (double)self->longitude: (double)self->gmtDelta];
//
//
//     }];
    
}

@end
