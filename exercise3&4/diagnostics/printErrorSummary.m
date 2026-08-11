function printErrorSummary(titleText, err)
% PRINTERRORSUMMARY Print compact pricing error diagnostics.
%
%   printErrorSummary(titleText, err)
%
%   Prints a short summary of pricing errors, using quadrature prices as the
%   benchmark. The FFT error metrics are always printed. Monte Carlo error
%   metrics are printed only when they are available, i.e. when the
%   corresponding fields in err are finite.
%
% INPUTS:
%   titleText : char/string
%               Title printed above the error summary.
%
%   err       : struct
%               Error metrics returned by computeErrors. Expected fields:
%                   maxAbsFftQuad
%                   meanAbsFftQuad
%                   maxRelFftQuad
%                   meanRelFftQuad
%                   maxAbsMcQuad
%                   maxAbsMcDigitalQuad
%
% OUTPUT:
%   none. The function prints diagnostics to the command window.

    disp(' ')
    fprintf('--- %s ---\n', titleText)

    fprintf('max  |FFT - Quadrature|       = %.6e\n', err.maxAbsFftQuad);
    fprintf('mean |FFT - Quadrature|       = %.6e\n', err.meanAbsFftQuad);
    fprintf('max relative FFT error       = %.6e\n', err.maxRelFftQuad);
    fprintf('mean relative FFT error      = %.6e\n', err.meanRelFftQuad);

    if isfield(err, 'maxAbsMcQuad') && isfinite(err.maxAbsMcQuad)
        fprintf('max  |Direct MC - Quadrature| = %.6e\n', err.maxAbsMcQuad);
    end

    if isfield(err, 'meanAbsMcQuad') && isfinite(err.meanAbsMcQuad)
        fprintf('mean |Direct MC - Quadrature| = %.6e\n', err.meanAbsMcQuad);
    end

    if isfield(err, 'maxAbsMcDigitalQuad') && isfinite(err.maxAbsMcDigitalQuad)
        fprintf('max  |MC digital - Quadrature| = %.6e\n', err.maxAbsMcDigitalQuad);
    end

    if isfield(err, 'meanAbsMcDigitalQuad') && isfinite(err.meanAbsMcDigitalQuad)
        fprintf('mean |MC digital - Quadrature| = %.6e\n', err.meanAbsMcDigitalQuad);
    end

end