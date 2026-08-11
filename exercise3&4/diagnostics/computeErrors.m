function err = computeErrors(priceQuad, priceFft, priceMcDirect, priceMcFromDigital)
% COMPUTEERRORS Compute compact pricing error metrics.
%
%   err = computeErrors(priceQuad, priceFft, priceMcDirect, priceMcFromDigital)
%
%   Computes absolute and relative pricing errors using the quadrature prices
%   as benchmark. The function is designed to work both when Monte Carlo
%   prices are available and when they are not. If a Monte Carlo input is a
%   vector of NaN values, the corresponding error statistics are returned as NaN.
%
% INPUTS:
%   priceQuad         : numeric vector
%                       Benchmark prices computed by Fourier quadrature.
%
%   priceFft          : numeric vector
%                       Prices computed by FFT.
%
%   priceMcDirect     : numeric vector
%                       Prices computed by direct Monte Carlo.
%                       Use NaN(size(priceQuad)) if direct MC is not available.
%
%   priceMcFromDigital: numeric vector
%                       Prices computed by Monte Carlo simulation from the
%                       reconstructed CDF/digital prices.
%                       Use NaN(size(priceQuad)) if this method is not available.
%
% OUTPUT:
%   err               : struct containing the following fields:
%
%                       absFftQuad
%                           Absolute errors |FFT - Quadrature|.
%
%                       relFftQuad
%                           Relative errors |FFT - Quadrature| / |Quadrature|.
%
%                       maxAbsFftQuad
%                           Maximum absolute FFT error.
%
%                       meanAbsFftQuad
%                           Mean absolute FFT error.
%
%                       maxRelFftQuad
%                           Maximum relative FFT error.
%
%                       meanRelFftQuad
%                           Mean relative FFT error.
%
%                       absMcQuad
%                           Absolute errors |Direct MC - Quadrature|.
%                           NaN if direct MC is not available.
%
%                       maxAbsMcQuad
%                           Maximum absolute direct MC error.
%                           NaN if direct MC is not available.
%
%                       meanAbsMcQuad
%                           Mean absolute direct MC error.
%                           NaN if direct MC is not available.
%
%                       absMcDigitalQuad
%                           Absolute errors |MC from digital - Quadrature|.
%                           NaN if MC from digital is not available.
%
%                       maxAbsMcDigitalQuad
%                           Maximum absolute MC-from-digital error.
%                           NaN if MC from digital is not available.
%
%                       meanAbsMcDigitalQuad
%                           Mean absolute MC-from-digital error.
%                           NaN if MC from digital is not available.
%
% NOTES:
%   - The denominator for relative errors is floored at 1e-14 to avoid
%     division by zero.
%   - Non-finite values are excluded from the max/mean summaries.

    priceQuad = priceQuad(:);
    priceFft = priceFft(:);
    priceMcDirect = priceMcDirect(:);
    priceMcFromDigital = priceMcFromDigital(:);

    err.absFftQuad = abs(priceFft - priceQuad);
    err.relFftQuad = err.absFftQuad ./ max(abs(priceQuad), 1e-14);

    validAbs = isfinite(err.absFftQuad);
    validRel = isfinite(err.relFftQuad);

    err.maxAbsFftQuad = max(err.absFftQuad(validAbs));
    err.meanAbsFftQuad = mean(err.absFftQuad(validAbs));

    err.maxRelFftQuad = max(err.relFftQuad(validRel));
    err.meanRelFftQuad = mean(err.relFftQuad(validRel));

    if all(isnan(priceMcDirect))
        err.absMcQuad = NaN(size(priceQuad));
        err.maxAbsMcQuad = NaN;
        err.meanAbsMcQuad = NaN;
    else
        err.absMcQuad = abs(priceMcDirect - priceQuad);
        validMc = isfinite(err.absMcQuad);
        err.maxAbsMcQuad = max(err.absMcQuad(validMc));
        err.meanAbsMcQuad = mean(err.absMcQuad(validMc));
    end

    if all(isnan(priceMcFromDigital))
        err.absMcDigitalQuad = NaN(size(priceQuad));
        err.maxAbsMcDigitalQuad = NaN;
        err.meanAbsMcDigitalQuad = NaN;
    else
        err.absMcDigitalQuad = abs(priceMcFromDigital - priceQuad);
        validMcDigital = isfinite(err.absMcDigitalQuad);
        err.maxAbsMcDigitalQuad = max(err.absMcDigitalQuad(validMcDigital));
        err.meanAbsMcDigitalQuad = mean(err.absMcDigitalQuad(validMcDigital));
    end

end