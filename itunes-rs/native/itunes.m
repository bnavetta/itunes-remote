@import Foundation
@import iTunesLibrary

@interface iTunes : NSObject
    @property ITLibrary* library;

    + (instancetype)sharedInstance;

@end

@implementation iTunes

- (instancetype)init {
    if (self = [super init])
    {
        NSError* error = nil;
        self.library = [ITLibrary libraryWithVersion:@"1.0" error:&error];
        if (self.library == nil)
        {
            NSLog(@"Library initialization failed: %@", [error localizedDescription]);
            self = nil
        }
    }
    return self;
}

+ (instancetype)sharedInstance {
    static iTunes* sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [self new];
        }
    }

    return sharedInstance;
}

@end
