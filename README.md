![download_resize](https://github.com/user-attachments/assets/e3c4a105-a13f-4d95-8cba-1ef84b7d1ff0)
# SPARKY
SPGR pulse sequence for ARbitrary Kspace trajectories

## Development steps:

0. Generate a kspace trajectory waveform. This can be done externally or by using the provided functions for EPI, Radial, and Spiral trajectories in the `/+seq` library. The trajectory does <b>not</b> need to include ramps or pre/rewinders, as sparky will generate these for you using MinTimeGradient. But, it does need to account for hardware and PNS limits during the waveform. Fortunately, toppe.preflightcheck() will crash your sequence if these limits are exceeded.

1. After externally generating the desired kspace trajectory, use sparky() function to generate the toppe sequence. Check the code or run "help sparky" in matlab to see its arguments.

2. Run the sequence on the scanner using toppe v6 framework and transfer its pfile back to the same directory containing ktraj.mat

3. Recon the image from this directory by using the example script "recon_sparky.m"

Refer to the experiments detailed in the `/testing` directory for examples
