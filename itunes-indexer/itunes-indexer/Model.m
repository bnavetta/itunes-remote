//
//  Model.m
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import "Model.h"

@implementation Artist

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        self.name = name;
    }
    return self;
}

#pragma mark - DatabaseObject

+ (NSString *)tableName
{
    return @"artist";
}

+ (instancetype)objectFromResultSet:(FMResultSet *)rs
{
    return [[Artist alloc] initWithName:[rs stringForColumn:@"name"]];
}

@end