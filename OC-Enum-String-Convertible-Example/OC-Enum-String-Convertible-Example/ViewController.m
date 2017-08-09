//
//  ViewController.m
//  OC-Enum-String-Convertible-Example
//
//  Created by 闫萌 on 17/8/9.
//  Copyright © 2017 RendezvousAuParadis. All rights reserved.
//

#import "ViewController.h"

DEFINE_ENUM(RAPDirection, RAP_DIRECTION)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *str = NSStringFromRAPDirection(RAPDirectionEast);
    NSLog(@"RAPDirectionEast has case name: %@", str);
    
    
    RAPDirection dir = RAPDirectionFromNSString(@"RAPDirectionNorth");
    NSLog(@"RAPDirectionNorth has case value: %zd", dir);
}

@end
