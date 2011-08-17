//
//  analysis.c
//  AntSimulation2
//
//  Created by Dylan Lukes on 7/23/11.
//  Copyright 2011 Dylan Lukes. All rights reserved.
//

#import <math.h>
#import "analysis.h"

#import <stdio.h>
#import <stdlib.h>
#import <math.h>
#import <string.h>
#import <Accelerate/Accelerate.h>

void autocorrelate(double *input, double *output, int size, int lag)
{
    double *s = input;
    int l = lag, n = size, l2 = 0;
    
    for(int i = l; i <= n - l; i++){
        for(int j = 0; j <= 2 * l - 1; j++){
            l2 = -l + j;
            output[j] += s[i] * s[i + l2];
        }
    }
    
    // Sum of signal
    double sum = 0;
    for(int i = 0; i < size; i++){
        sum += s[i];
    }
    
    for(int j = 0; j <= 2 * l - 1; j++){
        output[j] /= (n - 2 * l);
        output[j] -= pow((sum/size), 2);
    }
}

void smooth(double *input, double *output, int input_length, int sigma)
{
    int gauss_length = 6 * sigma;
    int output_length = input_length - gauss_length;
    double *gauss = calloc(0, gauss_length);
    double *norm_gauss = calloc(0, gauss_length);
    
    double A = 1 / sqrt(M_PI * pow(sigma, 2));
    
    for (int i = 0; i < gauss_length; i++) {
        gauss[i] = A * exp(-1 * pow(i - gauss_length/2, 2) / 2 / pow(sigma, 2));
    }
    
    // Normalize gaussian
    double sum = 0;
    vDSP_sveD(gauss, 1, &sum, gauss_length);
    vDSP_vsdivD(gauss, 1, &sum, norm_gauss, 1, gauss_length);
    
    // Convolute the padded input with the normalised gaussian
    vDSP_convD(input, 1, norm_gauss, 1, output + (gauss_length / 2), 1, output_length, gauss_length);
    
    free(gauss); free(norm_gauss);
}