//
//  analysis.h
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/23/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#ifndef ANTSIMULATION_ANALYSIS_H
#define ANTSIMULATION_ANALYSIS_H

void autocorrelate(double *input, double *output, int size, int lag);
void smooth(double *input, double *output, int length, int sigma);
void downsample(double *input, int input_length, double *output, int stride);
void crossings(double *input, double *output, int input_length, int *output_length, double threshold);

#endif
