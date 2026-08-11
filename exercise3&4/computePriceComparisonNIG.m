function [cQuad, cFFT, cMCfromDigital, cMCexercise4, Kvals] = ...
    computePriceComparisonNIG(xVals, B, F0, sigma, k, eta, t, ...
    xGrid, Nsim, ST_fromCDF, charFuncNIG, muNIG)
% computePriceComparisonNIG
% Compare call prices under NIG using:
%   1) Fourier quadrature
%   2) Fourier FFT
%   3) Monte Carlo from reconstructed CDF
%   4) Direct Monte Carlo under NIG

    xVals = xVals(:);
    ST_fromCDF = ST_fromCDF(:);
    Kvals = F0 * exp(-xVals);

    % FFT grid parameters recovered from xGrid
    N  = length(xGrid);
    dx = xGrid(2) - xGrid(1);
    dz = 2*pi/(N*dx);
    z1 = -N/2 * dz;
    M  = round(log2(N));

    % Fourier quadrature
    cQuad = runPricingFourier(charFuncNIG, xVals.', B, F0).';
    cQuad = cQuad(:);

    % Fourier FFT
    cFFT = runPricingFourier(charFuncNIG, xVals.', B, F0, M, xGrid(1), z1).';
    cFFT = cFFT(:);

    % MC from digital / reconstructed CDF
    payoffMatrix = max(ST_fromCDF - Kvals.', 0);
    cMCfromDigital = B * mean(payoffMatrix, 1).';

    % Direct MC under NIG
    % exercise4MC simulates once and evaluates all xVals on the same paths.
    cMCexercise4 = exercise4MC(Nsim, sigma, k, eta, muNIG, t, F0, B, xVals);
    cMCexercise4 = cMCexercise4(:);

end