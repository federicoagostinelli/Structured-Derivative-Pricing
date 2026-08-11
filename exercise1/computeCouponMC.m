function [couponMC, CallMC, MCError, details] = computeCouponMC(Nsim, alpha, refDate, matDate, dfMat, weights, strike, dividend1, dividend2, rho, sigma1, sigma2, notional)
% COMPUTECOUPONMC Prices an Arithmetic Basket Call Option using Monte Carlo
% Simulations and Cholesky decomposition for the correlation.
%
% INPUTS:
%   Nsim            : Number of Monte Carlo simulations to run
%   alpha           : Participation coefficient
%   refDate         : Valuation date.
%   matDate         : Maturity date.
%   dfMat              : Exact discount factor from maturity to present
%   weights         : Two-element vector of basket weights.
%   strike          : Strike level of the option
%   dividend1       : Continuous dividend yield of asset 1.
%   dividend2       : Continuous dividend yield of asset 2.
%   rho             : Correlation between the two assets
%   sigma1          : Implied volatility of asset 1
%   sigma2          : Implied volatility of asset 2
%   notional        : Principal amount
%
% OUTPUTS:
%   couponMC       : Monetary coupon paid at maturity.
%   CallMC         : Discounted expected price of the Call option
%   MCError        : Standard error of the Monte Carlo price estimate
%   details         : Struct containing intermediate quantities.

% Ensure it's a column vector
w = weights(:);

% Normalized starting prices for the index/basket calculation
S0_1 = 1;
S0_2 = 1;

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(refDate, matDate, 3);

% Compute the scalar continuous risk-free rate
r = -log(dfMat) / T;

% Draw Nsim independent standard normal random variables
Z1 = randn(Nsim, 1);
Z2 = randn(Nsim, 1);

% Apply Cholesky decomposition for the correlation
W1 = Z1;
W2 = rho * Z1 + sqrt(1 - rho^2) * Z2;
% Now, W1 and W2 have exactly rho correlation.

% (Added mapping to match your input variable names to your formula variables)
d1 = dividend1;
d2 = dividend2;

% Simulate the Asset Prices using the exact solution to the Geometric Brownian Motion SDE
S1_T = S0_1 * exp((r - d1 - 0.5 * sigma1^2) * T + sigma1 * sqrt(T) .* W1);
S2_T = S0_2 * exp((r - d2 - 0.5 * sigma2^2) * T + sigma2 * sqrt(T) .* W2);

% The basket value is the weighted sum of the two terminal prices
Basket_T = w(1) * S1_T + w(2) * S2_T;

% Compute Call Payoff
payoffs = max(Basket_T - strike, 0);

% The price is the discounted average of all simulated payoffs
CallMC = dfMat * mean(payoffs);

% Compute the standard error of the Monte Carlo simulation (Optional)
MCError = dfMat * std(payoffs) / sqrt(Nsim);

% Compute Final Coupon Payment
couponMC = notional * alpha * CallMC;

% Details for the report
details = struct();
details.Nsim = Nsim;
details.meanBasket_T = mean(Basket_T);
details.CallMC = CallMC;
details.MCCoupon = couponMC;
details.MCError = MCError;

end