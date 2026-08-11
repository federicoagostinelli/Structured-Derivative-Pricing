function printPricingTable(titleText, xVals, strikeVals, priceQuad, priceFft, priceMcDirect, priceMcFromDigital, idxPrint)
% PRINTPRICINGTABLE Prints a compact pricing comparison table.
%
% INPUTS:
%   titleText          : title printed above the table
%   xVals              : log-moneyness values, x = log(F0/K)
%   strikeVals         : strikes corresponding to xVals
%   priceQuad          : quadrature prices
%   priceFft           : FFT prices
%   priceMcDirect      : direct Monte Carlo prices
%   priceMcFromDigital : Monte Carlo prices from reconstructed CDF
%   idxPrint           : optional indices to print. If omitted, prints all rows.
%
% OUTPUT:
%   none. Prints the table to the command window.

    xVals = xVals(:);
    strikeVals = strikeVals(:);
    priceQuad = priceQuad(:);
    priceFft = priceFft(:);
    priceMcDirect = priceMcDirect(:);
    priceMcFromDigital = priceMcFromDigital(:);

    if nargin < 8 || isempty(idxPrint)
        idxPrint = 1:numel(xVals);
    end

    disp(' ')
    fprintf('--- %s ---\n', titleText)

    fprintf('%10s %14s %14s %14s %14s %14s\n', ...
        'x', 'K', 'Quadrature', 'FFT', 'DirectMC', 'MCdigital');

    for jj = 1:numel(idxPrint)
        i = idxPrint(jj);

        fprintf('%+10.5f %14.6f %14.6f %14.6f %14.6f %14.6f\n', ...
            xVals(i), ...
            strikeVals(i), ...
            priceQuad(i), ...
            priceFft(i), ...
            priceMcDirect(i), ...
            priceMcFromDigital(i));
    end

end