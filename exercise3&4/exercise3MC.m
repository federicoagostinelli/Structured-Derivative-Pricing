function prices = exercise3MC(Nsim, p_plus, p_minus, mu, F0, B, xVals)
% exercise3MC Monte Carlo prices of European calls for Exercise 3.
%
%   Simulates the log-return once:
%       f_t = mu + Y_plus - Y_minus
%   where Y_plus ~ Exp(rate = p_plus) and Y_minus ~ Exp(rate = p_minus).
%
%   Inputs:
%       Nsim    : number of Monte Carlo simulations
%       p_plus  : positive rate of the upward exponential component
%       p_minus : positive rate of the downward exponential component
%       mu      : drift fixed by the martingale condition
%       F0      : ATM forward
%       B       : discount factor
%       xVals   : vector of log-moneyness values, x = log(F0/K)
%
%   Output:
%       prices  : row vector of Monte Carlo call prices, one for each x in xVals

    % Simulate once
    ft = mu + exprnd(1/p_plus, Nsim, 1) - exprnd(1/p_minus, Nsim, 1);

    % x = log(F0/K) => K = F0 * exp(-x)
    xVals = xVals(:).';              % force row vector

    payoff = max(exp(ft) - exp(-xVals), 0);
    prices = B * F0 * mean(payoff, 1);
end