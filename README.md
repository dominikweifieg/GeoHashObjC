GeoHashObjC
===========

GeoHash implementation in Objective-C for iOS and Mac OS X

About geohash:
==============

See http://en.wikipedia.org/wiki/Geohash

Usage: 
======

Encoding to geohash:
--------------------

- (NSString *) encodeGeohash:(CLLocationCoordinate2D) coordinate;
- (NSString *) encodeGeohash:(CLLocationCoordinate2D) coordinate withPrecision:(NSUInteger) precision;
- (NSString *) encodeGeohashFromLocation:(CLLocation*) location;
- (NSString *) encodeGeohashFromLocation:(CLLocation*) location withPrecision:(NSUInteger) precision;

These methods will return a geohash for the given coordinate/location. The methods with the precision parameter allow you to define the precision of the resulting geocode, the ones without that parameter use a precision of 12.

Decoding a geohash:
-------------------

- (GHLocationRect) decodeGeohash:(NSString *) geohash;
- (CLRegion *) decodeGeohashAsRegion:(NSString *) geohash;

Since a geohash does not denote a point but a square region, these methods do not return coordinates. The first method returns a GHLocationRect, which is a struct containing to CLLocationCoordinate2D entries, one for the north-eastern coordinate and one for the south-western coordinate. The method return a CLRegion transforms the GHLocationRect into a circular region of about the same size as the rectangle.

Expanding the size of a geohash:
--------------------------------

- (NSArray *) adjacentGeohashes:(NSString *) geohash includeSelf:(BOOL) include;

The resulting array will contain the geohashes which are adjacent to the given geohash. These will be 8 geohashes for north-east, north, north-west, west, south-west, south, south-east and east. If inculde is YES, the given geohosh will be included in the resulting array. 

For use with databases (without spatial search, e.g. DynamoDB):
---------------------------------------------------------------

In addition to the latitude and longitude values you should store the correspondin geohashes of the entries. The client can then compute the geohash for a location, find the adjacent geohashes and perform a search for those hashes on the database. The radius of the search can be controlled by the precision of the geohash. 

Credits: 
========

This implementation is based on https://github.com/davetroy/geohash-js by Dave Troy (https://github.com/davetroy)

