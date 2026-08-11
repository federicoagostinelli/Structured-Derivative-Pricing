function [dfMat, coupon, details] = computeCoupon(alpha, refDate, matDate, curveDates, curveDiscounts, weights, strike, dividend1, dividend2, rho, sigma1, sigma2, notional)
% computeCoupon Calculates the final monetary payoff of a
% European Call on an arithmetic two-asset basket using Moment Matching.
%
% INPUTS:
%   alpha           : Participation coefficient.
%   refDate         : Valuation date.
%   matDate         : Maturity date.
%   curveDates      : Yield curve pillar dates.
%   curveDiscounts  : Discount factors at curve pillar dates.
%   weights         : Two-element vector of basket weights.
%   strike          : Strike level of the option.
%   dividend1       : Continuous dividend yield of asset 1.
%   dividend2       : Continuous dividend yield of asset 2.
%   rho             : Correlation between the two assets.
%   sigma1          : Implied volatility of asset 1.
%   sigma2          : Implied volatility of asset 2.
%   notional        : Principal amount.
%
% OUTPUTS:
%   dfMat           : Discount factor at maturity.
%   coupon          : Monetary coupon paid at maturity.
%   details         : Struct containing intermediate quantities.

% Ensure weights is a column vector
w = weights(:);

% Normalized starting value of the assets
S0_1 = 1;
S0_2 = 1;

% Calculate Time to Maturity (T) in years (Act/365)
T = yearfrac(refDate, matDate, 3);

% Extract the exact interpolated discount factor for the maturity date
dfMat = getDiscountFactorByZeroRatesLinearInterp(refDate, matDate, curveDates, curveDiscounts);

% Compute the scalar continuous risk-free rate
r = -log(dfMat) / T;

% Compute Fwd's
F1 = S0_1 * exp((r - dividend1) * T);
F2 = S0_2 * exp((r - dividend2) * T);

% First Moment (Expected value of the sum)
M1 = w(1)*F1 + w(2)*F2;

% Second Moment (Expected value of the sum squared)
M2 = (w(1)^2 * F1^2 * exp(sigma1^2 * T)) + ...
    (w(2)^2 * F2^2 * exp(sigma2^2 * T)) + ...
    (2 * w(1) * w(2) * F1 * F2 * exp(rho * sigma1 * sigma2 * T));

% Compute basket variance and volatility
basketVariance = (1/T) * log(M2 / (M1^2));

basketSigma = sqrt(basketVariance);

% Using M1 as the Forward Price of the basket
d1_bs = (log(M1 / strike) + 0.5 * basketSigma^2 * T) / (basketSigma * sqrt(T));
d2_bs = d1_bs - basketSigma * sqrt(T);

% Call Price using Black
callPrice = dfMat * (M1 * normcdf(d1_bs) - strike * normcdf(d2_bs));

% Final Payoff
coupon = notional * alpha * callPrice;

% Details for the report
details = struct();
details.basketVariance = basketVariance;
details.basketSigma = basketSigma;
details.callPrice = callPrice;
details.coupon_price = coupon;

end