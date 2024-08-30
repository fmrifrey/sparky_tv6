function x_star = cg_solve(x0, A, b, niter, msg_pfx)

    % set default message prefix
    if nargin < 5
        msg_pfx = '';
    end

    % loop through iterations of conjugate gradient descent
    x_star = x0;
    r = reshape(A'*(b - A*x_star), size(x_star));
    p = r;
    rsold = r(:)' * r(:);
    for n = 1:niter
        fprintf('%sCG iteration %d/%d, res: %.3g\n', msg_pfx, n, niter, rsold);
        
        % calculate the gradient descent step
        AtAp = reshape(A'*(A*p), size(x_star));
        alpha = rsold / (p(:)' * AtAp(:));
        x_star = x_star + alpha * p;

        % calculate new residual
        r = r - alpha * AtAp;
        rsnew = r(:)' * r(:);
        p = r + (rsnew / rsold) * p;
        rsold = rsnew;

        if exist('exitcg','var')
            break % set a variable called "exitcg" to exit at current iteration when debugging
        end

    end
    
end