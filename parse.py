'''
Finds the midpoint coordinates of a button in an Android .xml file and prints
the coordinates to stdout
Params:
    1. Name of the xml file
    2. Text of the button to find the coordinates for
'''

import xml.etree.ElementTree as ET
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("filename")
parser.add_argument("button_text")
args = parser.parse_args()

tree = ET.parse(args.filename)
root = tree.getroot()
for elem in root.iter():
    att = elem.attrib
    if ("text" in att):
        text_val = att["text"]
        if (text_val == args.button_text):
            bound = att["bounds"][1:-1].split("][")
            left_top = bound[0].split(",")
            right_btm = bound[1].split(",")
            midpoint_x = int((int(left_top[0]) + int(right_btm[0]))/2)
            midpoint_y = int((int(left_top[1]) + int(right_btm[1]))/2)
            print(midpoint_x, midpoint_y)
            break




