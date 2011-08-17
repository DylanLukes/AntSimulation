//
//  AntSimulationTests.m
//  AntSimulationTests
//
//  Created by Dylan Lukes on 7/1/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import "AntSimulationTests.h"
#import "Environment.h"
#import "Cell.h"

@implementation AntSimulationTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEnvironmentIntegrity
{
    Environment *env = [[Environment alloc] initWithPathLength:50 pathCount:2 antCount:50];
    
    NSUInteger cellIndex = 30, pathIndex = 1;
    
    Cell *aCell = [env cellAtIndex:cellIndex onPath:pathIndex];
    
    STAssertEquals(aCell.pathIndex, pathIndex, @"Expected path index should be equal to Cell's cached value.");
    STAssertEquals(aCell.cellIndex, cellIndex, @"Expected cell index should be equal to Cell's cached value.");
}

- (void)testSimpleAdvance
{
    Environment *env = [[Environment alloc] initWithPathLength:50 pathCount:2 antCount:100];
    for(int i = 0; i < 100; i++){
        [env advance];
    }
}

@end
