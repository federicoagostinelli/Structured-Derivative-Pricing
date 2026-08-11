function cMC = exercise4MC(Nsim, sigma, k, eta, muNIG, t, F0, B, xVals)
% EXERCISE4MC Direct Monte Carlo pricing of European calls under the NIG model.
%
%   cMC = exercise4MC(Nsim, sigma, k, eta, muNIG, t, F0, B, xVals)
%
%   Simulates the NIG terminal log-return once and prices European call
%   options for all log-moneyness values in xVals using the same Monte Carlo
%   scenarios.
%
% INPUTS:
%   Nsim   : integer
%            Number of Monte Carlo simulations.
%
%   sigma  : numeric scalar
%            Volatility parameter.
%
%   k      : numeric scalar
%            Variance parameter of the inverse Gaussian subordinator.
%
%   eta    : numeric scalar
%            Skew parameter.
%
%   muNIG  : numeric scalar
%            Martingale correction obtained from the characteristic exponent.
%
%   t      : numeric scalar
%            Time to maturity.
%
%   F0     : numeric scalar
%            Forward price at initial time.
%
%   B      : numeric scalar
%            Discount factor to maturity.
%
%   xVals  : numeric scalar or vector
%            Log-moneyness values, with x = log(F0 / K).
%            Therefore K = F0 * exp(-x).
%
% OUTPUT:
%   cMC    : numeric column vector
%            Monte Carlo call prices, one for each value in xVals.

    % Force row vector so that broadcasting produces an Nsim-by-nX matrix.
    xVals = xVals(:).';

    % ------------------------------------------------------------
    % Simulate the inverse Gaussian subordinator
    % ------------------------------------------------------------
    % We simulate S_t ~ IG(muIG, lambdaIG), with:
    %   E[S_t]   = t
    %   Var[S_t] = k t
    %
    % For an inverse Gaussian IG(mu, lambda):
    %   E[X]   = mu
    %   Var[X] = mu^3 / lambda
    %
    % Hence:
    %   muIG     = t
    %   lambdaIG = t^2 / k
    muIG = t;
    lambdaIG = t^2 / k;

    V = randn(Nsim, 1);
    Y = V.^2;

    X1 = muIG ...
       + (muIG^2 .* Y) ./ (2 * lambdaIG) ...
       - (muIG ./ (2 * lambdaIG)) .* ...
         sqrt(4 * muIG * lambdaIG .* Y + muIG^2 .* Y.^2);

    U = rand(Nsim, 1);

    St = X1;
    mask = U > muIG ./ (muIG + X1);
    St(mask) = muIG^2 ./ X1(mask);

    % ------------------------------------------------------------
    % Simulate the NIG terminal log-return
    % ------------------------------------------------------------
    g = randn(Nsim, 1);

    fT = muNIG ...
       + sigma .* sqrt(St) .* g ...
       - (0.5 + eta) .* sigma.^2 .* St;

    % ------------------------------------------------------------
    % Price calls for all x values using the same simulated paths
    % ------------------------------------------------------------
    % x = log(F0/K), hence K = F0 * exp(-x).
    % ST is Nsim-by-1, Kvals is 1-by-nX, payoff is Nsim-by-nX.
    ST = F0 .* exp(fT);
    Kvals = F0 .* exp(-xVals);

    payoff = max(ST - Kvals, 0);

    cMC = B .* mean(payoff, 1).';
end