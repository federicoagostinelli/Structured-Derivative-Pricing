function printPricingComparisonReport(xVals, F0, cQuad, cFFT, cMCdirect, cMCfromDigital, cRes, dFFT, cdfGrid, idxPrint)
% PRINTPRICINGCOMPARISONREPORT Print a pricing comparison report.
%
%   printPricingComparisonReport( ...
%       xVals, F0, cQuad, cFFT, cMCdirect, cMCfromDigital, ...
%       cRes, dFFT, cdfGrid)
%
%   printPricingComparisonReport(..., idxPrint)
%
%   Prints a comparison report for prices already computed in the main
%   script. The function supports several pricing methods and automatically
%   skips unavailable methods. A method is considered unavailable if its
%   vector is empty, all zeros, or all NaN values.
%
% INPUTS:
%   xVals          : numeric vector
%                   Log-moneyness values, with x = log(F0 / K).
%
%   F0             : numeric scalar
%                   Forward price at initial time.
%
%   cQuad          : numeric vector
%                   Call prices computed by Fourier quadrature.
%
%   cFFT           : numeric vector
%                   Call prices computed by FFT.
%
%   cMCdirect      : numeric vector
%                   Call prices computed by direct Monte Carlo.
%                   Use NaN(size(xVals)) if unavailable.
%
%   cMCfromDigital : numeric vector
%                   Call prices computed by Monte Carlo from the
%                   reconstructed CDF/digital prices.
%                   Use NaN(size(xVals)) if unavailable.
%
%   cRes           : numeric vector
%                   Call prices computed by the residue theorem.
%                   Use NaN(size(xVals)) if unavailable.
%
%   dFFT           : numeric vector
%                   Digital prices computed by FFT at xVals.
%                   Use NaN(size(xVals)) if unavailable.
%
%   cdfGrid        : numeric vector
%                   Reconstructed CDF values used for diagnostics.
%                   Pass [] if unavailable.
%
%   idxPrint       : numeric vector, optional
%                   Indices of xVals to print in the pointwise tables.
%                   If omitted, all points are printed.
%
% OUTPUT:
%   none. The function prints diagnostics to the command window.
%
% NOTES:
%   - The quadrature prices are treated as benchmark for the error tables.
%   - Aggregate error summaries are still computed on the full vectors, not
%     only on idxPrint.
%   - Monotonicity checks are performed on the full vectors.

    xVals = xVals(:);
    nX = numel(xVals);

    if nargin < 10 || isempty(idxPrint)
        idxPrint = 1:nX;
    end

    cQuad = normalizeInputVector(cQuad, nX);
    cFFT = normalizeInputVector(cFFT, nX);
    cMCdirect = normalizeInputVector(cMCdirect, nX);
    cMCfromDigital = normalizeInputVector(cMCfromDigital, nX);
    cRes = normalizeInputVector(cRes, nX);
    dFFT = normalizeInputVector(dFFT, nX);

    Kvals = F0 .* exp(-xVals);

    hasQuad = hasData(cQuad);
    hasFFT = hasData(cFFT);
    hasMCd = hasData(cMCdirect);
    hasMCg = hasData(cMCfromDigital);
    hasRes = hasData(cRes);
    hasDfft = hasData(dFFT);

    fprintf('\n');
    disp('========================================')
    disp('PRICING COMPARISON REPORT')
    disp('========================================')

    if ~isempty(cdfGrid)
        cdfGrid = cdfGrid(:);
        fprintf('CDF min            = %.8f\n', min(cdfGrid));
        fprintf('CDF max            = %.8f\n', max(cdfGrid));
        fprintf('CDF nondecreasing  = %d\n', all(diff(cdfGrid) >= -1e-10));
        fprintf('\n');
    end

    %% Pointwise comparison
    disp('--- Pointwise comparison ---')

    headerStr = '%12s %12s';
    argsHead = {'x', 'K'};
    formatStr = '%+12.5f %12.6f';

    if hasDfft
        headerStr = [headerStr ' %14s'];
        argsHead{end+1} = 'DigitalFFT';
        formatStr = [formatStr ' %14.8f'];
    end

    if hasQuad
        headerStr = [headerStr ' %14s'];
        argsHead{end+1} = 'Quadrature';
        formatStr = [formatStr ' %14.8f'];
    end

    if hasFFT
        headerStr = [headerStr ' %14s'];
        argsHead{end+1} = 'FFT';
        formatStr = [formatStr ' %14.8f'];
    end

    if hasMCd
        headerStr = [headerStr ' %16s'];
        argsHead{end+1} = 'DirectMC';
        formatStr = [formatStr ' %16.8f'];
    end

    if hasMCg
        headerStr = [headerStr ' %16s'];
        argsHead{end+1} = 'MCfromDigital';
        formatStr = [formatStr ' %16.8f'];
    end

    if hasRes
        headerStr = [headerStr ' %16s'];
        argsHead{end+1} = 'Residuals';
        formatStr = [formatStr ' %16.8f'];
    end

    headerStr = [headerStr '\n'];
    formatStr = [formatStr '\n'];

    fprintf(headerStr, argsHead{:});

    for jj = 1:numel(idxPrint)
        j = idxPrint(jj);

        argsData = {xVals(j), Kvals(j)};

        if hasDfft
            argsData{end+1} = dFFT(j);
        end

        if hasQuad
            argsData{end+1} = cQuad(j);
        end

        if hasFFT
            argsData{end+1} = cFFT(j);
        end

        if hasMCd
            argsData{end+1} = cMCdirect(j);
        end

        if hasMCg
            argsData{end+1} = cMCfromDigital(j);
        end

        if hasRes
            argsData{end+1} = cRes(j);
        end

        fprintf(formatStr, argsData{:});
    end

    fprintf('\n');

    %% Absolute errors
    disp('--- Absolute errors ---')

    headerStrErr = '%12s';
    argsHeadErr = {'x'};
    formatStrErr = '%+12.5f';

    if hasQuad && hasFFT
        errQFFT = abs(cQuad - cFFT);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|Q-FFT|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    if hasFFT && hasMCd
        errFFTMCd = abs(cFFT - cMCdirect);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|FFT-MCd|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    if hasFFT && hasMCg
        errFFTMCg = abs(cFFT - cMCfromDigital);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|FFT-MCdig|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    if hasQuad && hasMCg
        errQMCg = abs(cQuad - cMCfromDigital);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|Q-MCdig|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    if hasMCd && hasMCg
        errMCs = abs(cMCdirect - cMCfromDigital);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|MCd-MCdig|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    if hasQuad && hasRes
        errQRes = abs(cQuad - cRes);
        headerStrErr = [headerStrErr ' %14s'];
        argsHeadErr{end+1} = '|Q-Res|';
        formatStrErr = [formatStrErr ' %14.8e'];
    end

    headerStrErr = [headerStrErr '\n'];
    formatStrErr = [formatStrErr '\n'];

    fprintf(headerStrErr, argsHeadErr{:});

    for jj = 1:numel(idxPrint)
        j = idxPrint(jj);

        argsDataErr = {xVals(j)};

        if hasQuad && hasFFT
            argsDataErr{end+1} = errQFFT(j);
        end

        if hasFFT && hasMCd
            argsDataErr{end+1} = errFFTMCd(j);
        end

        if hasFFT && hasMCg
            argsDataErr{end+1} = errFFTMCg(j);
        end

        if hasQuad && hasMCg
            argsDataErr{end+1} = errQMCg(j);
        end

        if hasMCd && hasMCg
            argsDataErr{end+1} = errMCs(j);
        end

        if hasQuad && hasRes
            argsDataErr{end+1} = errQRes(j);
        end

        fprintf(formatStrErr, argsDataErr{:});
    end

    fprintf('\n');

    %% Aggregate summary
    disp('--- Aggregate summary ---')

    if hasQuad && hasFFT
        printAggregateError('Quadrature - FFT', errQFFT);
    end

    if hasFFT && hasMCd
        printAggregateError('FFT - Direct MC', errFFTMCd);
    end

    if hasFFT && hasMCg
        printAggregateError('FFT - MC from digital', errFFTMCg);
    end

    if hasQuad && hasMCg
        printAggregateError('Quadrature - MC from dig', errQMCg);
    end

    if hasQuad && hasRes
        printAggregateError('Quadrature - Residuals', errQRes);
    end

    if hasMCd && hasMCg
        printAggregateError('Direct MC - MC from dig', errMCs);
    end

    fprintf('\n');

    %% Monotonicity checks
    disp('--- Monotonicity checks ---')

    if hasDfft
        fprintf('Digitals increasing in x (FFT)          = %d\n', all(diff(dFFT) >= -1e-10));
    end

    if hasQuad
        fprintf('Calls increasing in x (Quadrature)      = %d\n', all(diff(cQuad) >= -1e-10));
    end

    if hasFFT
        fprintf('Calls increasing in x (FFT)             = %d\n', all(diff(cFFT) >= -1e-10));
    end

    if hasMCd
        fprintf('Calls increasing in x (Direct MC)       = %d\n', all(diff(cMCdirect) >= -1e-10));
    end

    if hasMCg
        fprintf('Calls increasing in x (MC from digital) = %d\n', all(diff(cMCfromDigital) >= -1e-10));
    end

    if hasRes
        fprintf('Calls increasing in x (Residuals)       = %d\n', all(diff(cRes) >= -1e-10));
    end

    fprintf('\n');

    disp('========================================')
    disp('END OF REPORT')
    disp('========================================')
    fprintf('\n');

end

function v = normalizeInputVector(v, nX)
% NORMALIZEINPUTVECTOR Convert input to a column vector with length nX.

    if isempty(v)
        v = NaN(nX, 1);
        return
    end

    v = v(:);

    if numel(v) ~= nX
        error('All input vectors must have the same length as xVals.');
    end

end

function tf = hasData(v)
% HASDATA Return true if vector contains usable numerical data.

    tf = any(isfinite(v)) && ~all(v == 0 | isnan(v));

end

function printAggregateError(labelText, errVec)
% PRINTAGGREGATEERROR Print max and mean absolute errors.

    errVec = errVec(:);
    errVec = errVec(isfinite(errVec));

    if isempty(errVec)
        return
    end

    fprintf('max |%-29s| = %.8e\n', labelText, max(errVec));
    fprintf('avg |%-29s| = %.8e\n', labelText, mean(errVec));

end