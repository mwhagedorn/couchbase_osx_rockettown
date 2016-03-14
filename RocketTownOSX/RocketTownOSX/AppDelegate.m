//
//  AppDelegate.m
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/1/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import <CouchBaseLite/CouchBaseLite.h>
#import "ASDRocket.h"


//http://www.raywenderlich.com/17811/how-to-make-a-simple-mac-app-on-os-x-10-7-tutorial-part-13
@interface AppDelegate ()
    @property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;

@end

@implementation AppDelegate


-(void) awakeFromNib{
    [self setupCouchbase];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
   
    
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView*)self.window.contentView).bounds;

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



- (void)setupCouchbase {
    [[NSUserDefaults standardUserDefaults] setObject:@"Admin" forKey:kCBLPrefKeyUserID];
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    self.database = [manager databaseNamed:kDBName error: &error];
    
    if (error) {
        NSLog(@"error getting database %@",error);
        exit(-1);
    }
    
    [[self.database modelFactory] registerClass: [ASDRocket class] forDocumentType: [ASDRocket docType]];
    
    _cblSync = [[CBLSyncManager alloc] initSyncForDatabase:_database withURL:[NSURL URLWithString:kSyncUrl]];
    

    // Configure sync and trigger it if the user is already logged in.
    [self loginAndSync:^{
        [_cblSync start];
    }];
}

- (void)loginAndSync: (void (^)())complete {
    if (_cblSync.userID) {
        complete();
    } else {
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData, NSError **outError) {
            complete();
        }];
        [_cblSync start];
    }
}


@end
