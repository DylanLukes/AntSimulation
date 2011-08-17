//
//  Ant.m
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/1/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import "Ant.h"
#import "Cell.h"
#import "Environment.h"
#import "Utilities.h"

#import <objc/runtime.h>

@interface Ant ()
- (void)forage;
- (void)explore;
@end

@implementation Ant

@synthesize env     = _env,
            cell    = _cell,
            aID     = _aID,
            food    = _food,
            verbose = _verbose;

- (id)initInEnvironment:(Environment *)env atCell:(Cell *)cell
{
    static uint64_t curr_id = 0;
    
    self = [super init];
    if (self) {
        self.env  = env;
        self.cell = cell;
        self.aID  = curr_id++;
        self.food = 0;
    }
    
    return self;
}

typedef void (*void_imp_t)(id, SEL);

- (void)move
{    
    static void_imp_t forageIMP = NULL, exploreIMP = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        forageIMP = (void_imp_t)class_getMethodImplementation([self class], @selector(forage));
        exploreIMP = (void_imp_t)class_getMethodImplementation([self class], @selector(explore));
    });
    
    if (_food > 0.0) {
        //[self forage];
        forageIMP(self, @selector(forage));
    } else {
        exploreIMP(self, @selector(forage));
        //[self explore];
    }
}

- (void)explore
{
    Cell *dest = nil;
    
    if (_cell.cellType == ColonyType) {
        dest = _cell.outboundNeighbor;
    }
    else if (_cell.cellType == FoodSourceType) {
        _food += 1.0;
        dest = _cell.inboundNeighbor;
    } else {
        Cell *inCell  = _cell.inboundNeighbor;
        Cell *outCell = _cell.outboundNeighbor;
        
        double inPher    = inCell.totalPheromone + 1;
        double outPher   = outCell.totalPheromone + 1;
        double totalPher = inPher + outPher;
        
        double rand = randomDoubleInRange(0.0, totalPher);
        
        if (rand - inPher < 0) {
            dest = inCell;
        } else {
            dest = outCell;
        }
    }
    
    if (_verbose) NSLog(@"Ant %@ moving from %@ to %@", self, _cell, dest);
    
    self.cell = dest;
    
    if (_cell.cellType == FoodSourceType) {
        _food += 1.0;
    }
    else if (_cell.cellType == ColonyType) {
        // ... (do nothing)
    }
    else if (_env.isExplorationPheromone && _cell.explorationPheromone > 0.75) {
        [_cell incrementExplorationPheromone:_env.explorationPheromoneIntensity];
    }
}

- (void)forage
{
    Cell *dest = nil;
    
    dest = _cell.inboundNeighbor;
        
    if (_verbose) NSLog(@"Ant %@ moving from %@ to %@", self, _cell, dest);
        
    self.cell = dest;
    
    if (_cell.cellType == ColonyType) {
        _food = 0.0;
    }
    else if (_env.isForagingPheromone) {
        [_cell incrementForagingPheromone:_env.foragingPheromoneIntensity];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Ant #%llu>", _aID];
}

@end
