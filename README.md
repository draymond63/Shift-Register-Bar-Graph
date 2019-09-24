# Shift-Register-Bar-Graph
An assembly program that manipulates a shift register, whose output leads to an LED bar graph.
The first pattern increments the LEDs. The next is a binary decrementing pattern. A switch decides 
which animation to show.

The shift register is a serial-to-parallel IC with three main control pins: latch, data, and clock. 
The latch controls whether the chip is reading or presenting the data. To beginning reading, this pin 
is set low. After this, a value of either high or low is presented on the data pin. When the clock 
pin goes high (on a RISING edge) the shift register reads the data pin and ‘loads’ that value into 
the byte. After this process cycles eight times (or more when daisy chaining) the latch is pulled high, 
displaying the byte on the shift register’s eight output pins.

The data byte presented by the shift register is made to follow the pattern 2^n-1, so all the LEDs 
stay on as a new one is added onto it. To present this data, as mentioned before, the data pin needs 
to present each bit individually. To accomplish this, a 1-bit mask cycles through and is AND’d with
the data. If the result is zero, the data pin is grounded; otherwise it is pulled high. To create this 
data byte there are two registers involved. The first starts at one and then, through every iteration 
of the loop, shifts left one bit. At each cycle this value is AND’d with the data byte that is sent 
out to the shift register. 

The final piece is the switch. It is connected to PCO-2 of the Arduino, with its outer pins tied to 
power and ground respectively. The middle pin simply reads the value that it is connected to and sets 
the animation. 
