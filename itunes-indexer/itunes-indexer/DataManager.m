//
//  DataManager.m
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@property FMDatabaseQueue* dbQueue;

- (NSArray*)objectsWithResultSet:(FMResultSet*)rs ofType:(Class<DatabaseObject>)class;

@end

@implementation DataManager

- (instancetype)initWithPath:(NSString*)path;
{
    if (self = [super init])
    {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

- (void)dealloc
{
    [self.dbQueue close];
}

- (NSArray *)fetchObjectsOfClass:(Class<DatabaseObject>)cls withQueryBlock:(DatabaseQueryBlock)queryBlock
{
    __block NSArray* results = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet* rs = queryBlock(db);
        results = [self objectsWithResultSet:rs ofType:cls];
    }];
    return results;
}

- (void)executeUpdateInTransaction:(DatabaseUpdateBlock)updateBlock {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        *rollback = !updateBlock(db); // updateBlock returns YES for success
        if (*rollback)
        {
            NSLog(@"Database Error: %@", [db lastErrorMessage]);
        }
    }];
}

#pragma mark - Private Methods

- (NSArray*)objectsWithResultSet:(FMResultSet*)rs ofType:(Class<DatabaseObject>)class
{
    NSMutableArray* result = [NSMutableArray array];
    
    while ([rs hasAnotherRow])
    {
        [result addObject:[class objectFromResultSet:rs]];
    }
    
    return result;
}

@end
