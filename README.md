# SPARKY
## SPGR pulse sequence for ARbitrary Kspace trajectories
![download](https://github.com/user-attachments/assets/97bd96f6-cddf-4a43-a21b-52191e121b4c)

1. After externally generating the desired kspace trajectory, use sparky() function to generate the toppe sequence.
The kspace trajectory does not need to include ramps or pre/rewinders, but it does need to be pre-constrained for slew
and gradient limits. Check the code or run "help sparky" in matlab to see its arguments.

2. Run the sequence on the scanner using toppe v6 framework and transfer its pfile back to the same directory
containing kspace.mat

3. Recon the image from this directory by using the example script "recon_sparky.m"
