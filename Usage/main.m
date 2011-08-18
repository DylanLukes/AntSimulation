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

#define SIM_SIZE 200000
#define AC_LAG 24000
#define AC_SIZE (AC_LAG * 2)
#define REALIZATION_NUM 5
#define SIGMA 100

typedef double (*double_imp_t)(id, SEL);
typedef double (*void_imp_t)(id, SEL);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        /* TODO:
         * - Run parallel many sim realizations:
         *  - smooth
         *  - find crossing
         *  - serial autocorr
         */
                    
        double *res = calloc(SIM_SIZE, sizeof(double));
        
        Environment *env = [[[Environment alloc] initWithPathLength:50 pathCount:2 antCount:100] autorelease];
        env.isExplorationPheromone = YES;
        env.explorationPheromoneDecayRate = 0.005;
        env.explorationPheromoneIntensity = 0.25;
        
        env.foragingPheromoneDecayRate    = 0.010;
        env.foragingPheromoneIntensity    = 0.5;
        
        //[env markSampleAsVerbose:0];
                
        
        
        for (int i = 0; i < SIM_SIZE; i++) {
            res[i] = [env sampleDeltaTotalPheromoneAtPathHeads];
            [env advance];
        }
        
        double *smoothed = calloc(SIM_SIZE, sizeof(double));
        
        smooth(res, smoothed, SIM_SIZE, SIGMA);
        
        /* --- Plotting --- */
        
        setenv("PATH", strcat(getenv("PATH"), ":/usr/local/bin"), 1);
        
        gnuplot_ctrl *g = gnuplot_init();
        gnuplot_setstyle(g, "lines");
        
        gnuplot_cmd(g, "set title 'test'");
        gnuplot_set_xlabel(g, "t");
        gnuplot_set_ylabel(g, "delta ph.");
        
        //gnuplot_plot_x(g, res, SIM_SIZE, "delta pheromone"); 
        //gnuplot_plot_x(g, smoothed, SIM_SIZE, "smoothed");
        
        // Wait for a keypress to die
        //getc(stdin);
                
        free(res);
        free(smoothed); 
        
        gnuplot_close(g);
            
    }
    
    return 0;
}

