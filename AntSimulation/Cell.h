//
//  Cell.h
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/5/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Environment;

typedef enum {
    ColonyType,
    FoodSourceType,
    RegularType
} CellType;

@interface Cell : NSObject {
    NSUInteger _pathIndex, _cellIndex;
    NSLock *_explorationPheromoneLock;
    NSLock *_foragingPheromoneLock;
}

@property double explorationPheromone;
@property double foragingPheromone;
@property(readonly) double totalPheromone;

// These are thread-safe!
- (void)incrementExplorationPheromone:(double)amount;
- (void)incrementForagingPheromone:(double)amount;

/* Meta data to make handling Cells easier, and speed up reverse lookup. */
@property(assign) Environment *env;

// Which path is this cell on?
@property NSUInteger pathIndex;
// Which cell index is this cell?
@property NSUInteger cellIndex;

// Can the ant move in/out from here?
@property(readonly) BOOL canMoveInbound;
@property(readonly) BOOL canMoveOutbound;

@property(readonly) CellType cellType;

// For convenience...
@property(readonly) Cell *inboundNeighbor;
@property(readonly) Cell *outboundNeighbor;

- (void)decay;

@end

#pragma mark -

@interface ColonyCell : Cell

@end

#pragma mark -

@interface FoodSourceCell : Cell

@end
