/* Select the target processor. */
.cpu cortex-m4

/* Generate Thumb instructions. This performs the same action as .code 16 */
.thumb

/* NVIC -- vector interrupt table */
.section ".isr_vector"
.word   0x10008000  /* stack top address */
.word   _start      /* 1  Reset */
.word   hang        /* 2  NMI */
.word   hang        /* 3  HardFault */
.word   hang        /* 4  MemManage */
.word   hang        /* 5  BusFault */
.word   hang        /* 6  UsageFault */
.word   hang        /* 7  RESERVED */
.word   hang        /* 8  RESERVED */
.word   hang        /* 9  RESERVED*/
.word   hang        /* 10 RESERVED */
.word   hang        /* 11 SVCall */
.word   hang        /* 12 Debug Monitor */
.word   hang        /* 13 RESERVED */
.word   hang        /* 14 PendSV */
.word   hang        /* 15 SysTick */

/* This directive indicates to assemble the following code into a the section
name. See the flash.ld file for section layout. */
.section ".text"

/* The .thumb_func directive specifies that the following symbol is the name
of a Thumb encoded function. */
.thumb_func
hang:
    b    .                  // ~ while( true )

/* Perform a busy waiting. */
.thumb_func
dowait:
    ldr  r7, =0xFFFF000       // store 0xA0000 in the r7 register
dowaitloop:
    sub  r7, #1             // substract 1 from the value in r7
    bne  dowaitloop         // if r7 != 0, goto dowaitloop
    bx   lr                 // return

/* .globl makes the symbol visible to ld */
.thumb_func
.globl _start
_start:
   // Before we use the GPIOD peripheral, we need to turn it on. By default,
   // power is not applied to most of the peripherals for energy efficiency,
   // so we need to turn them on by setting the appropriate bit in the RCC
   // “clock enable” registers.
   movw r0, #0x3800
   movt r0, #0x4002
   movw r1, #0x08
   str  r1, [r0, #0x30]

   // GPIO port mode register -- 01: General purpose output mode
   movw r0, #0x0c00
   movt r0, #0x4002
   movw r1, #0x0000
   movt r1, #0x0100
   str  r1, [r0]

   // GPIO port output type register -- 0: Output push-pull (reset state)
   // GPIO port output speed register -- 0: Low speed
   // GPIO port pull-up/pull-down register -- 01: Pull-up
   // values by default

mainloop:
   // LED off
   movw r1, #0x0000
   movt r1, #0x1000
   str  r1, [r0, #0x18]

   bl dowait               // execute dowait

   // LED on
   movw r1, #0x1000
   movt r1, #0x0000
   str  r1, [r0, #0x18]

   bl   dowait             // execute dowait

   b    mainloop           // goto mainloop

.end
