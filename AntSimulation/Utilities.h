//
//  Utilities.h
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/5/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import <stdlib.h>

static inline double randomDoubleInRange(double minValue, double maxValue){
    double p = (double) arc4random() / ((double) 0x100000000 + 1.0);
    double range = maxValue - minValue;
    
    return range * p + minValue;
}