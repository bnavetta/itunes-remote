//
//  Model.h
//  itunes-indexer
//
//  Created by Ben Navetta on 8/25/15.
//  Copyright © 2015 Ben Navetta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"

@interface Artist : NSObject <DatabaseObject>

@property NSString* name;

- (instancetype)initWithName:(NSString*)name;

@end