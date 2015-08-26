//
//  DataManager.h
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

@import Foundation;
#import <FMDB/FMDB.h>

@protocol DatabaseObject <NSObject>

+ (NSString*)tableName;
+ (instancetype)objectFromResultSet:(FMResultSet*)rs;

@end

typedef FMResultSet*(^DatabaseQueryBlock)(FMDatabase* db);
typedef BOOL(^DatabaseUpdateBlock)(FMDatabase* db);

@interface DataManager : NSObject

- (instancetype)initWithPath:(NSString*)path;

- (void)executeUpdateInTransaction:(DatabaseUpdateBlock)updateBlock;

- (NSArray*)fetchObjectsOfClass:(Class<DatabaseObject>)cls withQueryBlock:(DatabaseQueryBlock)queryBlock;

@end
