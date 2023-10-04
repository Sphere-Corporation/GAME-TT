#!/usr/bin/env python3
# encode_tape.py
#
# Author : David Beazley (http://www.dabeaz.com)
# Copyright (C) 2010
#
# + Ben Zotto 2023
#
# Requires Python 3.1.2 or newer

# Updated 2023: Andrew Shapton to include in Sphere Cassette
# Based on sphere_encode.py 
"""
Takes the contents of a binary file and encodes it into a Kansas
City Standard WAV file, that when played will upload data via the
cassette tape input on various vintage home computers. See
http://en.wikipedia.org/wiki/Kansas_City_standard
"""

import math
import wave

# A few global parameters related to the encoding

FRAMERATE = 44100      # Hz
ONES_FREQ = 2400       # Hz (per KCS)
ZERO_FREQ = 1200       # Hz (per KCS)
AMPLITUDE = 128        # Max amplitude of generated waves
CENTER    = 128        # Center point of generated waves

# Create a single sine wave cycle
def make_sine_wave(freq, framerate, amp):
    samples = []
    n = int(framerate/freq)          
    rad_per_sample = (2 * math.pi) / n
    for i in range(n):
        val = math.floor(math.sin(i * rad_per_sample) * amp) + CENTER
        samples.append(val)
    return bytearray(samples)
    
# Create the wave patterns that encode 1s and 0s. The amplitudes are different so that
# the result looks somewhat more similar to the SIM/1 generated audio. 
one_pulse  = make_sine_wave(ONES_FREQ,FRAMERATE,AMPLITUDE//4)*8
zero_pulse = make_sine_wave(ZERO_FREQ,FRAMERATE,AMPLITUDE//2)*4

# Carrier pause to insert before and after content, and between blocks
null_pulse = one_pulse*(int(FRAMERATE/len(one_pulse)))*5

# Take a single byte value and turn it into a bytearray representing
# the associated waveform along with the required start and stop bits.
def kcs_encode_byte(bval):
    bitmasks = [0x1,0x2,0x4,0x8,0x10,0x20,0x40,0x80]
    # The start bit (0)
    encoded = bytearray(zero_pulse)
    # 8 data bits
    for mask in bitmasks:
        encoded.extend(one_pulse if (bval & mask) else zero_pulse)
    # Two stop bits (1)
    encoded.extend(one_pulse)
    encoded.extend(one_pulse)
    return encoded

# Write a WAV file with encoded data. leader and trailer specify the
# number of seconds of carrier signal to encode before and after the data
def kcs_write_wav(filename,data,leader,trailer,interfile):
    w = wave.open(filename,"wb")
    w.setnchannels(1)
    w.setsampwidth(1)
    w.setframerate(FRAMERATE)

    # Write the leader
    w.writeframes(one_pulse*(int(FRAMERATE/len(one_pulse))*leader))

    firstblock = 1 

    # Encode the actual data
    for index in range(len(data)):
    
        # If this is the 
        if (firstblock == 0 and
            (index+3 < len(data)) and
                data[index] == 0x16 and
                data[index+1] == 0x16 and
                data[index+2] == 0x16 and
                data[index+3] == 0x1B):
            # Write interstitial carrier
            w.writeframes(null_pulse)
            
        byteval = data[index]
        w.writeframes(kcs_encode_byte(byteval))
        firstblock = 0
    
    # Write the trailer
    w.writeframes(one_pulse*(int(FRAMERATE/len(one_pulse))*trailer))
    w.close()

def write_wav(in_filename,out_filename):
    data = open(in_filename,"rb").read()
    rawdata = data ;
    kcs_write_wav(out_filename,rawdata,5,5,5)