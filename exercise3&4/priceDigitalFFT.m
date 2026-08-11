function d = priceDigitalFFT(f, x, B, M, x1, z1)
% priceDigitalFFT Compute digital option prices by Fourier methods.
%
%   Inputs:
%       f  : characteristic function handle phi(z)
%       x  : log-moneyness x = log(F0/K)
%       B  : discount factor B(t0,t)
%       M  : (optional) integer, N = 2^M FFT grid points
%       x1 : (optional) first point of integration grid
%       z1 : (optional) first point of output grid
%
% In this implementation, the numerical Fourier routine returns a quantity
% such that
%    D(x)/B = exp(x/2) * I(x)
% i.e. the half-residue contribution is already incorporated by the
% transform convention / numerical inversion routine.

    g = @(xi) f(-xi - 1i/2) ./ (2*pi .* (1/2 - 1i .* xi));

    if nargin == 3
        I = arrayfun(@(xval) computeIntegralQuadrature( ...
            @(xi) exp(-1i .* xi .* xval) .* g(xi)), x);
        d = real(B .* (exp(x./2) .* I));
        return
    end

    if nargin ~= 6
        error('priceDigitalFFT requires either 3 inputs or 6 inputs.');
    end

    [Ifft, ~, z] = computeIntegralFFT(g, M, x1, z1);
    I = interp1(z, Ifft, x, 'spline');
    d = real(B .* (exp(x./2) .* I));
end