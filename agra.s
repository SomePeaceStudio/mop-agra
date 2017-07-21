.data
.balign 4
color: .word 0x0000

.text
.align 4
.extern FrameBufferGetAddress
.extern FrameBufferGetWidth
.extern FrameBufferGetHeight

.global setPixColor
.global pixel
.global line
.global triangleFill
.global circle      
.global test      

test:
    ldr r0, #0b111
    bx lr

color_adr: .word color

setPixColor:
    ldr r0, [r0]
    ldr r1, color_adr
    str r0, [r1]
    bx lr

pixel:
    @ r0 = x
    @ r1 = y
    @ r2 = color_adr
    push {r4-r10,lr}
    push {r0-r2}
    bl FrameBufferGetWidth
    mov r4, r0          @ r4 = frame width
    bl FrameBufferGetHeight
    mov r5, r0          @ r5 = frame height
    pop {r0-r2}

    mov r6, #0
    cmp r4, r6          @ frame width > 0
    ble exit
    cmp r5, r6          @ frame height > 0
    ble exit
    
    cmp r0, r4          @ x < frame width
    bge exit
    cmp r1, r4          @ y < frame height
    bge exit

    mla r7, r1, r4, r0  @ r7 = frameBuffer pixel idx
    lsl r7, #2          @ r7 = relative frameBuffer pixel adr

    push {r0-r3}
    bl FrameBufferGetAddress
    cmp r0, r6          @ flag if: address <= 0
    add r7, r7, r0      @ r7 = frameBuffer pixel adr
    pop {r0-r3}

    bls exit            @ exit if: address <= 0
    
    cmp r2, #0
    ldreq r2, color_adr
    ldr r8, [r2]        @ jaunā krāsa & op

    ldr r10, [r7]       @ pašreizējā krāsa

    and r9, r8, #0xC0000000 
    ror r9, #30         @ r9 = op

    cmp r9, #0          @ PIXEL_COPY = 0
    moveq r10, r8
    beq 1f

    cmp r9, #1          @ PIXEL_AND  = 1
    andeq r10, r10, r8
    beq 1f

    cmp r9, #2          @ PIXEL_OR   = 2
    orreq r10, r10, r8
    beq 1f

    cmp r9, #3          @ PIXEL_XOR  = 3
    eoreq r10, r10, r8
    beq 1f

    1:
    str r10, [r7]        @ r-g-b -> frameBuffer[x][y]
    b exit


// Bresenham's line algorithm
// https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
line:
    @ r0 = x0
    @ r1 = y0
    @ r2 = x1
    @ r3 = y1
    push {r4-r10,lr}
    push {r0-r3}
    bl getOctant
    mov r8, r0
    pop {r0-r3}
    push {r8} @ push octant
    bl switchToOctantZero

    sub r4, r2, r0      @ r4 = dx = x1 - x0
    sub r5, r3, r1      @ r5 = dy = y1 - y0
    mov r6, r5, lsl #2  @ r6 = 2*dy
    sub r6, r4          @ r6 = D = 2*dy - dx
                        @ r1 = y = y0
                        @ r0 = x = x0
    ldr r7, color_adr   @ r7 = *color
    re1:
    cmp r0, r2          @ while r0 <= r2
    ble lp1
    pop { r8 }          @pop octant
    b exit

lp1:
    push {r0-r3}
    mov r2, r8          @ r2 = octant
    bl switchFromOctantZero
    mov r2, r7          @ r2 = color_adr
    bl pixel            @ pixel(x,y,col) 
    pop {r0-r3}

    cmp r6, #0
    ble skip            
    @ if D > 0
    add r1, r1, #1      @ y = y + 1
    sub r6, r6, r4, lsl #2   @ D = D - 2*dx
    skip:
    add r6, r6, r5, lsl #2   @ D = D + 2*dy
    add r0, r0, #1      @ x = x + 1
    b re1

@ Pārbauda kurā no apļa astotdaļām taisne atrodas
getOctant:
    @ r0 = x0
    @ r1 = y0
    @ r2 = x1
    @ r3 = y1
    push {r4-r10,lr}
    cmp r0, r2
    ble oct_0_1_6_7
        @ oct_2_3_4_5
        cmp r1, r3
        ble oct_2_3
            @ oct_4_5
            sub r4, r0, r2  @ r4 = x0-x1
            sub r5, r1, r3  @ r4 = y0-y1
            cmp r4, r5
            blt oct_5
            mov r0, #4      @ oct_4
            b exit
            oct_5:
            mov r0, #5      @ oct_5
            b exit
        oct_2_3:
            sub r4, r0, r2  @ r4 = x0-x1
            sub r5, r1, r3  @ r4 = y0-y1
            cmp r4, r5
            blt oct_2
            mov r0, #3      @ oct_3
            b exit
            oct_2:
            mov r0, #2      @ oct_2
            b exit
    oct_0_1_6_7:
        cmp r1, r3
        ble oct_0_1
            @ oct_6_7
            sub r4, r2, r0  @ r4 = x1-x0
            sub r5, r1, r3  @ r4 = y0-y1
            cmp r4, r5
            blt oct_6
            mov r0, #7      @ oct_7
            b exit
            oct_6:
            mov r0, #6      @ oct_6
            b exit
        oct_0_1:
            sub r4, r2, r0  @ r4 = x1-x0
            sub r5, r3, r1  @ r4 = y1-y0
            cmp r4, r5
            blt oct_1
            mov r0, #0      @ oct_0
            b exit
            oct_1:
            mov r0, #1      @ oct_1
            b exit

