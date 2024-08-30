function sparky(ktraj,varargin)
% SPGR sequence with arbitrary kspace trajectory
% written in toppe v6 by David Frey
% kspace = kspace trajectory ([N x Nshots x 3] cm^-1)
% 
% args.te: echo time (center of excitation --> beginning of readout) (ms)
% args.tr: repitition time (ms)
% args.slabthk: slice thickness (cm)
% args.rffa: tipdown flip angle (deg)
% args.rftbw: tipdown time-bandwidth product
% args.rfdur: tipdown pulse duration (ms)
% args.rfspoil = 1: option to do rf spoiling
% args.spoilcyc: number of phase cycles per voxel for gradient spoiling
% args.padtime: extra deadtime in each core (us)
% args.ndisdaqs: number of disdaq shots at beginning of sequence
%

%% Set defaults
if nargin < 1 || isempty(ktraj)
    ktraj = zeros(501,1,3); % zeros - just get 500 samples FID
end

defaults.te = 'min'; % echo time (center of excitation --> beginning of readout) (ms)
defaults.tr = 'min'; % repitition time (ms)

defaults.slabthk = 3; % slice thickness (cm)

defaults.rffa = 10; % tipdown flip angle (deg)
defaults.rftbw = 8; % tipdown time-bandwidth product
defaults.rfdur = 3.2; % tipdown pulse duration (ms)
defaults.rfspoil = 1; % option to do rf spoiling

defaults.spoilcyc = 4; % number of phase cycles per voxel for gradient spoiling
defaults.padtime = 500; % extra deadtime in each core (us)

defaults.ndisdaqs = 0; % number of disdaq shots at beginning of sequence

% parse variable inputs (will overwrite loaded arguments!)
args = toppe.utils.vararg_pair(defaults, varargin);

%% Generate pulse sequence modules
sys = toppe.systemspecs;

% Create tipdown SLR pulse
[rf,gzrf,rffreq] = toppe.utils.rf.makeslr( ...
    args.rffa, ...
    args.slabthk, ...
    args.rftbw, ...
    args.rfdur, ...
    eps(), ...
    sys, ...
    'writeModFile', false ...
    );
toppe.writemod(sys, ...
    'rf', rf, ...
    'gz', gzrf, ...
    'nChop', [10,10], ...
    'ofname', 'tipdown.mod');

% Generate the readout gradients
nshots = size(ktraj,2);
[g,nramp] = seq.gengrads(sys,ktraj);
gx = g(:,:,1);
gy = g(:,:,2);
gz = g(:,:,3);
toppe.writemod(sys, ...
    'gx', gx, ...
    'gy', gy, ...
    'gz', gz, ...
    'nChop', nramp, ...
    'ofname', 'readout.mod');

% Create a crusher gradient
gspoil = toppe.utils.makecrusher(args.spoilcyc, ...
    args.slabthk, ...
    sys, ...
    0, ...
    sys.maxSlew, ...
    sys.maxGrad);
toppe.writemod(sys, ...
    'gz', gspoil, ...
    'ofname', 'crusher.mod');

% Calculate all module durations
dur_tipdown = length(toppe.readmod('tipdown.mod'))*sys.raster + args.padtime; % us
dur_readout = length(toppe.readmod('readout.mod'))*sys.raster + args.padtime; % us
dur_crusher = length(toppe.readmod('crusher.mod'))*sys.raster + args.padtime; % us

% Calculate minimum echo time and tgap1
[~,peakidx] = max(abs(rf)); % get rf peak sample
minte = dur_tipdown - peakidx*sys.raster + ... % rf pulse duration (post-peak)
    args.padtime + ... % some extra fluffiness
    nramp(1)*sys.raster; % effective echo delay (wrt start of readout)
minte = minte*1e-3; % convert to ms
if strcmpi(args.te,'min')
    args.te = minte;
    fprintf('spgr auto min te: effective echo time = %.3fms\n', args.te);
elseif (args.te < minte)
    error('te (%.3fms) < minte (%.3fms)', args.te, minte);
end
tgap1 = args.te - minte;
fprintf('spgr gap: gap time 1 = %.3fms\n', tgap1);

% Calculate minimum repitition time and tgap2
mintr = dur_tipdown + ... % tipdown (us)
    tgap1*1e3 + ... % gap 1 (us)
    dur_readout + ... % readout (us)
    dur_crusher; % crusher (us)
mintr = mintr*1e-3; % convert to ms
if strcmpi(args.tr,'min')
    args.tr = mintr;
    fprintf('spgr auto tr: repitition time = %.3fms\n', args.tr);
elseif (args.tr < mintr)
    error('tr (%.3fms) < mintr (%.3fms)', args.tr, mintr);
end
tgap2 = args.tr - mintr;
fprintf('spgr gap: gap time 2 = %.3fms\n', tgap2);

% Write entry file
toppe.writeentryfile('toppeN.entry');

% Set cores file entries
toppe.writecoresfile( {...
    [3,1,0], ... % tipdown
    [2,0] ... % readout
    })

% Set modules file text
modulesfiletext = [ ...
    sprintf("tipdown.mod %d 1 0 -1", dur_tipdown)
    sprintf("readout.mod %d 0 1 -1", dur_readout)
    sprintf("crusher.mod %d 0 0 -1", dur_crusher)
    ];

% Write out cores and modules files
seq.writemodulesfile(modulesfiletext);

%% Write the scan loop
toppe.write2loop('setup',sys,'version',6);
for shotn = 1-args.ndisdaqs:nshots % loop through shots

    % Write crusher to loop
    toppe.write2loop('crusher.mod', sys, ...
        'version', 6, ...
        'trigout', 0, ...
        'core', 1);

    % Write tipdown to loop
    toppe.write2loop('tipdown.mod', sys, ...
        'RFspoil', args.rfspoil, ...
        'RFoffset', rffreq, ...
        'RFphase', 0, ...
        'version', 6, ...
        'trigout', 0, ...
        'core', 1);

    % Write tgap1 to loop
    toppe.write2loop('delay', sys, ...
        'textra', tgap1, ...
        'core', 1);

    % Write readout to loop
    if shotn > 0
        toppe.write2loop('readout.mod', sys, ...
            'RFspoil', args.rfspoil, ...
            'echo', 1, ...
            'slice', 1, ...
            'view', shotn, ...
            'waveform', shotn, ...
            'RFphase', 0, ...
            'version', 6, ...
            'trigout', 0, ...
            'dabmode', 'on', ...
            'core', 2);
    else
        toppe.write2loop('readout.mod', sys, ...
            'RFspoil', args.rfspoil, ...
            'version', 6, ...
            'RFphase', 0, ...
            'trigout', 0, ...
            'dabmode', 'off', ...
            'core', 2);
    end

    % Write tgap2 to loop
    toppe.write2loop('delay', sys, ...
        'textra', tgap2, ...
        'core', 2);
    

end

% Finish loop
toppe.write2loop('finish',sys);
toppe.preflightcheck('toppeN.entry','seqstamp.txt',sys);

% Save arguments to file
save args.mat args
save ktraj.mat ktraj

end