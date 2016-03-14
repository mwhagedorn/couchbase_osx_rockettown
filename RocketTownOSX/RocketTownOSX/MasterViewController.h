//
//  MasterViewController.h
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/1/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CouchBaseLite/CouchBaseLite.h>

@interface MasterViewController : NSViewController
  @property (strong, nonatomic) CBLDatabase *database;

  @property (weak) IBOutlet NSTableView *rocketsTableView;
  @property (weak) IBOutlet NSTextField *rocketNameView;
  @property (weak) IBOutlet NSTextField *rocketDiameterView;
  @property (weak) IBOutlet NSTextField *rocketWeightView;
  @property (weak) IBOutlet NSTextField *rocketCoefficientView;

- (IBAction)addRocket:(id)sender;
- (IBAction)deleteRocket:(id)sender;
@end
