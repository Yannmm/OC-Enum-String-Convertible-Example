//
//  ViewController.h
//  OC-Enum-String-Convertible-Example
//
//  Created by 闫萌 on 17/8/9.
//  Copyright © 2017 RendezvousAuParadis. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EnumMarcos.h"

#define RAP_DIRECTION(XX) \
XX(RAPDirectionEast, ) \
XX(RAPDirectionSouth, ) \
XX(RAPDirectionWest, = 50) \
XX(RAPDirectionNorth, = 100) \

DECLARE_ENUM(RAPDirection, RAP_DIRECTION)

@interface ViewController : UIViewController


@end

