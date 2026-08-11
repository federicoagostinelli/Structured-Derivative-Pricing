function printFourierPricingTable(titleText, xVals, strikeVals, priceQuad, priceFft, idxPrint)
% PRINTFOURIERPRICINGTABLE Prints a compact Quadrature-vs-FFT pricing table.
%
% INPUTS:
%   titleText  : string
%                Title printed above the table.
%
%   xVals      : numeric vector
%                Log-moneyness values, with x = log(F0 / K).
%
%   strikeVals : numeric vector
%                Strike values corresponding to xVals.
%
%   priceQuad  : numeric vector
%                Prices computed by Fourier quadrature.
%
%   priceFft   : numeric vector
%                Prices computed by FFT.
%
%   idxPrint   : optional numeric vector
%                Indices of rows to print. If omitted, all rows are printed.
%
% OUTPUT:
%   none. The function prints a table to the command window.

    xVals = xVals(:);
    strikeVals = strikeVals(:);
    priceQuad = priceQuad(:);
    priceFft = priceFft(:);

    if nargin < 6 || isempty(idxPrint)
        idxPrint = 1:numel(xVals);
    end

    absErr = abs(priceFft - priceQuad);
    relErr = absErr ./ max(abs(priceQuad), 1e-14);

    disp(' ')
    fprintf('--- %s ---\n', titleText)

    fprintf('%10s %14s %14s %14s %14s %14s\n', ...
        'x', 'K', 'Quadrature', 'FFT', 'AbsError', 'RelError');

    for jj = 1:numel(idxPrint)
        i = idxPrint(jj);

        fprintf('%+10.5f %14.6f %14.6f %14.6f %14.6e %14.6e\n', ...
            xVals(i), ...
            strikeVals(i), ...
            priceQuad(i), ...
            priceFft(i), ...
            absErr(i), ...
            relErr(i));
    end

end