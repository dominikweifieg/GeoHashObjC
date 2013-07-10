//
//  GeoHashObjC.m
//  GeoHashObjC
//
//  Created by Dominik Wei-Fieg on 09.07.13.
//  Copyright (c) 2013 Ars Subtilior. All rights reserved.
//
//  Code is available for free distribution under the MIT License
//  Based on geohash.js : Geohash library for Javascript (c) 2008 David Troy

#import "GeoHashObjC.h"

int GH_BITS[] = {16,8,4,2,1};

#define GH_RIGHT @"right"
#define GH_LEFT @"left"
#define GH_TOP @"top"
#define GH_BOTTOM @"bottom"
#define GH_ODD @"odd"
#define GH_EVEN @"even"

@interface GeoHashObjC (Private)

@end

//NEIGHBORS = { right  : { even :  "bc01fg45238967deuvhjyznpkmstqrwx" },
//    left   : { even :  "238967debc01fg45kmstqrwxuvhjyznp" },
//    top    : { even :  "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
//    bottom : { even :  "14365h7k9dcfesgujnmqp0r2twvyx8zb" } };
//BORDERS   = { right  : { even : "bcfguvyz" },
//    left   : { even : "0145hjnp" },
//    top    : { even : "prxz" },
//    bottom : { even : "028b" } };

@implementation GeoHashObjC

NSString *_gh_base_32;
NSDictionary *_neighbours;
NSDictionary *_borders;

- (id) init
{
    self = [super init];
    if (self) {
        _gh_base_32 = @"0123456789bcdefghjkmnpqrstuvwxyz";
        _neighbours = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSDictionary dictionaryWithObjectsAndKeys:@"bc01fg45238967deuvhjyznpkmstqrwx", GH_EVEN,
                            @"p0r21436x8zb9dcf5h7kjnmqesgutwvy", GH_ODD, nil], GH_RIGHT,
                           [NSDictionary dictionaryWithObjectsAndKeys:@"238967debc01fg45kmstqrwxuvhjyznp", GH_EVEN,
                            @"14365h7k9dcfesgujnmqp0r2twvyx8zb", GH_ODD, nil], GH_LEFT,
                           [NSDictionary dictionaryWithObjectsAndKeys:@"p0r21436x8zb9dcf5h7kjnmqesgutwvy", GH_EVEN,
                            @"bc01fg45238967deuvhjyznpkmstqrwx", GH_ODD, nil], GH_TOP,
                           [NSDictionary dictionaryWithObjectsAndKeys:@"14365h7k9dcfesgujnmqp0r2twvyx8zb", GH_EVEN,
                            @"238967debc01fg45kmstqrwxuvhjyznp", GH_ODD, nil], GH_BOTTOM,
                           nil];
        _borders = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSDictionary dictionaryWithObjectsAndKeys:@"bcfguvyz", GH_EVEN,
                        @"prxz", GH_ODD, nil], GH_RIGHT,
                        [NSDictionary dictionaryWithObjectsAndKeys:@"0145hjnp", GH_EVEN,
                         @"028b", GH_ODD, nil], GH_LEFT,
                        [NSDictionary dictionaryWithObjectsAndKeys:@"prxz", GH_EVEN,
                         @"bcfguvyz", GH_ODD, nil], GH_TOP,
                        [NSDictionary dictionaryWithObjectsAndKeys:@"028b", GH_EVEN,
                         @"0145hjnp", GH_ODD, nil], GH_BOTTOM,
                        nil];
    }
    return self;
}

- (GHLocationRect) decodeGeohash:(NSString *)geohash
{
    GHLocationRect result = {};

    BOOL even = YES;
    double lat[2] = {-90.0, 90.0};
    double lng[2] = {-180.0, 180.0};
    double lat_err = 90.0;
    double lng_err = 180.0;
    
    NSUInteger length = [geohash length];
    for (int i=0; i<length; i++) {
        NSString *c = [geohash substringWithRange:NSMakeRange(i, 1)];
        int cd = [_gh_base_32 rangeOfString:c].location;
        for (int j=0; j<5; j++) {
            int mask = GH_BITS[j];
            if (even) {
                lng_err /= 2;
                [self refineIntervalForLongitude:lng location:cd andMask:mask];
            } else {
                lat_err /= 2;
                [self refineIntervalForLongitude:lat location:cd andMask:mask];
            }
            even = !even;
        }
        
    }
    
    result.ne = CLLocationCoordinate2DMake(lat[0], lng[0]);
    result.sw = CLLocationCoordinate2DMake(lat[1], lng[1]);
    
    return result;
}

