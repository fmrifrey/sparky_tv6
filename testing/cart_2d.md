# Cartesian Sequence Testing

## Experiment 1: fully sampled 2D cartesian

Generate a 2D cartesian grid:

<img width="805" alt="Screenshot 2024-08-30 at 7 34 41 AM" src="https://github.com/user-attachments/assets/5101b938-a269-4654-a24d-4d0229f8775d">

Convert to 3D kspace coordinates:

<img width="270" alt="Screenshot 2024-08-30 at 7 36 08 AM" src="https://github.com/user-attachments/assets/b772b706-d48b-4c81-af8e-688e28b869a5">

Generate sparky sequence:

<img width="473" alt="Screenshot 2024-08-30 at 7 37 13 AM" src="https://github.com/user-attachments/assets/4f5e9bfa-4d6c-45fc-8b5d-18d101290b0a">

--> These files will be generated:

<img width="173" alt="Screenshot 2024-08-30 at 7 37 30 AM" src="https://github.com/user-attachments/assets/fc579be3-8eb7-46a6-9a67-9152609e3667">

Transfer files to the scanner (if you have coppe set up, use it here!)

<img width="378" alt="Screenshot 2024-08-30 at 7 39 05 AM" src="https://github.com/user-attachments/assets/b0cc49ef-8abf-476f-9693-a4c61e529740">

Set toppe v6 parameters on the pulse sequence (entry file name should match the number you used in coppe):

<img width="329" alt="Screenshot 2024-08-30 at 7 41 44 AM" src="https://github.com/user-attachments/assets/34990f56-dd7d-4a81-8f87-b9dee283b66b">

Also make sure enableDynamicWavs is turned ON from the CV menu:

<img width="376" alt="Screenshot 2024-08-30 at 7 43 50 AM" src="https://github.com/user-attachments/assets/bb7083e6-3898-4b58-ade5-606156b98f64">

Transfer the generated pfile back to the directory you generated the sequence from:

<img width="455" alt="Screenshot 2024-08-30 at 7 45 58 AM" src="https://github.com/user-attachments/assets/00adc8e6-eb95-4ef9-9285-6549a5875853">

Run `recon_sparky.m` from the directory, after changing the recon settings at the top of the script:

<img width="163" alt="Screenshot 2024-08-30 at 7 49 26 AM" src="https://github.com/user-attachments/assets/fc24a2d9-3d9d-4fca-950f-a5e93caf315c">

<img width="402" alt="Screenshot 2024-08-30 at 7 49 40 AM" src="https://github.com/user-attachments/assets/302e677a-1176-40b6-ac28-ad4bedff70f8">

<img width="449" alt="Screenshot 2024-08-30 at 7 50 05 AM" src="https://github.com/user-attachments/assets/0ff5ddbe-c8f6-4321-b5ab-0125c2a9ea79">

note: this is the most basic sequence ran with all defaults - things look better when you add disdaqs, center-out trajectories, flip angle optimization, etc. :)

## Experiment 2: R=2 undersampling along ky + PRx

First, acquire a fully sampled image with multiple coils:
