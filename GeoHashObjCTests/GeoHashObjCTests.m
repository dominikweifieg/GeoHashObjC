//
//  GeoHashObjCTests.m
//  GeoHashObjCTests
//
//  Created by Dominik Wei-Fieg on 09.07.13.
//  Copyright (c) 2013 Ars Subtilior. All rights reserved.
//
//  Code is available for free distribution under the MIT License
//  Based on geohash.js : Geohash library for Javascript (c) 2008 David Troy

#import "GeoHashObjCTests.h"

#define muenster_lat 47.9955807
#define muenster_lng 7.8527893

@implementation GeoHashObjCTests

- (void)setUp
{
    [super setUp];
    
    self.geoHasher = [[GeoHashObjC alloc] init];
}

- (void)tearDown
{
    self.geoHasher = nil;
    
    [super tearDown];
}

- (void)testEncodeGeohash12
{
    CLLocationCoordinate2D muenster = CLLocationCoordinate2DMake(muenster_lat, muenster_lng);
    NSString *result = [self.geoHasher encodeGeohash:muenster];
    STAssertEqualObjects(result, @"u0t949q4x28n", @"Did encode to wrong geohash");
}

- (void)testEncodeGeohash8
{
    CLLocationCoordinate2D muenster = CLLocationCoordinate2DMake(muenster_lat, muenster_lng);
    NSString *result = [self.geoHasher encodeGeohash:muenster withPrecision:8];
    STAssertEqualObjects(result, @"u0t949q4", @"Did encode to wrong geohash");
}

- (void) testDecodeGeohash12
{
    GHLocationRect rect = [self.geoHasher decodeGeohash:@"u0t949q4x28n"];
//    NSLog(@"NE lat: %f, lng: %f; SW lat: %f, lng: %f", rect.ne.latitude, rect.ne.longitude, rect.sw.latitude, rect.sw.longitude);
    STAssertEqualsWithAccuracy(rect.ne.latitude, muenster_lat, 0.000001, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.ne.longitude, muenster_lng, 0.000001, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.sw.latitude, muenster_lat, 0.000001, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.sw.longitude, muenster_lng, 0.000001, @"Did decode wrong");
}

- (void) testDecodeGeohash8
{
    GHLocationRect rect = [self.geoHasher decodeGeohash:@"u0t949q4"];
//    NSLog(@"NE lat: %f, lng: %f; SW lat: %f, lng: %f", rect.ne.latitude, rect.ne.longitude, rect.sw.latitude, rect.sw.longitude);
    STAssertEqualsWithAccuracy(rect.ne.latitude, muenster_lat, 0.0004, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.ne.longitude, muenster_lng, 0.0004, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.sw.latitude, muenster_lat, 0.0004, @"Did decode wrong");
    STAssertEqualsWithAccuracy(rect.sw.longitude, muenster_lng, 0.0004, @"Did decode wrong");
}

- (void) testDecodeGeohashAsRegion
{
    CLRegion *region = [self.geoHasher decodeGeohashAsRegion:@"u0t949q4"];
    NSLog(@"Region: %@", region);
    STAssertEqualsWithAccuracy(region.center.latitude, muenster_lat, 0.0005, @"Wrong center lat");
    STAssertEqualsWithAccuracy(region.center.longitude, muenster_lng, 0.0005, @"Wrong center lng");
    STAssertEqualsWithAccuracy(region.radius, 16.0, 0.1, @"Wrong radius");
    STAssertEqualObjects(region.identifier, @"u0t949q4", @"Wrong identifier");
}

- (void) testAdjacentGeohashes8
{
    NSArray *result = [self.geoHasher adjacentGeohashes:@"u0t949q4" includeSelf:NO];
    NSArray *expected = @[@"u0t949mc",@"u0t949mf",@"u0t949mg",@"u0t949q1",@"u0t949q3",@"u0t949q5",@"u0t949q6",@"u0t949q7"];
    STAssertEqualObjects(result, expected, @"Wrong adjacent");
}

- (void) testAdjacentGeohashes8Include
{
    NSArray *result = [self.geoHasher adjacentGeohashes:@"u0t949q4" includeSelf:YES];
    NSArray *expected = @[@"u0t949mc",@"u0t949mf",@"u0t949mg",@"u0t949q1",@"u0t949q3",@"u0t949q4",@"u0t949q5",@"u0t949q6",@"u0t949q7"];
    STAssertEqualObjects(result, expected, @"Wrong adjacent");
}

- (void) testAdjacentGeohashes2
{
    NSArray *result = [self.geoHasher adjacentGeohashes:@"u0" includeSelf:NO];
    NSArray *expected = @[@"ez",@"gb",@"gc",@"sp",@"sr",@"u1",@"u2",@"u3"];
    STAssertEqualObjects(result, expected, @"Wrong adjacent");
}

- (void) testAdjacentGeohashes2Include
{
    NSArray *result = [self.geoHasher adjacentGeohashes:@"u0" includeSelf:YES];
    NSArray *expected = @[@"ez",@"gb",@"gc",@"sp",@"sr",@"u0",@"u1",@"u2",@"u3"];
    STAssertEqualObjects(result, expected, @"Wrong adjacent");
}

- (void) testAdjacentGeohashes1
{
    STAssertThrowsSpecificNamed([self.geoHasher adjacentGeohashes:@"u" includeSelf:NO], NSException, @"AdjacentGeohashComputeException",
                                @"GeoCodes with less than 2 characters should throw an exception");
    
}

- (void) testAdjacentGeohashes1Include
{
    STAssertThrowsSpecificNamed([self.geoHasher adjacentGeohashes:@"u" includeSelf:YES], NSException, @"AdjacentGeohashComputeException",
                                                                                                              @"GeoCodes with less than 2 characters should throw an exception");
}

@end
