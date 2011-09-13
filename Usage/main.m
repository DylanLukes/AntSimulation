//
//  main.m
//  Usage
//
//  Created by Dylan Lukes on 7/20/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Environment.h"
#import "gnuplot_i.h"
#import "analysis.h"

#import <objc/runtime.h>

#define SIM_SIZE (50000 * 100)
#define AC_LAG (24000)
#define AC_SIZE (AC_LAG * 2)
#define REALIZATION_NUM (5)

// smoothing constants
#define SIGMA (1000)

// path state
#define EPSILON (0.5)

typedef double (*double_imp_t)(id, SEL);
typedef double (*void_imp_t)(id, SEL);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"Start");
        /* TODO:
         * - Run parallel many sim realizations:
         *  - smooth
         *  - find crossing
         *  - serial autocorr
         */
                    
        double *res = calloc(SIM_SIZE, sizeof(double));
        
        Environment *env = [[Environment alloc] initWithPathLength:50 pathCount:2 antCount:100];
        env.isExplorationPheromone = YES;
        env.explorationPheromoneDecayRate = 0.005;
        env.explorationPheromoneIntensity = 0.25;
        
        env.isForagingPheromone = YES;
        env.foragingPheromoneDecayRate    = 0.010;
        env.foragingPheromoneIntensity    = 0.5;
        
        //[env markSampleAsVerbose:0];
        
        for (int i = 0; i < SIM_SIZE; i++) {
            res[i] = [env sampleDeltaTotalPheromoneAtPathHeads];
            [env advance];
        }
        
        double *smoothed = calloc(SIM_SIZE, sizeof(double));
        
        smooth(res, smoothed, SIM_SIZE, SIGMA);

        double *crossings = calloc(SIM_SIZE, sizeof(double));
        int crossing_count = 0;
        
        find_crossings(smoothed, crossings, SIM_SIZE, &crossing_count, EPSILON);
        crossings = realloc(crossings, sizeof(double) * crossing_count);
        
        double *crossings_nz = calloc(crossing_count, sizeof(double));
        int nz_count = 0;
        
        rem_zeroes(crossings, crossings_nz, crossing_count, &nz_count);
        crossings_nz = realloc(crossings_nz, sizeof(double) * nz_count);
        
        /* --- Plotting --- */
        
        setenv("PATH", strcat(getenv("PATH"), ":/usr/local/bin"), 1);
        
        gnuplot_ctrl *g = gnuplot_init();
        gnuplot_setstyle(g, "steps");
        
        gnuplot_cmd(g, "set title 'Path State'");
        gnuplot_set_xlabel(g, "-");
        gnuplot_set_ylabel(g, "path state");
                
        gnuplot_cmd(g, "set yrange [-1.1:1.1]");
        
        
        NSLog(@"End: Plotting %d crossings.", nz_count);
        gnuplot_plot_x(g, res, SIM_SIZE, "crossings");
        
        // Wait for a keypress to die
        getc(stdin);
                
        free(smoothed);
        free(crossings);
        free(crossings_nz);
        free(res);
        
        gnuplot_close(g);
        [env release];
        
    }
    
    return 0;
}

