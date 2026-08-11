function [cQuad, cFFT, cMCdirect, cMCfromDigital, cRes, Kvals] = ...
    computePriceComparison(xVals, charFunc, B, F0, M, x1, z1, ...
                           Nsim, p_plus, p_minus, mu, ST_fromCDF)
% computePriceComparison
% Compute call prices with:
%   1) Fourier quadrature
%   2) Fourier FFT
%   3) Direct Monte Carlo
%   4) Monte Carlo from CDF reconstructed from digital prices
%
% INPUTS:
%   xVals       : vector of log-moneyness values, x = log(F0/K)
%   charFunc    : characteristic function
%   B           : discount factor
%   F0          : forward at time 0
%   M, x1, z1   : FFT parameters
%   Nsim        : number of MC simulations (used by exercise3MC)
%   p_plus      : model parameter
%   p_minus     : model parameter
%   mu          : drift correction
%   ST_fromCDF  : simulated terminal prices from reconstructed CDF
%
% OUTPUTS:
%   cQuad          : call prices via quadrature
%   cFFT           : call prices via FFT
%   cMCdirect      : direct MC call prices
%   cMCfromDigital : MC-from-digital call prices
%   cRes           : call prices via residue theorem
%   Kvals          : corresponding strikes

    xVals = xVals(:);
    ST_fromCDF = ST_fromCDF(:);

    %% Strikes 
    Kvals = F0 * exp(-xVals);

    %% Fourier quadrature and FFT
    cQuad = arrayfun(@(x) runPricingFourier(charFunc, x, B, F0), xVals);
    cFFT  = arrayfun(@(x) runPricingFourier(charFunc, x, B, F0, M, x1, z1), xVals);

    %% Residuals
    cRes = arrayfun(@(x) exercise3Residuals(p_plus, p_minus, mu, F0, B, x), xVals);

    %% Direct MC
    cMCdirect = exercise3MC(Nsim, p_plus, p_minus, mu, F0, B, xVals);
    
    %% MC from digital
    % payoffMatrix(i,j) = max(ST_fromCDF(i) - Kvals(j), 0)
    payoffMatrix = max(ST_fromCDF - Kvals.', 0);
    cMCfromDigital = B * mean(payoffMatrix, 1).';
end