@ Pārveido taisnes pozīciju uz riņķa 0.astotdaļas pozīciju
switchToOctantZero:
    @ r0 = x0
    @ r1 = y0
    @ r2 = x1
    @ r3 = y1
    @ stack top = octant
    push {r4-r10,lr}
    ldr r4, [sp, #32] @ r4 = octant

    cmp r4, #0
    beq exit
    cmp r4, #1
    bne 1f
    @ case 1: return (y, x)
    mov r5, r0
    mov r0, r1
    mov r1, r5

    mov r5, r2
    mov r2, r3
    mov r3, r5
    b exit
    
    1:
    cmp r4, #2
    bne 1f
    @ case 2: return (y, -x)
    mov r5, r0
    mov r0, r1
    mvn r1, r5
    add r1, r1, #1

    mov r5, r2
    mov r2, r3
    mvn r3, r5
    add r3, r3, #1
    b exit

    1:
    cmp r4, #3
    bne 1f
    @ case 3: return (-x, y)
    mvn r0, r0
    add r0, r0, #1

    mvn r2, r2
    add r2, r2, #1
    b exit

    1:
    cmp r4, #4
    bne 1f
    @ case 4: return (-x, -y)
    mvn r0, r0
    add r0, r0, #1
    mvn r1, r1
    add r1, r1, #1

    mvn r2, r2
    add r2, r2, #1
    mvn r3, r3
    add r3, r3, #1
    b exit

    1:
    cmp r4, #5
    bne 1f
    @ case 5: return (-y, -x)
    mov r5, r0
    mvn r0, r1
    add r0, r0, #1
    mvn r1, r5
    add r1, r1, #1

    mov r5, r2
    mvn r2, r3
    add r2, r2, #1
    mvn r3, r5
    add r3, r3, #1
    b exit

    1:
    cmp r4, #6
    bne 1f
    @ case 6: return (-y, x)
    mov r5, r0
    mvn r0, r1
    add r0, r0, #1
    mov r1, r5

    mov r5, r2
    mvn r2, r3
    add r2, r2, #1
    mov r3, r5
    b exit

    1:
    @ case 7: return (x, -y)
    mvn r1, r1
    add r1, r1, #1

    mvn r3, r3
    add r3, r3, #1
    b exit

@ Pārveido taisni no riņķa 0.astotdaļas uz orģinālo pozīciju
switchFromOctantZero:
    @ r0 = x0
    @ r1 = y0
    @ r2 = octant
    push {r4-r10,lr}
    mov r4, r2

    cmp r4, #0
    beq exit
    cmp r4, #1
    bne 1f
    @ case 1: return (y, x)
    mov r5, r0
    mov r0, r1
    mov r1, r5
    b exit
    
    1:
    cmp r4, #2
    bne 1f
    @ case 2: return (-y, x)
    mov r5, r0
    mvn r0, r1
    add r0, r0, #1
    mov r1, r5
    b exit

    1:
    cmp r4, #3
    bne 1f
    @ case 3: return (-x, y)
    mvn r0, r0
    add r0, r0, #1
    b exit

    1:
    cmp r4, #4
    bne 1f
    @ case 4: return (-x, -y)
    mvn r0, r0
    add r0, r0, #1
    mvn r1, r1
    add r1, r1, #1
    b exit

    1:
    cmp r4, #5
    bne 1f
    @ case 5: return (-y, -x)
    mov r5, r0
    mvn r0, r1
    add r0, r0, #1
    mvn r1, r5
    add r1, r1, #1
    b exit

    1:
    cmp r4, #6
    bne 1f
    @ case 6: return (y, -x)
    mov r5, r0
    mov r0, r1
    mvn r1, r5
    add r1, r1, #1
    b exit

    1:
    @ case 7: return (x, -y)
    mvn r1, r1
    add r1, r1, #1
    b exit

triangleFill:
    @ r0 = x1
    @ r1 = y1
    @ r2 = x2
    @ r3 = y2
    push { r4-r10,lr }
    ldr r4, [sp, #32] @ r4 = x3
    ldr r5, [sp, #36] @ r5 = y3
    push { r11 }

    mov r6, r0
    cmp r6, r2
    movgt r6, r2
    cmp r6, r4
    movgt r6, r4 @ r6 = minX

    mov r7, r0
    cmp r7, r2
    movlt r7, r2
    cmp r7, r4
    movlt r7, r4 @ r7 = maxX

    mov r8, r1
    cmp r8, r3
    movgt r8, r3
    cmp r8, r5
    movgt r8, r5 @ r8 = minY

    mov r9, r1
    cmp r9, r3
    movlt r9, r3
    cmp r9, r5
    movlt r9, r5 @ r9 = maxY

    @ Pārliecinās, ka trijstūris ir pretēji pulksteņa rādītāju
    @ virzienam
    push {r0-r3}
    push {r4-r5}
    bl orient2d
    add sp, #8
    cmp r0, #0  @ + pretēji pulkstenim, 
                @ - pulksteņa virzienā,
                @ 0 visi punkti ir uz taisnes
    pop {r0-r3}

    @ Apmaina vietām divus punktus, ja punkti bija pulksteņa virzienā
    movlt r10, r0
    movlt r11, r1
    movlt r0, r2
    movlt r1, r3
    movlt r2, r10
    movlt r3, r11
    
    @ Ja trijstūrim nav laukuma - algoritmu neizpildīt
    beq 3f

    @ r10, r11 = izmanto kā iteratorus
    mov r11, r8 @ y
    1: @ Cikls priekš y kordinantes
        cmp r11, r9
        bgt 3f

        mov r10, r6 @ x
        2: @ Cikls priekš x kordinantes
        cmp r10, r7
        addgt r11, r11, #1
        bgt 1b

        push {r0-r3,r6-r9}
        @w0 = orient2d(v1, v2, p);
        push {r0-r3}
        mov r0, r2
        mov r1, r3
        mov r2, r4
        mov r3, r5
        push {r10-r11}
        bl orient2d
        add sp, #8
        mov r6, r0
        pop {r0-r3}
        
        @w1 = orient2d(v2, v0, p);
        push {r0-r3}
        mov r2, r0
        mov r3, r1
        mov r0, r4
        mov r1, r5
        push {r10-r11}
        bl orient2d
        add sp, #8
        mov r7, r0
        pop {r0-r3}

        @w2 = orient2d(v0, v1, p);
        push {r0-r3}
        push {r10-r11}
        bl orient2d
        add sp, #8
        mov r8, r0
        pop {r0-r3}

        @ Pārbauda vai pixelis ir trijstūrī
        cmp r6, #0
        cmpge r7, #0
        cmpge r8, #0
        movge r0, r10
        movge r1, r11
        movge r2, #0
        blge pixel

        pop {r0-r3,r6-r9}
        add r10, r10, #1
        b 2b
    3:
    pop {r11}
    b exit


orient2d:
    @ r0 = a.x
    @ r1 = a.y
    @ r2 = b.x
    @ r3 = b.y
    push {r4-r10,lr}
    ldr r4, [sp, #32] @ r4 = c.x
    ldr r5, [sp, #36] @ r5 = c.y
    
    @return (b.x-a.x)*(c.y-a.y) - (b.y-a.y)*(c.x-a.x);
    sub r6, r2, r0
    sub r7, r5, r1
    mul r8, r6, r7

    sub r6, r3, r1
    sub r7, r4, r0
    mul r9, r6, r7

    sub r0, r8, r9
    b exit

// Midpoint circle algorithm
// https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
circle:
    @ r0 = x0
    @ r1 = y0
    @ r2 = x = radius
    push {r4-r10,lr}
    mov r4, #0          @ r4 = y = 0;
    mov r5, #0          @ r5 = err = 0;
    ldr r6, color_adr   @ r6 = *color
    1: 
    cmp r2, r4
    bge 2f          @ while (x >= y)
    b exit
    2:
    push {r0-r2}
    add r0, r0, r2      @ x0 + x
    add r1, r1, r4      @ y0 + y
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    add r0, r0, r4      @ x0 + y
    add r1, r1, r2      @ y0 + x
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    sub r0, r0, r4      @ x0 - y
    add r1, r1, r2      @ y0 + x
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    sub r0, r0, r2      @ x0 - x
    add r1, r1, r4      @ y0 + y
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    sub r0, r0, r2      @ x0 - x
    sub r1, r1, r4      @ y0 - y
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    sub r0, r0, r4      @ x0 - y
    sub r1, r1, r2      @ y0 - x
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    add r0, r0, r4      @ x0 + y
    sub r1, r1, r2      @ y0 - x
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    push {r0-r2}
    add r0, r0, r2      @ x0 + x
    sub r1, r1, r4      @ y0 - y
    mov r2, r6          @ r2 = *color
    bl pixel
    pop {r0-r2}

    cmp r5, #0
    bgt 3f
    @ if (err <= 0)
    add r4, r4, #1      @ y += 1;
    lsl r7, r4, #1      @ r7 = 2*y
    add r7, r7, #1      @ r7 = r7 + 1
    add r5, r5, r7      @ err += 2*y + 1;
    b 1b
    3:
    @ if (err > 0)
    sub r2, r2, #1      @ x -= 1;
    lsl r7, r2, #1      @ r7 = 2*x
    add r7, r7, #1      @ r7 = r7 + 1
    sub r5, r5, r7      @ err -= 2*x + 1;
    b 1b

exit:
    pop {r4-r10,lr}
    bx lr
