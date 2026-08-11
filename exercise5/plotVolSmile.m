function plotVolSmile(logMoneyness, marketVols, modelVols, timeToMaturity)
% PLOTVOLSMILE Plot market and calibrated NTS implied volatility smiles.
%
%   plotVolSmile(logMoneyness, marketVols, modelVols, timeToMaturity)
%
%   Creates a plot comparing market implied volatilities and model implied
%   volatilities from the calibrated NTS model. The x-axis is log-moneyness,
%   x = log(F0 / K), and the y-axis is implied volatility in percentage points.
%
% INPUTS:
%   logMoneyness  : numeric vector
%                   Log-moneyness values, x = log(F0 / K).
%
%   marketVols    : numeric vector
%                   Market implied volatilities in decimal form.
%
%   modelVols     : numeric vector
%                   Model implied volatilities in decimal form.
%
%   timeToMaturity: numeric scalar
%                   Time to maturity in years.
%
% OUTPUT:
%   none. The function creates a figure.

    logMoneyness = logMoneyness(:);
    marketVols = marketVols(:);
    modelVols = modelVols(:);

    [logMoneynessSorted, sortIdx] = sort(logMoneyness);
    marketVolsSorted = marketVols(sortIdx);
    modelVolsSorted = modelVols(sortIdx);

    figure('Color', 'white', 'Position', [100, 100, 850, 500]);

    ax = gca;
    hold(ax, 'on');

    marketHandle = plot(ax, logMoneynessSorted, marketVolsSorted * 100, ...
        '-o', ...
        'Color', [0.2, 0.47, 0.72], ...
        'LineWidth', 2, ...
        'MarkerFaceColor', [0.2, 0.47, 0.72], ...
        'MarkerSize', 7, ...
        'DisplayName', 'Market IV');

    modelHandle = plot(ax, logMoneynessSorted, modelVolsSorted * 100, ...
        '--s', ...
        'Color', [0.85, 0.33, 0.10], ...
        'LineWidth', 2, ...
        'MarkerFaceColor', [0.85, 0.33, 0.10], ...
        'MarkerSize', 7, ...
        'DisplayName', 'Model IV (NTS)');

    xline(0, ':', ...
        'Color', [0.5, 0.5, 0.5], ...
        'LineWidth', 1.2, ...
        'Label', 'ATM', ...
        'LabelVerticalAlignment', 'bottom', ...
        'FontSize', 9);

    xlabel(ax, 'Log-Moneyness  \it{log(F_0/K)}', ...
        'FontSize', 12, ...
        'FontWeight', 'normal');

    ylabel(ax, 'Implied Volatility (%)', ...
        'FontSize', 12, ...
        'FontWeight', 'normal');

    title(ax, sprintf('Exercise 5 - NTS Calibration, T = %.4f', timeToMaturity), ...
        'FontSize', 14, ...
        'FontWeight', 'bold');

    ax.FontSize = 11;
    ax.Box = 'on';
    ax.GridAlpha = 0.25;
    ax.GridLineStyle = ':';
    ax.XMinorGrid = 'off';
    ax.YMinorGrid = 'off';
    ax.TickDir = 'out';

    grid(ax, 'on');

    legend([marketHandle, modelHandle], ...
        'Location', 'best', ...
        'FontSize', 11, ...
        'Box', 'on');

    allVols = [marketVolsSorted(:); modelVolsSorted(:)];

    xRange = range(logMoneynessSorted);
    yRange = range(allVols * 100);

    if xRange == 0
        xRange = 1;
    end

    if yRange == 0
        yRange = 1;
    end

    xPad = 0.05 * xRange;
    yPad = 0.05 * yRange;

    xlim([min(logMoneynessSorted) - xPad, max(logMoneynessSorted) + xPad]);
    ylim([min(allVols) * 100 - yPad, max(allVols) * 100 + yPad]);

    hold(ax, 'off');

end