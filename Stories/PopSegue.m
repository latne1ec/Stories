//
//  PopSegue.m
//  Stories
//
//  Created by Evan Latner on 2/19/15.
//  Copyright (c) 2015 Evan Latner. All rights reserved.
//

#import "PopSegue.h"

@implementation PopSegue

-(void) perform{
    
    UIViewController *vc = self.sourceViewController;
    [vc.navigationController pushViewController:self.destinationViewController animated:NO];
    
}



@end
