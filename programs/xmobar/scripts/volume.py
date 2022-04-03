#!/usr/bin/env python

import subprocess

USE_SYMBOLS = True
VOLUME_COMMAND = 'amixer get Master'.split(' ')
VOLUME_SYMBOLS = {
  "0":   "𝒫", # "∅"
  "10":  "−",
  "20":  "=",
  "30":  "≡",
  "40":  "∫",
  "50":  "∮",
  "60":  "∬",
  "70":  "∯",
  "80":  "∭",
  "90":  "∰",
  "100": "⨌",
}

def get_volume():
  volumeData = subprocess \
    .check_output(VOLUME_COMMAND) \
    .decode() \
    .split('\n')[5] \
    .strip() \
    .split(' ')

  volume_level = int(volumeData[-2][1:-2])

  if USE_SYMBOLS:
    volume = VOLUME_SYMBOLS[str((volume_level // 10) * 10)]
    if volumeData[-1] == '[off]':
      volume = 'Ψ'
  else:
    volume = f'{volume_level}%'
    if volumeData[-1] == '[off]':
      volume = 'M'

  return volume

if __name__ == '__main__':
  print(get_volume())
