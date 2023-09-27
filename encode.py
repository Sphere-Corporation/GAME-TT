# Based on kcs_encode.py
#
# Author : David Beazley (http://www.dabeaz.com)
# Copyright (C) 2010
#
# Requires Python 3.1.2 or newer
#
# Updated 2022: Greg Strike (https://www.gregorystrike.com)
# Updated 2023: Andrew Shapton to include in Sphere Cassette

"""
Takes the contents of any file and encodes it into a Kansas
City Standard WAV file, that when played will upload data via the
cassette tape input on various vintage home computers. See
http://en.wikipedia.org/wiki/Kansas_City_standard
"""

import wave

# Create a single square wave cycle of a given frequency
def make_square_wave(freq,framerate,center,amplitude):
    n = int(framerate/freq/2)
    return bytearray([center-amplitude//2])*n + \
           bytearray([center+amplitude//2])*n

# Take a single byte value and turn it into a bytearray representing
# the associated waveform along with the required start and stop bits.
def kcs_encode_byte(byteval,one_pulse,zero_pulse):
    bitmasks = [0x1,0x2,0x4,0x8,0x10,0x20,0x40,0x80]
    # The start bit (0)
    encoded = bytearray(zero_pulse)
    # 8 data bits
    for mask in bitmasks:
        encoded.extend(one_pulse if (byteval & mask) else zero_pulse)
    # Two stop bits (1)
    encoded.extend(one_pulse)
    encoded.extend(one_pulse)
    return encoded

# Write a WAV file with encoded data. leader and trailer specify the
# number of seconds of carrier signal to encode before and after the data
def kcs_write_wav(filename,data,leader,trailer):
 
    # A few parameters related to the encoding

    FRAMERATE = 9600       # Hz
    ONES_FREQ = 2400       # Hz (per KCS)
    ZERO_FREQ = 1200       # Hz (per KCS)
    AMPLITUDE = 128        # Amplitude of generated square waves
    CENTER    = 128        # Center point of generated waves

    # Create the wave patterns that encode 1s and 0s
    one_pulse  = make_square_wave(ONES_FREQ,FRAMERATE,CENTER,AMPLITUDE)*8
    zero_pulse = make_square_wave(ZERO_FREQ,FRAMERATE,CENTER,AMPLITUDE)*4

    # Pause to insert after carriage returns (10 NULL bytes)
    #null_pulse = ((zero_pulse * 9) + (one_pulse * 2))*10
    
    w = wave.open(filename,"wb")
    w.setnchannels(1)
    w.setsampwidth(1)
    w.setframerate(FRAMERATE)

    # Write the leader
    w.writeframes(one_pulse*(int(FRAMERATE/len(one_pulse))*leader))

    # Encode the actual data
    for byteval in data:
        w.writeframes(kcs_encode_byte(byteval,one_pulse,zero_pulse))
        # The following 3 lines are not appropriate for encoding of binary data
        #if byteval == 0x0d:
            # If CR, emit a short pause (10 NULL bytes)
        #    w.writeframes(null_pulse)

    # Write the trailer
    w.writeframes(one_pulse*(int(FRAMERATE/len(one_pulse))*trailer))
    w.close()

# Main function to read a previously assembled and formatted binary file
# and send it to a kcs_write_wav function to create a WAV file ready for
# saving to cassette
def write_wav(input,output):
    rawdata = bytearray(open(input,"rb").read())
    kcs_write_wav(output,rawdata,5,5)