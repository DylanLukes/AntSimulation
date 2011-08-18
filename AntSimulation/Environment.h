//
//  Environment.h
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/1/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

/*      An `Environment` represents the system (space/time) in which the Ant agents move.
    It contains a set of `Path` objects, comprised of `Cell`s.
    Additionally, it contains various constants which would otherwise be global,
    such as the decay rate of different types of pheromone.
 */

#import <Foundation/Foundation.h>

@class Cell, Ant;

@interface Environment : NSObject {
    // An array containing all of the cells in the environment, interleaved.
    NSMutableArray *_cells;
    NSMutableArray *_ants;
}

- (id)initWithPathLength:(NSUInteger)pathLen pathCount:(NSUInteger)pathCount antCount:(NSUInteger)antCount;

// Current time within the environment (edited internally)
@property(readonly) NSUInteger time;
@property(readonly) NSUInteger pathLength;
@property(readonly) NSUInteger pathCount;

@property BOOL isExplorationPheromone;
@property BOOL isForagingPheromone;

@property double explorationPheromoneIntensity;
@property double foragingPheromoneIntensity;
@property double explorationPheromoneDecayRate;
@property double foragingPheromoneDecayRate;

// Advances the environment by one timestep, moving ants and decaying cells as necessary.
- (void)advance;

- (Cell *)colonyCell;
- (Cell *)cellAtIndex:(NSUInteger)cellIndex onPath:(NSUInteger)pathIndex;

- (Cell *)inboundNeighborOfCell:(Cell *)cell;
- (Cell *)outboundNeighborOfCell:(Cell *)cell;

// Debugging utilities :)
- (void)markSampleAsVerbose:(NSUInteger)sampleSize;

// Data sampling
- (double)sampleDeltaTotalPheromoneAtPathHeads; // this only works for two path heads!

@end
