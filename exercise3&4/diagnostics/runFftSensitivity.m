function sensitivity = runFftSensitivity(titleText, charFunc, xVals, dfMat, forward, priceBenchmark, Mtest, Lvalues)
% RUNFFTSENSITIVITY Runs a compact FFT sensitivity test over L.
%
% INPUTS:
%   titleText      : string used in printed output
%   charFunc       : characteristic function
%   xVals          : log-moneyness vector
%   dfMat          : discount factor
%   forward        : forward price
%   priceBenchmark : benchmark prices
%   Mtest          : FFT exponent, N = 2^M
%   Lvalues        : vector of symmetric Fourier ranges [-L, L]
%
% OUTPUT:
%   sensitivity    : struct with tested L values, prices, and errors

    disp(' ')
    fprintf('--- %s ---\n', titleText)

    xVals = xVals(:).';
    priceBenchmark = priceBenchmark(:).';

    nL = numel(Lvalues);
    nX = numel(xVals);

    prices = NaN(nL, nX);
    maxAbsError = NaN(nL, 1);
    rmseAbsError = NaN(nL, 1);

    fprintf('%8s %8s %14s %14s\n', ...
        'L', 'M', 'MaxAbsErr', 'RMSEAbsErr');

    for j = 1:nL

        L = Lvalues(j);

        Ntest = 2^Mtest;
        xLeftTest = -L;
        xRightTest = L;
        dxTest = (xRightTest - xLeftTest) / Ntest;
        dzTest = 2 * pi / (Ntest * dxTest);
        zLeftTest = -Ntest / 2 * dzTest;

        prices(j, :) = runPricingFourier( ...
            charFunc, ...
            xVals, ...
            dfMat, ...
            forward, ...
            Mtest, ...
            xLeftTest, ...
            zLeftTest);

        absErr = abs(prices(j, :) - priceBenchmark);

        maxAbsError(j) = max(absErr);
        rmseAbsError(j) = sqrt(mean(absErr.^2));

        fprintf('%8.2f %8d %14.6e %14.6e\n', ...
            L, Mtest, maxAbsError(j), rmseAbsError(j));
    end

    [~, bestIdx] = min(rmseAbsError);

    fprintf('Selected L by RMSE = %.2f\n', Lvalues(bestIdx));

    sensitivity.Lvalues = Lvalues;
    sensitivity.M = Mtest;
    sensitivity.prices = prices;
    sensitivity.maxAbsError = maxAbsError;
    sensitivity.rmseAbsError = rmseAbsError;
    sensitivity.bestIdx = bestIdx;
    sensitivity.bestL = Lvalues(bestIdx);

end