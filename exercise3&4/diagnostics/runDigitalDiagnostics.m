function diagResults = runDigitalDiagnostics(digitalPricer, xVals, xMin, xMax, numPoints, headerText, plotTitleText, usePercentFormat, printDigitalPrices)
% RUNDIGITALDIAGNOSTICS Evaluate digital prices and large-grid diagnostics.
%
%   diagResults = runDigitalDiagnostics( ...
%       digitalPricer, xVals, xMin, xMax, numPoints, ...
%       headerText, plotTitleText, usePercentFormat, printDigitalPrices)
%
% INPUTS:
%   digitalPricer      : function handle
%                       Function that evaluates digital prices D(x).
%
%   xVals              : numeric vector
%                       Target log-moneyness values, x = log(F0 / K).
%
%   xMin, xMax         : numeric scalars
%                       Bounds of the diagnostic grid.
%
%   numPoints          : integer
%                       Number of grid points in the diagnostic grid.
%
%   headerText         : char/string
%                       Header printed before diagnostics.
%
%   plotTitleText      : char/string
%                       Title of the diagnostic plot.
%
%   usePercentFormat   : logical, optional
%                       If true, xVals are printed as percentages.
%                       Default is false.
%
%   printDigitalPrices : logical, optional
%                       If true, prints DFourier at each xVal.
%                       Use true for Exercise 3 and false otherwise.
%                       Default is false.
%
% OUTPUT:
%   diagResults        : struct with fields:
%                       digitalAtX   : digital prices at xVals
%                       xDiag        : diagnostic grid
%                       digitalDiag  : digital prices on diagnostic grid

    if nargin < 8 || isempty(usePercentFormat)
        usePercentFormat = false;
    end

    if nargin < 9 || isempty(printDigitalPrices)
        printDigitalPrices = false;
    end

    diagResults = struct();

    xVals = xVals(:).';

    diagResults.digitalAtX = digitalPricer(xVals);
    diagResults.xDiag = linspace(xMin, xMax, numPoints);
    diagResults.digitalDiag = digitalPricer(diagResults.xDiag);

    disp(' ')
    disp(headerText)

    if printDigitalPrices
        for idx = 1:length(xVals)
            if usePercentFormat
                fprintf('x = %+7.2f%%   DFourier = %.8f\n', ...
                    100 * xVals(idx), diagResults.digitalAtX(idx));
            else
                fprintf('x = %+8.5f   DFourier = %.8f\n', ...
                    xVals(idx), diagResults.digitalAtX(idx));
            end
        end
    end

    disp(' ')
    disp('--- Digital diagnostics on large grid ---')
    fprintf('min D = %.8f\n', min(diagResults.digitalDiag));
    fprintf('max D = %.8f\n', max(diagResults.digitalDiag));

    figure;
    plot(diagResults.xDiag, diagResults.digitalDiag, 'LineWidth', 1.2);
    grid on;
    title(plotTitleText);
    xlabel('x = log(F0 / K)');
    ylabel('D(x)');

end