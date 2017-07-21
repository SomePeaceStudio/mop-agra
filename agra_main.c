#include <stdio.h>
#include <stdlib.h>
#include "agra.h"

pixcolor_t* makeColor(unsigned int r, unsigned int g, unsigned int b, unsigned int op){
    pixcolor_t* color = (pixcolor_t*)malloc(sizeof(pixcolor_t));
    if(color==0){
        printf("%s\n", "Error: Could not make initial color");
        exit(1);
    }
    color->r = r;
    color->g = g;
    color->b = b;
    color->op = op;
    return color;
}

int main (int argc, char *argv[])
{

    printf("%d\n", test());
    return 0;
    
    pixcolor_t* white = makeColor(0x03ff,0x03ff,0x03ff,0);
    pixcolor_t* blue = makeColor(0,0,0x03ff,0);
    pixcolor_t* green = makeColor(0,0x03ff,0,0);
    pixcolor_t* red = makeColor(0x03ff,0,0,0);

    // Demonstracija
    // definēt ekrāna buferi ar izmēru 40 x 20 (lietojot jūsu framebuffer.c versiju)
    // notīrīt buferi, aizpildīt katru pikseli ar 0x00000000
    pixcolor_t* c = FrameBufferGetAddress();
    for (int i = 0; i < FrameWidth*FrameHeight; ++i){
        c[i].r = 0x0000;
        c[i].g = 0x0000;
        c[i].b = 0x0000;
    }

    // zīmēt pikseli koordinātās (25,2), baltu.
    setPixColor(white);
    pixel(25,2,white);
    
    // zīmēt līniju no (0,0) līdz (39,19), zilu, ar intensitāti 0x03ff
    setPixColor(blue);
    line(0,0,39,19);
    
    //zīmēt aizpildītu trijstūri: (20,13), (28,19), (38,6), zaļu, ar intensitāti 0x03ff
    setPixColor(green);
    triangleFill(20,13,28,19,38,6);

    // zīmēt riņķa līniju ar centru (20,10) un rādiusu 7, sarkanu, ar intensitāti 0x03ff
    setPixColor(red);
    circle(20,10,7);

    // izsaukt funkciju FrameShow()
    FrameShow();
    return 0;
}


    
 