#!/usr/bin/env python3
# cas.py
#
# Author : Andrew Shapton 
# Copyright (C) 2023
#
# Requires Python 3.9 or newer
#

from datetime import date

import click
import encode

"""
Takes a binary Sphere-1 program and converts it into a format that can be
     i)   Included in the Virtual Sphere simulator
    ii)   Converted to a  Kansas City Standard WAV file.
See http://en.wikipedia.org/wiki/Kansas_City_standard
"""

# Define software characteristics
_version = '1.0.0';
_package_name = 'convertEXE';
_message = '%(package)s (Version %(version)s): Convert MC6800 assembled code into Sphere-1 loadable package.';

# Define Tape Constants
SYNC       = '0x16, '   # Synchronisation Byte
CONST_BYTE = '0x1B, '   # 
EOT_BYTE   = '0x17, '   # End of Transmission Byte

# Define internal Constants
ERROR_CONSTANT = "ERROR:"
CR = '\n'
TAB = '\t'
TODAY = date.today().strftime("%d/%m/%Y")
EXTRA_DATA = 13
CASSETTE_EXTENSION='.wav'

# Define defaults
BLOCK_NAME='XX'
EXTENSION=".js"

def fhex(value):
    return f'0x{value:02x}'.upper().replace('X','x')

def check16(value, file):
    if value == 16:
            file.write(CR);
            file.write(TAB);
            value = 0;
    return value
        
def geterror(text):
    return text[6:]

def iserror(text):
    status = False;
    if text[:6] == ERROR_CONSTANT:
        status = True
    return status

def read_input_file(filename):
    try:
        with open(filename, 'rb') as f_obj:
            contents = f_obj.read()
            return contents
    except FileNotFoundError:
        return ERROR_CONSTANT + "FileNotFoundError"

def write_binary_content(file, binary_data, prefix):
    # Get length of the program to store in bytes minus 1
    raw_data = len(binary_data) - 1;

    # Write the 3 Synchronisation bytes
    file.write(TAB + SYNC);
    file.write(SYNC);
    file.write(SYNC);

    # Write the 1 byte constant marker
    file.write(CONST_BYTE);

    # Write the count of bytes in the block (high byte first)
    b = raw_data.to_bytes(2, 'big')
    file.write(fhex(b[0]) + ", ");
    file.write(fhex(b[1]) + ", ");

    # Write the 2 character block name    
    block_ascii = list(prefix.encode('ascii'))
    file.write(fhex(block_ascii[0]) + ", ");
    file.write(fhex(block_ascii[1]) + ", ");

    c = 8
    # Initialise checksum
    checksum = 0;
    # Write raw data to the file
    for x in binary_data:
        value = fhex(x);
        file.write((value) + ", ");
        c += 1
        c = check16(c, file);
        checksum = checksum + x;

    # Write the end of transmission byte
    file.write(EOT_BYTE);
    c += 1
    c = check16(c, file);

    # Checksum is the summation of the bytes in the program MOD 256
    checksum = fhex(checksum % 256);

    # Write the checksum byte (and the 3 final trailer bytes (actually the checksum written 3 times)
    for _ in range(3):
        file.write(checksum + ", ");
        c += 1
        c = check16(c, file);
    
    file.write(checksum);    
    
def write_preamble(filehandle, filename, prefix, title, base, noheader):
    if not(noheader):
        filehandle.write("/// Executable image for : " + filename + CR)
        filehandle.write("/// Date                 : " + TODAY + CR)
        filehandle.write("///" + CR)
        filehandle.write("/// Created by " + _package_name + " " + _version + CR)
        filehandle.write("///" + CR)
        click.secho('Written preamble : Title       : ' + title, fg="green")
        click.secho('                 : Prefix      : ' + prefix, fg="green")
        click.secho('                 : Address     : ' + base, fg="green")
        
    filehandle.write("const cassette_" + prefix.lower() + " =  { title: \"" + title + \
        "\", label: \"" + prefix + "/" + base + "\", data:" + CR)
    filehandle.write("[" + CR)
    
def write_postamble(filehandle):
    filehandle.write(CR + "]};" + CR)
    
@click.command()
@click.option("--base","-b", help="Base address.",required=True)
@click.option("--cassette","-c", help="Cassette output file (experimental).",required=False,default="")
@click.option("--input","-i", help="Input MC6800 executable file.",required=True)
@click.option("--noheader","-n", help="Don't produce headers for JS file.",required=False,default=False,is_flag=True)
@click.option("--output","-o", help="Output file (will have a '.js' extension).",required=False, default="")
@click.option("--prefix","-p", help="Cassette prefix.",required=False, default=BLOCK_NAME)
@click.option("--title","-t", help="Cassette title (for Virtual Sphere).",required=False, default="NONE")
@click.option("--silent","-s", help="Silent (no output).",required=False,default=False,is_flag=True)
@click.version_option(version=_version, package_name=_package_name, message=_message)
def cli(base, input, output, prefix, title, cassette, noheader, silent):
    
    # Announcement
    if not(silent):
        click.secho(_package_name + ' ' + _version + ' on ' + TODAY + CR, fg="green", bold=True)
        click.secho('Options: ' + ('No JS header' if noheader else 'With JS header'), fg="green")
        click.secho('         ' + ('With cassette output' if cassette else 'No cassette output') + CR, fg="green")

    #
    # Validate options supplied
    #

    # Open the binary file for reading
    binary_data = read_input_file(input);
    if iserror(binary_data):
        if (geterror(binary_data)=='FileNotFoundError'):
            click.secho('Input file not found: ' + input, fg="red", err=True)
            exit()
    else:
        if not(silent):
            click.secho('Read ' + str(len(binary_data)) + ' bytes from input file : ' + input + CR   , fg="green")

    # Check prefix parameter
    if len(prefix) != 2:
        click.secho('Prefix should either be empty or 2 characters: ' + prefix, fg="red", err=True)
        exit()
        
    # Construct output filename if none is supplied
    if output == "":
        output = input + EXTENSION;
    
    # The business end.....
    with open(output,'w') as file:
        
        # Output the first stage of information to allow the file to be appended to the Virtual Sphere codebase
        write_preamble(file, input, prefix, title, base, noheader)

        # Output the binary content of the executable in the correct format
        write_binary_content(file, binary_data, prefix)
        if not(silent):
            click.secho('Written binary content         : ' + str(len(binary_data) + EXTRA_DATA)+ ' bytes', fg="green")
        
        # Output the final stage of information to the data block and close the braces etc
        write_postamble(file)
        if not(silent):
            click.secho(CR + 'Output JS file created         : ' + output + CR, fg="green")

    if cassette != "":
        cassette_file = cassette + CASSETTE_EXTENSION
        encode.write_wav(input,cassette_file);
        click.secho('Cassette file created          : ' + cassette_file, fg="green")
        

if __name__ == '__main__':
    cli()

