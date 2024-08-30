%% set parms
fov = 14;
N = 128;
nd = 2;
niter = 5;

%% get pfile and trajectory
p = dir('P*.7');
p = toppe.utils.loadpfile(p(1).name);
raw = permute(p,[1,5,3,2,4]);
raw = flip(raw,1);
load kspace.mat

%% correct sizes
if size(kspace,1) > size(raw,1)
    warning('size(kspace,1) < size(raw,1)');
    kspace = kspace(1:size(raw,1),:,:);
elseif size(kspace,1) < size(raw,1)
    warning('size(kspace,1) < size(raw,1)');
    raw = raw(1:size(kspace,1),:,:);
end

%% compress coils
nc = size(raw,3);
if ~exist('smap','var') && nc > 1
    nc = 1;
    raw = ir_mri_coil_compress(raw,'ncoil',nc);
end
    
%% set nufft arguments
nufft_args = {N*ones(1,nd), ...
    6*ones(1,nd), ...
    2*N*ones(1,nd), ...
    N/2*ones(1,nd), ...
    'table', 2^10, ...
    'minmax:kb'};
    
%% form NUFFT operator
omega = 2*pi*fov/N.*reshape(kspace(:,:,1:nd),[],nd);
omega_msk = vecnorm(omega,2,2) < pi;
omega = omega(omega_msk,:);
A = Gnufft(true(N*ones(1,nd)),[omega,nufft_args]); % NUFFT
w = rec.pipedcf(A,15); % calculate density compensation
if nc > 1 % sensitivity encoding
    A = Asense(A,smap);
end

%% initialize with density compensated adjoint solution
b = reshape(raw,[],nc);
b = b(omega_msk,:);
x0 = A' * (w.*b);
x0 = ir_wls_init_scale(A, b, x0);

imagesc(abs(x))

%% solve with CG
x = cg_solve(x0, A, b, niter);
x = reshape(x,N*ones(1,nd));

imagesc(abs(x));