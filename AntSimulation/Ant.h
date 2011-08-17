//
//  Ant.h
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/1/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Environment, Cell;

@interface Ant : NSObject

// A weak reference to the Environment in which the ant exists.
@property(assign) Environment *env;
// A weak reference to the Cell the ant is currently at.
@property(assign) Cell *cell;
// Ant ID number. Each ant has a unique ID to make tracking them easier.
@property uint64_t  aID;
// The amount of food the ant is carrying.
@property NSUInteger food;
// Verbose mode (for tracking a single ant)
@property BOOL verbose;

- (id)initInEnvironment:(Environment *)env atCell:(Cell *)cell;
- (void)move;

@end
