#!/usr/bin/env python3
"""Send a bounded controller command to the opt-in Simulator probe build."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('udid')
for axis in ('x', 'y', 'camera-x', 'camera-y'):
    parser.add_argument('--' + axis, type=float, default=0)
parser.add_argument('--button', action='append', choices=['A', 'B', 'X', 'Y', 'LB', 'RB', 'LT', 'RT'], default=[])
parser.add_argument('--seconds', type=float, default=0.2)
parser.add_argument('--pause-after', action='store_true',
                    help='pulse Start at expiry; use only from unpaused gameplay')
args = parser.parse_args()
if not 0.05 <= args.seconds <= 10 or any(not -1 <= a <= 1 for a in (args.x, args.y, args.camera_x, args.camera_y)):
    parser.error('axes must be within -1...1 and duration within 0.05...10 seconds')
container = subprocess.run(['xcrun', 'simctl', 'get_app_container', args.udid,
                            'com.chrissotraidis.squirrelpad', 'data'],
                           check=True, capture_output=True, text=True).stdout.strip()
path = Path(container) / 'Documents' / 'squirrelpad-sim-input.json'
command = dict(sequence=time.time_ns(), x=args.x, y=args.y, cameraX=args.camera_x,
               cameraY=args.camera_y, buttons=args.button, seconds=args.seconds,
               expiresAt=time.time() + args.seconds, pauseAfter=args.pause_after)
path.parent.mkdir(parents=True, exist_ok=True)
temporary = path.with_suffix('.tmp')
temporary.write_text(json.dumps(command))
os.replace(temporary, path)
print(f'Controller command: stick {args.x},{args.y}; camera {args.camera_x},{args.camera_y}; buttons {args.button}; {args.seconds}s')
