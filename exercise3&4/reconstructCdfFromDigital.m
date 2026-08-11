function cdfResults = reconstructCdfFromDigital(digitalPricer, forward, dfMat, xMin, xMax, numPoints, numSim, headerText)
% reconstructCdfFromDigital Reconstructs the CDF from digital prices and
% simulates log-returns from the reconstructed distribution.
%
% OUTPUT:
%   cdfResults.xSim
%   cdfResults.yGrid
%   cdfResults.cdfVals
%   cdfResults.digitalGrid
%   cdfResults.terminalPrices

if nargin < 8
    headerText = '--- CDF diagnostics ---';
end

cdfResults = struct();

[~, cdfResults.xSim, cdfResults.yGrid, cdfResults.cdfVals, cdfResults.digitalGrid] = ...
    callMCFromDigital(digitalPricer, 0, forward, dfMat, xMin, xMax, numPoints, numSim);

cdfResults.terminalPrices = forward * exp(cdfResults.xSim);

disp(' ')
disp(headerText)
fprintf('min CDF = %.8f\n', min(cdfResults.cdfVals));
fprintf('max CDF = %.8f\n', max(cdfResults.cdfVals));
fprintf('is nondecreasing = %d\n', all(diff(cdfResults.cdfVals) >= -1e-10));
fprintf('left tail  = %.8e\n', cdfResults.cdfVals(1));
fprintf('right tail = %.8e\n', cdfResults.cdfVals(end));

end