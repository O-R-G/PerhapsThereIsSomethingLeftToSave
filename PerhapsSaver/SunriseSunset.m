//
//  SunriseSunset.m
//  PerhapsThereIsSomethingLeftToSave
//
//  Created by Eric Li on 12/27/18.
//  Copyright © 2018 O-R-G. All rights reserved.
//

#import "SunriseSunset.h"
#import <CoreLocation/CoreLocation.h>

@implementation SunriseSunset

- (int) checkTime {
    
    int currentHour, currentMin, currentHourMin;
    // GET TIME OBJECT
    time_t rawtime;
    struct tm * timeinfo;
    time ( &rawtime );
    timeinfo = localtime ( &rawtime );
    // PARSE TIME OBJECT TO VALUE BETWEEN 0-2359
    currentHour = (int) timeinfo->tm_hour;
    currentMin = (int) timeinfo->tm_min;
    currentHourMin = currentHour * 100 + currentMin;
    
    // basic bounds checking
    if ((sunriseValue > 0 && sunriseValue <= 2400) && (sunsetValue > 0 && sunsetValue <= 2400)) {
        if (currentHourMin >= sunriseValue && currentHourMin < sunsetValue)
        {
            // SET MODE TO SUN
            return 1;
        }
        if (currentHourMin < sunriseValue || currentHourMin >= sunsetValue)
        {
            // SET MODE TO MOON
            return 0;
        }
    }
    return -1;
}

#pragma mark sunrise/sunset
//////////////////////////////////////////////////////////////////
// SUNRISE AND SUNSET
//////////////////////////////////////////////////////////////////


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
    latitude = Fix2Long(latitudeFix*90);
    longitude = Fix2Long(longitudeFix*90);
    
    // GET GMT OFFSET AND DAYLIGHT SAVINGS
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation: location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        // NSLog(@"Timezone -%@",placemark.timeZone);
        self->gmtDelta = placemark.timeZone.secondsFromGMT/3600;

        // THIS COMPUTES SUNRISE AND SUNSET
        // NEED TO CAST LAT AND LONG TO DOUBLE
        // NEEDS A POSITIVE VALUE FOR LAT, LONG, GMT
        if (self->latitude < 0) self->latitude *= -1;
        if (self->longitude < 0) self->longitude *= -1;
        if (self->gmtDelta < 0) self->gmtDelta *= -1;
        
        [self computeSunriseSunset: (double)self->latitude : (double)self->longitude: (double)self->gmtDelta];
        
    }];
    
}


- (void) computeSunriseSunset: (double) latit : (double) longit : (double) tzone
{
    double y,m,day,h;
//    NSLog(@"Lat: %f, Long: %f, TZ: %f", latit, longit, tzone);
    
    // INIT VALUES
    sunriseValue = 0;
    sunsetValue = 2399;
    pie = M_PI;
    tpi = 2 * M_PI;
    degs = 180.0/M_PI;
    rads = M_PI/180.0;
    SunDia = 0.53;     // Sunradius degrees
    AirRefr = 34.0/60.0; // athmospheric refraction degrees //
    time_t sekunnit;
    struct tm *p;
    time(&sekunnit);
    p=localtime(&sekunnit);
    y = p->tm_year;
    y+= 1900;
    m = p->tm_mon + 1;
    day = p->tm_mday;
    h = 12;
    
    double d = [ self FNday: (int)y: (int)m: (int)day: h ];
    double lambda = [ self FNsun: d ];
    double obliq = 23.439 * rads - .0000004 * rads * d;
    double alpha = atan2(cos(obliq) * sin(lambda), cos(lambda));
    double delta = asin(sin(obliq) * sin(lambda));
    double LL = L - alpha;
    if (L < pie) LL += tpi;
    double equation = 1440.0 * (1.0 - LL / tpi);
    double ha = [ self f0: latit: delta ];
    double hb = [ self f1: latit: delta ];
    double twx = hb - ha;
    twx = 12.0 * twx/pie;
    daylen = degs * ha/7.5;
    if (daylen<0.0001) {daylen = 0.0;}
    double riset = 12.0 - 12.0 * ha/pie + tzone - longit/15.0 + equation/60.0;
    double settm = 12.0 + 12.0 * ha/pie + tzone - longit/15.0 + equation/60.0;
    double altmax = 90.0 + delta * degs - latit;
    if (latit < delta * degs) altmax = 180.0 - altmax;
    double twam = riset - twx;
    // UNUSED
    //double twpm = settm + twx;
    //double noont = riset + 12.0 * ha/pi;
    if (riset > 24.0) riset-= 24.0;
    if (settm > 24.0) settm-= 24.0;
    
    
    // SET GLOBAL SUNRISE AND SUNSET VALUES
    sunriseValue = [self getHrMnValue: twam];
    sunsetValue = [self getHrMnValue: settm];
//    NSLog(@"SUNRISE: %i, SUNSET %i", sunriseValue, sunsetValue);
}


- (double) FNday: (int) y : (int) m : (int) d : (float) h
{
    long int luku = - 7 * (y + (m + 9)/12)/4 + 275*m/9 + d;
    // type casting necessary on PC DOS and TClite to avoid overflow
    luku+= (long int)y*367;
    return (double)luku - 730531.5 + h/24.0;
}


- (double) FNrange: (double) x
{
    double b = x / tpi;
    double a = tpi * (b - (long)(b));
    if (a < 0) a = tpi + a;
    return a;
}


- (double) f0: (double) lat : (double) declin
{
    double fo,dfo;
    dfo = rads*(0.5*SunDia + AirRefr); if (lat < 0.0) dfo = -dfo;
    fo = tan(declin + dfo) * tan(lat*rads);
    if (fo>0.99999) fo=1.0; // to avoid overflow //
    fo = asin(fo) + pie/2.0;
    return fo;
}


- (double) f1 : (double) lat : (double) declin
{
    double fi,df1;
    // Correction: different sign at S HS
    df1 = rads * 6.0; if (lat < 0.0) df1 = -df1;
    fi = tan(declin + df1) * tan(lat*rads);
    if (fi>0.99999) fi=1.0; // to avoid overflow //
    fi = asin(fi) + pie/2.0;
    return fi;
}


- (double) FNsun: (double) d
{
    L = [ self FNrange: (280.461 * rads + .9856474 * rads * d) ];
    g = [ self FNrange: (357.528 * rads + .9856003 * rads * d) ];
    return [ self FNrange: (L + 1.915 * rads * sin(g) + .02 * rads * sin(2 * g)) ];
}

- (int) getHrMnValue: (double) dhr
{
    // THIS RETURNS AN INT 0-2400 TO USE FOR COMPARISON
    int hr,mn,hrmn;
    hr=(int) dhr;
    mn = (int) ((dhr - (double) hr)*60);
    hrmn = hr*100 + mn;
    return hrmn;
}

//////////////////////////////////////////////////////////////////
// END SUNRISE AND SUNSET
//////////////////////////////////////////////////////////////////


@end
