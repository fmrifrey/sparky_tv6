1. After externally generating the desired kspace trajectory, use sparky() function to generate the toppe sequence.
Check the code or run "help sparky" in matlab to see its arguments.

2. Run the sequence on the scanner using toppe v6 framework and transfer its pfile back to the same directory
containing kspace.mat

3. Recon the image from this directory by using the example script "recon_sparky.m"
