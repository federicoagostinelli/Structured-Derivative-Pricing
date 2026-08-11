function [price, Xsim, yGrid, cdfGrid, DGrid] = callMCFromDigital( ...
    digitalPricer, xTarget, F0, B, xMin, xMax, Nx, Nsim)
% callMCFromDigital Reconstruct the CDF of log-returns from digital prices,
% simulate by inverse transform, and price a call by Monte Carlo.
%
%   [price, Xsim, yGrid, cdfGrid, DGrid] = callMCFromDigital( ...
%       digitalPricer, xTarget, F0, B, xMin, xMax, Nx, Nsim)
%
%   Inputs:
%       digitalPricer : function handle
%           Function returning digital prices D(x) for given log-moneyness x.
%       xTarget       : scalar
%           Log-moneyness of the call to be priced, with x = log(F0 / K).
%       F0            : scalar
%           Forward at time 0.
%       B             : scalar
%           Discount factor.
%       xMin          : scalar
%           Lower bound of the x-grid used to reconstruct the CDF.
%       xMax          : scalar
%           Upper bound of the x-grid used to reconstruct the CDF.
%       Nx            : integer
%           Number of grid points.
%       Nsim          : integer
%           Number of Monte Carlo samples.
%
%   Outputs:
%       price   : scalar
%                 Monte Carlo estimate of the call price.
%       Xsim    : vector
%                 Simulated log-returns X = log(Ft/F0).
%       yGrid   : vector
%                 Grid for the log-return variable X.
%       cdfGrid : vector
%                 Reconstructed CDF values of X on yGrid.
%       DGrid   : vector
%                 Digital prices on the original x-grid.
%
%   Notes:
%       - Here x = log(F0 / K), so
%           D(x) = B * P(X >= -x),
%         where X = log(Ft/F0).
%       - Therefore the CDF of X is
%           F_X(y) = 1 - D(-y)/B.
%       - The CDF is inverted numerically by interpolation.

    % Grid in x = log(F0 / K)
    xGrid = linspace(xMin, xMax, Nx);

    % Digital prices on x-grid
    DGrid = digitalPricer(xGrid);

    % Build CDF of X on y-grid:
    % F_X(y) = 1 - D(-y)/B
    yGrid   = -flip(xGrid);
    cdfGrid = 1 - flip(DGrid) ./ B;

    % Numerical cleanup
    cdfGrid = real(cdfGrid);
    cdfGrid(~isfinite(cdfGrid)) = NaN;

    valid = isfinite(cdfGrid);
    yGrid = yGrid(valid);
    cdfGrid = cdfGrid(valid);

    if numel(cdfGrid) < 2
        error('CDF reconstruction failed: too few valid grid points.');
    end

    % Clamp to [0,1] and enforce monotonicity
    cdfGrid = max(cdfGrid, 0);
    cdfGrid = min(cdfGrid, 1);
    cdfGrid = cummax(cdfGrid);

    % Remove duplicates
    [cdfUnique, idx] = unique(cdfGrid, 'stable');
    yUnique = yGrid(idx);

    if numel(cdfUnique) < 2
        error(['CDF grid is degenerate: all values are effectively identical. ', ...
               'Enlarge [xMin, xMax] or check priceDigitalFFT.']);
    end

    % Diagnostic warning
    if cdfUnique(1) > 1e-3 || cdfUnique(end) < 1 - 1e-3
        warning(['CDF grid does not cover the full probability range well. ', ...
                 'Consider enlarging [xMin, xMax].']);
    end

    % Uniform samples
    U = rand(Nsim, 1);

    % Clamp to interpolation range
    U = max(U, cdfUnique(1));
    U = min(U, cdfUnique(end));

    Xsim = interp1(cdfUnique, yUnique, U, 'linear');

    % Price call: xTarget = log(F0 / K) => K = F0 * exp(-xTarget)
    K = F0 * exp(-xTarget);
    ST = F0 * exp(Xsim);
    payoff = max(ST - K, 0);

    price = B * mean(payoff);
end