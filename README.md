![download_resize](https://github.com/user-attachments/assets/5b9542cb-a6f4-4d07-ab24-7eb8b6e7cddf)
# SPARKY
SPGR pulse sequence for ARbitrary Kspace trajectories

1. After externally generating the desired kspace trajectory, use sparky() function to generate the toppe sequence.
The kspace trajectory does not need to include ramps or pre/rewinders, but it does need to be pre-constrained for slew
and gradient limits. Check the code or run "help sparky" in matlab to see its arguments.

2. Run the sequence on the scanner using toppe v6 framework and transfer its pfile back to the same directory
containing kspace.mat

3. Recon the image from this directory by using the example script "recon_sparky.m"
