function comparison = compareFftParametersExercise3(xVals, charFunc, dfMat, forward, priceBenchmark, fftBase)
% COMPAREFFTPARAMETERSEXERCISE3 Compare FFT call prices across parameter choices.
%
%   comparison = compareFftParametersExercise3( ...
%       xVals, charFunc, dfMat, forward, priceBenchmark, fftBase)
%
%   Computes European call prices via FFT for several choices of the FFT
%   parameters and compares them against benchmark prices, typically obtained
%   by adaptive quadrature. The function reports absolute and relative errors,
%   selects the best configuration according to the RMSE absolute error, and
%   produces diagnostic plots.
%
% INPUTS:
%   xVals          : numeric vector
%                   Log-moneyness values, with x = log(F0 / K).
%
%   charFunc       : function handle
%                   Characteristic function of the log-return.
%
%   dfMat          : numeric scalar
%                   Discount factor B(t0,t) for the option maturity.
%
%   forward        : numeric scalar
%                   Forward price F0 at time t0.
%
%   priceBenchmark : numeric vector
%                   Benchmark call prices evaluated at xVals.
%
%   fftBase        : struct
%                   Baseline FFT parameter structure with fields:
%                       fftBase.M     : exponent such that N = 2^M
%                       fftBase.xLeft : first point of the Fourier grid
%                       fftBase.zLeft : first point of the output x-grid
%
% OUTPUT:
%   comparison     : struct containing FFT prices, errors, valid tests,
%                    best configuration, and best prices.

    disp(' ')
    disp('--- FFT parameter comparison ---')
    disp('Benchmark: quadrature prices.')
    disp('The goal is to study how FFT prices change when M and zLeft are varied.')

    %% Force row vectors
    xVals = xVals(:).';
    priceBenchmark = priceBenchmark(:).';

    nX = length(xVals);

    %% ------------------------------------------------------------
    % Parameter configurations
    % ------------------------------------------------------------
    paramTable = [
        12, fftBase.xLeft, fftBase.zLeft;
        13, fftBase.xLeft, fftBase.zLeft;
        14, fftBase.xLeft, fftBase.zLeft;
        15, fftBase.xLeft, fftBase.zLeft;
        16, fftBase.xLeft, fftBase.zLeft;
        17, fftBase.xLeft, fftBase.zLeft;

        fftBase.M, fftBase.xLeft, -25;
        fftBase.M, fftBase.xLeft, -50;
        fftBase.M, fftBase.xLeft, -75;
        fftBase.M, fftBase.xLeft, -100;
        fftBase.M, fftBase.xLeft, -125;
        fftBase.M, fftBase.xLeft, -150
    ];

    nTests = size(paramTable, 1);

    prices = NaN(nTests, nX);

    %% ------------------------------------------------------------
    % FFT pricing
    % ------------------------------------------------------------
    for j = 1:nTests

        Mtest = paramTable(j, 1);
        xLeftTest = paramTable(j, 2);
        zLeftTest = paramTable(j, 3);

        try
            tmpPrices = runPricingFourier( ...
                charFunc, ...
                xVals, ...
                dfMat, ...
                forward, ...
                Mtest, ...
                xLeftTest, ...
                zLeftTest);

            tmpPrices = tmpPrices(:).';

            if numel(tmpPrices) == nX && all(isfinite(tmpPrices))
                prices(j, :) = tmpPrices;
            end

        catch
            prices(j, :) = NaN(1, nX);
        end
    end

    %% ------------------------------------------------------------
    % Error metrics
    % ------------------------------------------------------------
    absErrors = abs(prices - priceBenchmark);
    relErrors = absErrors ./ max(abs(priceBenchmark), 1e-12);

    validTest = all(isfinite(prices), 2);

    maxAbsError = NaN(nTests, 1);
    rmseAbsError = NaN(nTests, 1);
    maxRelError = NaN(nTests, 1);
    rmseRelError = NaN(nTests, 1);

    maxAbsError(validTest) = max(absErrors(validTest, :), [], 2);
    rmseAbsError(validTest) = sqrt(mean(absErrors(validTest, :).^2, 2));

    maxRelError(validTest) = max(relErrors(validTest, :), [], 2);
    rmseRelError(validTest) = sqrt(mean(relErrors(validTest, :).^2, 2));

    %% ------------------------------------------------------------
    % Summary table
    % ------------------------------------------------------------
    disp(' ')
    disp('--- FFT parameter summary ---')

    fprintf('%5s %8s %10s %12s %12s %14s %14s %14s %14s\n', ...
        'Test', 'M', 'N=2^M', 'xLeft', 'zLeft', ...
        'MaxAbsErr', 'RMSEAbs', 'MaxRelErr', 'RMSERel');

    for j = 1:nTests

        fprintf('%5d %8d %10d %12.4f %12.4f', ...
            j, ...
            paramTable(j, 1), ...
            2^paramTable(j, 1), ...
            paramTable(j, 2), ...
            paramTable(j, 3));

        printMetric(maxAbsError(j));
        printMetric(rmseAbsError(j));
        printMetric(maxRelError(j));
        printMetric(rmseRelError(j));

        fprintf('\n');
    end

    %% ------------------------------------------------------------
    % Best configuration
    % ------------------------------------------------------------
    if any(validTest)

        tmpRmse = rmseAbsError;
        tmpRmse(~validTest) = Inf;
        [~, bestIdx] = min(tmpRmse);

        bestM = paramTable(bestIdx, 1);
        bestXLeft = paramTable(bestIdx, 2);
        bestZLeft = paramTable(bestIdx, 3);

        disp(' ')
        disp('--- Best FFT configuration among the tested ones ---')
        fprintf('Best test index : %d\n', bestIdx);
        fprintf('Best M          : %d\n', bestM);
        fprintf('Best N = 2^M    : %d\n', 2^bestM);
        fprintf('Best xLeft      : %.6f\n', bestXLeft);
        fprintf('Best zLeft      : %.6f\n', bestZLeft);
        fprintf('Max abs error   : %.4e\n', maxAbsError(bestIdx));
        fprintf('RMSE abs error  : %.4e\n', rmseAbsError(bestIdx));
        fprintf('Max rel error   : %.4e\n', maxRelError(bestIdx));
        fprintf('RMSE rel error  : %.4e\n', rmseRelError(bestIdx));

        disp(' ')
        disp('--- Prices and absolute errors for best FFT configuration ---')
        fprintf('%12s %14s %14s %14s %14s\n', ...
            'x', 'Quadrature', 'FFT best', 'Abs error', 'Rel error');

        for k = 1:nX
            fprintf('%12.6f %14.8f %14.8f %14.4e %14.4e\n', ...
                xVals(k), ...
                priceBenchmark(k), ...
                prices(bestIdx, k), ...
                absErrors(bestIdx, k), ...
                relErrors(bestIdx, k));
        end

    else
        bestIdx = NaN;
        bestM = NaN;
        bestXLeft = NaN;
        bestZLeft = NaN;

        disp(' ')
        disp('No valid FFT configuration was found.')
    end

    %% ------------------------------------------------------------
    % Diagnostic plot: FFT accuracy versus M and zLeft
    % ------------------------------------------------------------
    figure;

    % Panel 1: error as a function of M
    idxM = 1:6;
    validM = validTest(idxM);

    subplot(1, 2, 1)

    if any(validM)

        MPlot = paramTable(idxM(validM), 1);
        rmseM = rmseAbsError(idxM(validM));
        maxM  = maxAbsError(idxM(validM));

        semilogy(MPlot, rmseM, '-o', 'LineWidth', 1.5);
        hold on
        semilogy(MPlot, maxM, '-s', 'LineWidth', 1.5);

        [bestRmseM, bestLocalIdxM] = min(rmseM);
        bestMPlot = MPlot(bestLocalIdxM);

        plot(bestMPlot, bestRmseM, 'kp', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', 'k');

        xlabel('M, with N = 2^M')
        ylabel('Absolute error vs quadrature')
        title('Sensitivity to M')
        legend( ...
            'RMSE abs. error', ...
            'Max abs. error', ...
            'Best M by RMSE', ...
            'Location', 'best')

    else
        text(0.5, 0.5, 'No valid M tests', ...
            'HorizontalAlignment', 'center')
        axis off
    end

    grid on

    % Panel 2: error as a function of zLeft
    idxZ = 7:12;
    validZ = validTest(idxZ);

    subplot(1, 2, 2)

    if any(validZ)

        zPlot = paramTable(idxZ(validZ), 3);
        rmseZ = rmseAbsError(idxZ(validZ));
        maxZ  = maxAbsError(idxZ(validZ));

        [zPlot, sortIdx] = sort(zPlot);
        rmseZ = rmseZ(sortIdx);
        maxZ  = maxZ(sortIdx);

        plot(zPlot, rmseZ, '-o', 'LineWidth', 1.5);
        hold on
        plot(zPlot, maxZ, '-s', 'LineWidth', 1.5);

        [bestRmseZ, bestLocalIdxZ] = min(rmseZ);
        bestZ = zPlot(bestLocalIdxZ);

        plot(bestZ, bestRmseZ, 'kp', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', 'k');

        xlabel('zLeft')
        ylabel('Absolute error vs quadrature')
        title('Sensitivity to zLeft')
        legend( ...
            'RMSE abs. error', ...
            'Max abs. error', ...
            'Best zLeft by RMSE', ...
            'Location', 'best')

    else
        text(0.5, 0.5, 'No valid zLeft tests', ...
            'HorizontalAlignment', 'center')
        axis off
    end

    grid on

    sgtitle('Exercise 3 - FFT parameter sensitivity')

    %% ------------------------------------------------------------
    % Output struct
    % ------------------------------------------------------------
    comparison.paramTable = paramTable;
    comparison.validTest = validTest;

    comparison.prices = prices;
    comparison.absErrors = absErrors;
    comparison.relErrors = relErrors;

    comparison.maxAbsError = maxAbsError;
    comparison.rmseAbsError = rmseAbsError;
    comparison.maxRelError = maxRelError;
    comparison.rmseRelError = rmseRelError;

    comparison.bestIdx = bestIdx;
    comparison.bestParams.M = bestM;

    if isnan(bestM)
        comparison.bestParams.N = NaN;
    else
        comparison.bestParams.N = 2^bestM;
    end

    comparison.bestParams.xLeft = bestXLeft;
    comparison.bestParams.zLeft = bestZLeft;

    if any(validTest)
        comparison.bestPrices = prices(bestIdx, :);
        comparison.bestAbsErrors = absErrors(bestIdx, :);
        comparison.bestRelErrors = relErrors(bestIdx, :);
    else
        comparison.bestPrices = NaN(1, nX);
        comparison.bestAbsErrors = NaN(1, nX);
        comparison.bestRelErrors = NaN(1, nX);
    end

end


function printMetric(x)
% PRINTMETRIC Prints a numeric metric or '--' if invalid.

    if isfinite(x)
        fprintf(' %14.4e', x);
    else
        fprintf(' %14s', '--');
    end
end