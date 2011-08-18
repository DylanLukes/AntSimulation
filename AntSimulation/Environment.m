//
//  Environment.m
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/1/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import "Environment.h"
#import "Ant.h"
#import "Cell.h"
#import "Utilities.h"

#import <objc/runtime.h>

@implementation Environment

@synthesize time          = _time,
            pathLength    = _pathLength,
            pathCount     = _pathCount,
            isExplorationPheromone        = _isExplorationPheromone,
            isForagingPheromone           = _isForagingPheromone,
            explorationPheromoneIntensity = _explorationPheromoneIntensity,
            foragingPheromoneIntensity    = _foragingPheromoneIntensity,
            explorationPheromoneDecayRate = _explorationPheromoneDecayRate,
            foragingPheromoneDecayRate    = _foragingPheromoneDecayRate;

static dispatch_queue_t queue;

+ (void)initialize
{
    sranddev();
    srandomdev();
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    });
}

- (id)initWithPathLength:(NSUInteger)pathLen pathCount:(NSUInteger)pathCount antCount:(NSUInteger)antCount
{
    @autoreleasepool {
        self = [super init];
        if (self) {
            _time                = 0;
            _pathLength          = pathLen;
            _pathCount           = pathCount;
            
            // Default settings
            _isExplorationPheromone = YES;
            _isForagingPheromone    = YES;
            
            _cells = [[NSMutableArray alloc] initWithCapacity:(_pathLength * _pathCount) + 1];
            
            // Insert colony node at index 0
            [_cells addObject:[[[ColonyCell alloc] init] autorelease]];
            
            // Insert each path
            for (int path_i = 0; path_i < pathCount; path_i++) {
                for (int cell_i = 0; cell_i < pathLen; cell_i++) {
                    Cell *cell;
                    
                    if (cell_i == (pathLen - 1)) {
                        cell = [[[FoodSourceCell alloc] init] autorelease];
                    } else {
                        cell = [[[Cell alloc] init] autorelease];
                    }
                    
                    cell.pathIndex = path_i;
                    cell.cellIndex = cell_i;
                    
                    [_cells addObject:cell];
                }
            }
            
            for (Cell *cell in _cells) {
                cell.env = self;
            }
            
            if ([_cells count] > UINT32_MAX) {
                [NSException raise:@"Invalid Environment" format:@"Environment cannot have more than %d cells.", UINT32_MAX];
            }
            
            // Initialize all ants
            _ants = [[NSMutableArray alloc] initWithCapacity:antCount];
            
            // Scatter ants
            for (int i = 0; i < antCount; i++) {
                NSInteger randIndex = arc4random_uniform((uint32_t)[_cells count]);
                
                Ant *ant = [[[Ant alloc] initInEnvironment:self atCell:[_cells objectAtIndex:randIndex]] autorelease];
                [_ants addObject:ant];
            }
        }
        
        return self;
    }
}

- (void)dealloc
{
    [_cells release];
    [_ants release];
    [super dealloc];
}

- (void)advance
{
    // Move all ants
    static IMP antMoveIMP;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        antMoveIMP = class_getMethodImplementation([Ant class], @selector(move));
    });
    
    // Decay all cells
    for(Cell *cell in _cells) {
        [cell decay];
    }
    
    for(Ant *ant in _ants) {
        antMoveIMP(ant, @selector(move));
        //[ant move];
    }
        
    ++_time;
}

- (Cell *)colonyCell
{
    // The colony cell is allocated in _cells[0]
    return [_cells objectAtIndex:0];
}

- (Cell *)cellAtIndex:(NSUInteger)cellIndex onPath:(NSUInteger)pathIndex;
{
    NSUInteger absoluteIndex = 1 + (pathIndex * _pathLength) + cellIndex;
    return [_cells objectAtIndex:absoluteIndex];
}

- (Cell *)inboundNeighborOfCell:(Cell *)cell
{
    // Ant @ Colony, Inbound = ERROR
    if (!cell.canMoveInbound)
        [NSException raise:@"Invalid Movement" format:@"Cannot move inbound from the colony."];
    
    // Ant @ [_][0], Inbound = Colony
    if (cell.cellIndex == 0) return [self colonyCell];
    
    // else, Ant @ [_][n], Inbound = [_][n - 1]
    return [self cellAtIndex:cell.cellIndex - 1 onPath:cell.pathIndex];
}

- (Cell *)outboundNeighborOfCell:(Cell *)cell
{
    // Ant @ FoodSource, Outbound = ERROR
    if (!cell.canMoveOutbound)
        [NSException raise:@"Invalid Movement" format:@"Cannot move outbound from a food source."];
    
    // Ant @ Colony, Outbound = [Random][0]
    if (cell.cellType == ColonyType) {
        // Select a trail head randomly.
        
        double total = 0;
        
        // Sum trail heads
        for (int i = 1, p = 0; p < _pathCount; i += _pathLength, p++) {
            total += [(Cell *)[_cells objectAtIndex:i] totalPheromone] + 1;
        }
        
        double threshold = randomDoubleInRange(0.0, total);
        
        for (int i = 1, p = 0; p < _pathCount; i += _pathLength, p++) {
            threshold -= [(Cell *)[_cells objectAtIndex:i] totalPheromone] + 1;
            
            if (threshold < 0.0) {
                return (Cell *)[_cells objectAtIndex:i];
            }
        }
    }
    
    // else, Ant @ [_][n], Outbound = [_][n + 1]
    return [self cellAtIndex:cell.cellIndex + 1 onPath:cell.pathIndex];
}

- (void)markSampleAsVerbose:(NSUInteger)sampleSize
{
    __block NSUInteger i = sampleSize;
    [_ants enumerateObjectsUsingBlock:^(__strong Ant *ant, NSUInteger idx, BOOL *stop) {
        ant.verbose = YES;
        if (--i <= 0) *stop = YES;
    }];
}

- (double)sampleDeltaTotalPheromoneAtPathHeads
{
    if (_pathCount != 2) {
        [NSException raise:@"Invalid sampling" format:@"Delta pheromone metric is not valid for more than two paths."];
    }
    return [self cellAtIndex:0 onPath:1].totalPheromone - [self cellAtIndex:0 onPath:0].totalPheromone;
}

@end