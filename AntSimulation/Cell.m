//
//  Cell.m
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/5/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import "Cell.h"
#import "Environment.h"

@implementation Cell

@synthesize env                  = _env,
            explorationPheromone = _explorationPheromone,
            foragingPheromone    = _foragingPheromone,
            pathIndex            = _pathIndex,
            cellIndex            = _cellIndex;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _explorationPheromoneLock = [[NSLock alloc] init];
        _foragingPheromoneLock = [[NSLock alloc] init];
    }
    
    return self;
}

- (void)incrementExplorationPheromone:(double)amount
{
    [_explorationPheromoneLock lock];
    self.explorationPheromone += amount;
    [_explorationPheromoneLock unlock];
}

- (void)incrementForagingPheromone:(double)amount
{
    [_foragingPheromoneLock lock];
    self.foragingPheromone += amount;
    [_foragingPheromoneLock unlock];
}

- (BOOL)canMoveInbound { return YES; }

- (BOOL)canMoveOutbound { return YES; }

- (CellType)cellType { return RegularType; }

- (Cell *)inboundNeighbor { return [_env inboundNeighborOfCell:self]; }

- (Cell *)outboundNeighbor { return [_env outboundNeighborOfCell:self]; }

- (double)totalPheromone { return _foragingPheromone + _explorationPheromone; }

- (void)decay
{
    _foragingPheromone    *= 1.0 - _env.foragingPheromoneDecayRate;
    _explorationPheromone *= 1.0 - _env.explorationPheromoneDecayRate;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Cell %02d on Path %d>", _cellIndex, _pathIndex];
}

@end

#pragma mark -

@implementation ColonyCell

- (double)explorationPheromone {
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
    return 0.0;
}

- (void)setExplorationPheromone:(double)explorationPheromone
{
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
}

- (double)foragingPheromone {
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
    return 0.0;
}

- (void)setForagingPheromone:(double)foragingPheromone
{
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
}

- (BOOL)canMoveInbound
{
    return NO;
}

- (double)totalPheromone
{
    return 1.0;
}

- (CellType)cellType { return ColonyType; }

// Ignore decay message
- (void)decay {}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Colony %02d on Path %d>", _cellIndex, _pathIndex];
}

@end

#pragma mark -

@implementation FoodSourceCell

- (double)explorationPheromone {
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
    return 0.0;
}

- (void)setExplorationPheromone:(double)explorationPheromone
{
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
}

- (double)foragingPheromone {
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
    return 0.0;
}

- (void)setForagingPheromone:(double)foragingPheromone
{
    [NSException raise:@"Invalid Access" format:@"Cannot access %@'s explorationPheromone", [self class], NSStringFromSelector(_cmd)];
}

- (CellType)cellType { return FoodSourceType; }

- (BOOL)canMoveOutbound
{
    return NO;
}

- (double)totalPheromone
{
    return INFINITY;
}

- (void)decay {}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Food Source %02d on Path %d>", _cellIndex, _pathIndex];
}

@end