- (CLRegion *) decodeGeohashAsRegion:(NSString *) geohash
{
    GHLocationRect rect = [self decodeGeohash:geohash];
    double lat = rect.ne.latitude + (rect.sw.latitude - rect.ne.latitude);
    double lng = rect.ne.longitude + (rect.sw.longitude - rect.ne.longitude);
    CLLocationDistance dist = [[[CLLocation alloc] initWithLatitude:lat longitude:lng] distanceFromLocation:[[CLLocation alloc] initWithLatitude:rect.ne.latitude longitude:rect.ne.longitude]];
    CLRegion *result = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(lat, lng) radius:dist/2 identifier:geohash];
    return result;
}

- (void) refineIntervalForLongitude:(double *) interval location:(int) cd andMask:(int) mask
{
    if (cd&mask)
		interval[0] = (interval[0] + interval[1])/2;
    else
		interval[1] = (interval[0] + interval[1])/2;
}

- (NSString *) encodeGeohash:(CLLocationCoordinate2D)coordinate
{
    return [self encodeGeohash:coordinate withPrecision:12];
}

- (NSString *) encodeGeohash:(CLLocationCoordinate2D)coordinate withPrecision:(NSUInteger) precision
{
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:precision];
    BOOL even = YES;
    int bit = 0;
    int ch = 0;
    
    
    double lat[2] = {-90.0, 90.0};
    double lng[2] = {-180.0, 180.0};

    while (result.length < precision) {
        if (even) {
            double mid = (lng[0] + lng[1]) / 2;
            if (coordinate.longitude > mid) {
                ch |= GH_BITS[bit];
                lng[0] = mid;
            } else {
                lng[1] = mid;
            }
        } else {
            double mid = (lat[0] + lat[1]) / 2;
            if (coordinate.latitude > mid) {
                ch |= GH_BITS[bit];
                lat[0] = mid;
            } else {
                lat[1] = mid;
            }
        }
        even = !even;
    if (bit < 4) {
        bit++;
    } else
    {
        [result appendString:[_gh_base_32 substringWithRange:NSMakeRange(ch, 1)]];
        bit = 0;
        ch = 0;
    }
    }
    
    return result;
}

- (NSString *) encodeGeohashFromLocation:(CLLocation *)location
{
    return [self encodeGeohash:location.coordinate];
}

- (NSString *) encodeGeohashFromLocation:(CLLocation *)location withPrecision:(NSUInteger)precision
{
    return [self encodeGeohash:location.coordinate withPrecision:precision];
}

- (NSString *) calculateAdjacent:(NSString *) geohash direction:(NSString *) direction
{
    NSUInteger precision = geohash.length;
    NSString *result = nil;
    NSString *lcGeoHash = [geohash lowercaseString];
    NSString *lastChar = [lcGeoHash substringWithRange:NSMakeRange(precision - 1, 1)];
    NSString *type = precision % 2 ? GH_ODD : GH_EVEN;
    NSString *base = [lcGeoHash substringWithRange:NSMakeRange(0, precision - 1)];
    if ([[[_borders objectForKey:direction] objectForKey:type] rangeOfString:lastChar].location != NSNotFound) {
        base = [self calculateAdjacent:base direction:direction];
    }
    NSUInteger index = [[[_neighbours objectForKey:direction] objectForKey:type] rangeOfString:lastChar].location;
    result = [NSString stringWithFormat:@"%@%@", base, [_gh_base_32 substringWithRange:NSMakeRange(index, 1)]];
    return result;
    
}

- (NSArray *) adjacentGeohashes:(NSString *)geohash includeSelf:(BOOL)include
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:9];
    if (include) {
        [result addObject:geohash];
    }
    NSString *left = [self calculateAdjacent:geohash direction:GH_LEFT];
    NSString *right = [self calculateAdjacent:geohash direction:GH_RIGHT];
    [result addObject:left];
    [result addObject:right];
    [result addObject:[self calculateAdjacent:geohash direction:GH_TOP]];
    [result addObject:[self calculateAdjacent:geohash direction:GH_BOTTOM]];
    [result addObject:[self calculateAdjacent:left direction:GH_TOP]];
    [result addObject:[self calculateAdjacent:left direction:GH_BOTTOM]];
    [result addObject:[self calculateAdjacent:right direction:GH_TOP]];
    [result addObject:[self calculateAdjacent:right direction:GH_BOTTOM]];
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    return result;
}



@end
