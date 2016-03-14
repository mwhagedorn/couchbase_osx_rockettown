//
//  MasterViewController.m
//  RocketTownOSX
//
//  Created by Mike Hagedorn on 3/1/16.
//  Copyright © 2016 Mike Hagedorn. All rights reserved.
//

#import "MasterViewController.h"
#import "ASDRocket.h"
#import "AppDelegate.h"


typedef NS_ENUM (NSInteger, SSSActionType) {
    ColumnTagName= 10,
    ColumnTagWeight= 20,
    ColumnTagDiameter= 30,
    ColumnTagCoeff=40,
};

@interface MasterViewController ()
{
   
    AppDelegate *app;
    CBLLiveQuery *rocketsQuery;
}
@end



@implementation MasterViewController

-(void) viewDidLoad{
    app = (AppDelegate *)[NSApp delegate];
    self.database = app.database;
    
    rocketsQuery = [ASDRocket queryRocketsInDatabase:_database].asLiveQuery;
    [rocketsQuery start];
    [rocketsQuery waitForRows];
   
    
}


- (void)viewWillAppear {
    [rocketsQuery addObserver:self
                   forKeyPath:@"rows"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
}


- (void)viewWillDisappear{
    @try{
        [rocketsQuery removeObserver:self forKeyPath:@"rows"];
    }
    @catch (NSException * __unused exception) {}


}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];


    CBLQueryRow *docrow =  [rocketsQuery.rows rowAtIndex:row];
    ASDRocket *rocket= [ASDRocket modelForDocument:docrow.document];
    if( [tableColumn.identifier isEqualToString:@"NameColumn"] )
    {
      cellView.textField.stringValue = rocket.name;
      return cellView;
    }

    if( [tableColumn.identifier isEqualToString:@"WeightColumn"] )
    {

      cellView.textField.stringValue = [NSString stringWithFormat:@"%f", rocket.weight];
      return cellView;
    }

    if( [tableColumn.identifier isEqualToString:@"DiameterColumn"] )
    {

      cellView.textField.stringValue = [NSString stringWithFormat:@"%f", rocket.diameter];
      return cellView;
    }

    if( [tableColumn.identifier isEqualToString:@"CDColumn"] )
    {

      cellView.textField.stringValue = [NSString stringWithFormat:@"%f", rocket.coefficientFriction];
      return cellView;
    }



    return cellView;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
  ASDRocket *selectedRocket = [self selectedRocket];

  // Update info
  [self setDetailInfo:selectedRocket];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self itemCount];
}

- (NSInteger) itemCount{
    return rocketsQuery.rows.count;
}

- (IBAction)addRocket:(id)sender {
    NSAssert(self.database, @"No Database set");
    ASDRocket *newRocket = [ASDRocket modelForNewDocumentInDatabase:self.database];
    
    
    newRocket.name=[NSString stringWithFormat:@"alpha%i",[self itemCount]+100];
    newRocket.weight = 23.0;
    newRocket.diameter = 25.0;
    newRocket.coefficientFriction = 0.75;
    
    NSError* error;
    
    if (![newRocket save: &error]) {
        NSLog(@"could not save rocket");
    }
    
    NSInteger newRowIndex = [self itemCount]-1;

    [self.rocketsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
    [self.rocketsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] byExtendingSelection:NO];
    [self.rocketsTableView scrollRowToVisible:newRowIndex];

}
- (IBAction)deleteRocket:(id)sender {
    ASDRocket *selectedRocket = [self selectedRocket];
    if (selectedRocket)
    {
        NSError* error;
        if (![selectedRocket deleteDocument: &error]){
            NSLog(@"Unable to delete Rocket");
            return;
        }
        [self.rocketsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.rocketsTableView.selectedRow] withAnimation:NSTableViewAnimationSlideRight];
    }
    
    
}

-(ASDRocket*)selectedRocket
{
    NSInteger selectedRow = [self.rocketsTableView selectedRow];
    if( selectedRow >=0 && [rocketsQuery.rows count] > selectedRow )
    {
        CBLQueryRow *docrow =  [rocketsQuery.rows rowAtIndex:selectedRow];
        ASDRocket *selectedRocket = [ASDRocket modelForDocument:docrow.document];

        return selectedRocket;
    }
    return nil;
    
}

