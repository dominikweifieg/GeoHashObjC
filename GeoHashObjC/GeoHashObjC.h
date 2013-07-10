//
//  GeoHashObjC.h
//  GeoHashObjC
//
//  Created by Dominik Wei-Fieg on 09.07.13.
//  Copyright (c) 2013 Ars Subtilior. All rights reserved.
//
//  Code is available for free distribution under the MIT License
//  Based on geohash.js : Geohash library for Javascript (c) 2008 David Troy

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef struct {
    CLLocationCoordinate2D ne;
    CLLocationCoordinate2D sw;
} GHLocationRect;

@interface GeoHashObjC : NSObject

- (GHLocationRect) decodeGeohash:(NSString *) geohash;
- (CLRegion *) decodeGeohashAsRegion:(NSString *) geohash;
- (NSString *) encodeGeohash:(CLLocationCoordinate2D) coordinate;
- (NSString *) encodeGeohash:(CLLocationCoordinate2D) coordinate withPrecision:(NSUInteger) precision;
- (NSString *) encodeGeohashFromLocation:(CLLocation*) location;
- (NSString *) encodeGeohashFromLocation:(CLLocation*) location withPrecision:(NSUInteger) precision;

- (NSArray *) adjacentGeohashes:(NSString *) geohash includeSelf:(BOOL) include;


@end
