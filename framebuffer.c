#include <stdio.h>
#include <stdlib.h>
#include "agra.h"

pixcolor_t* FrameStart = 0;

// Kadra bufera sākuma adrese
pixcolor_t* FrameBufferGetAddress(){
    if(FrameStart != 0){
        return FrameStart;
    }
    FrameStart = (pixcolor_t*) malloc( FrameWidth * FrameHeight * sizeof(pixcolor_t));
    if(FrameStart==0){
        exit(1);
    }
    return FrameStart;
};
 
// Kadra platums
int FrameBufferGetWidth(){
    return FrameWidth;
};
 
// Kadra augstums
int FrameBufferGetHeight(){
    return FrameHeight;
};

// Kadra izvadīšana uz "displeja iekārtas".
int FrameShow(){
    pixcolor_t* c = FrameBufferGetAddress();
    for (int i = 0; i < FrameWidth*FrameHeight; ++i){
        // printf("%5d %5d %5d \n", c[i].r,c[i].g,c[i].b);
        if(c[i].r<512){
            if(c[i].g<512){
                if(c[i].b<512){
                    printf("%c", BLACK);
                }else{
                    printf("%c", BLUE);
                }
            }else{
                if(c[i].b<512){
                    printf("%c", GREEN);
                }else{
                    printf("%c", CYAN);
                }
            }
        }else{
            if(c[i].g<512){
                if(c[i].b<512){
                    printf("%c", RED);
                }else{
                    printf("%c", MAGENTA);
                }
            }else{
                if(c[i].b<512){
                    printf("%c", YELLOW);
                }else{
                    printf("%c", WHITE);
                }
            }
        }
        if((i+1)%FrameWidth==0){
            printf("\n");
        }
    }
    return 0;
};