-(void)setDetailInfo:(ASDRocket*)rocket
{

  NSString  *theName = @"";
  NSNumber *theWeight = [NSNumber numberWithDouble:0.0];
  NSNumber *theDiameter = [NSNumber numberWithDouble:0.0];;
  NSNumber *theCoefficient =[NSNumber numberWithDouble:0.0];;

  if( rocket != nil )
  {
    theName = rocket.name;
    theDiameter = [NSNumber numberWithDouble:rocket.diameter];
    theWeight = [NSNumber numberWithDouble:rocket.weight];
    theCoefficient = [NSNumber numberWithDouble:rocket.coefficientFriction];
  }


  [self.rocketNameView setStringValue:theName];
  [self.rocketDiameterView setStringValue:[NSString stringWithFormat:@"%@", theDiameter] ];
  [self.rocketWeightView setStringValue:[NSString stringWithFormat:@"%@", theWeight] ];
  [self.rocketCoefficientView setStringValue:[NSString stringWithFormat:@"%@", theCoefficient] ];

}

/* called when the liveQuery.rows gets changed */
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    
    if([keyPath isEqualToString:@"rows"]) {
        NSLog(@"Rows Changed");
        NSLog(@"rows count is %lu", rocketsQuery.rows.count );
        [self.rocketsTableView reloadData];
    }
}

-(NSUInteger) indexOfRocket:(ASDRocket *)rocket{
  NSUInteger rowIndex = -1;
  bool found = NO;
  for(CBLQueryRow* row in rocketsQuery.rows)
  {
    rowIndex+=1;
    if (row.documentID == rocket.document.documentID){
      NSLog(@"found rocket in livequery");
      found = YES;
      return rowIndex;
    }
  }
  if (!found){
     return -1;
  }
  return rowIndex;
}

- (IBAction)rocketNameDidEndEdit:(id)sender {
    ASDRocket *selectedRocket = [self selectedRocket];
    if (selectedRocket)
    {
        // 2. Get the new name from the text field
        selectedRocket.name = [self.rocketNameView stringValue];

        NSError* error;

        if (![selectedRocket save: &error]) {
          NSLog(@"could not save rocket");
          return;
        }
        // 3. Update the cell
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[self indexOfRocket:selectedRocket]];
        NSIndexSet * columnSet = [NSIndexSet indexSetWithIndex:0];
        [self.rocketsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
    }
    
}
- (IBAction)rocketWeightDidEndEdit:(id)sender {
    ASDRocket *selectedRocket = [self selectedRocket];
    if (selectedRocket)
    {
        // 2. Get the new name from the text field
        selectedRocket.weight = [self.rocketWeightView doubleValue];
        
        NSError* error;
        
        if (![selectedRocket save: &error]) {
            NSLog(@"could not save rocket");
            return;
        }
        // 3. Update the cell
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[self indexOfRocket:selectedRocket]];
        NSIndexSet * columnSet = [NSIndexSet indexSetWithIndex:0];
        [self.rocketsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
    }
}
- (IBAction)rocketCoefficientDidEndEdit:(id)sender {
    ASDRocket *selectedRocket = [self selectedRocket];
    if (selectedRocket)
    {
        // 2. Get the new name from the text field
        selectedRocket.coefficientFriction = [self.rocketCoefficientView doubleValue];
        
        NSError* error;
        
        if (![selectedRocket save: &error]) {
            NSLog(@"could not save rocket");
            return;
        }
        // 3. Update the cell
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[self indexOfRocket:selectedRocket]];
        NSIndexSet * columnSet = [NSIndexSet indexSetWithIndex:0];
        [self.rocketsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
    }
}
- (IBAction)rocketDiaDidEndEdit:(id)sender {
    ASDRocket *selectedRocket = [self selectedRocket];
    if (selectedRocket)
    {
        // 2. Get the new name from the text field
        selectedRocket.diameter = [self.rocketDiameterView doubleValue];
        
        NSError* error;
        
        if (![selectedRocket save: &error]) {
            NSLog(@"could not save rocket");
            return;
        }
        // 3. Update the cell
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndex:[self indexOfRocket:selectedRocket]];
        NSIndexSet * columnSet = [NSIndexSet indexSetWithIndex:0];
        [self.rocketsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
    }

}


@end
