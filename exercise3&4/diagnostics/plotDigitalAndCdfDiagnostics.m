function plotDigitalAndCdfDiagnostics(xDiag, digitalGrid, yGrid, cdfVals, xSim, plotPrefix)
% PLOTDIGITALANDCDFDIAGNOSTICS Plot digital and CDF reconstruction diagnostics.
%
%   plotDigitalAndCdfDiagnostics( ...
%       xDiag, digitalGrid, yGrid, cdfVals, xSim, plotPrefix)
%
%   Creates a single figure with three panels:
%       1) digital prices used for CDF reconstruction;
%       2) reconstructed target CDF;
%       3) empirical CDF from simulations compared with the target CDF.
%
% INPUTS:
%   xDiag       : numeric vector
%                 Grid of log-moneyness values used to evaluate digital prices,
%                 x = log(F0 / K).
%
%   digitalGrid : numeric vector
%                 Digital prices evaluated on xDiag.
%
%   yGrid       : numeric vector
%                 Grid for the reconstructed log-return variable
%                 X = log(Ft / F0).
%
%   cdfVals     : numeric vector
%                 Reconstructed CDF values evaluated on yGrid.
%
%   xSim        : numeric vector
%                 Simulated samples generated from the reconstructed CDF.
%
%   plotPrefix  : char/string
%                 Prefix used in the plot title.
%
% OUTPUT:
%   none. The function creates a diagnostic figure.
%
% NOTES:
%   - The third panel checks whether the simulated samples are consistent
%     with the reconstructed target CDF.
%   - This function is intended for visual diagnostics only.

    xDiag = xDiag(:);
    digitalGrid = digitalGrid(:);
    yGrid = yGrid(:);
    cdfVals = cdfVals(:);
    xSim = xSim(:);

    figure;

    % Digital prices
    subplot(1, 3, 1);
    plot(xDiag, digitalGrid, 'LineWidth', 1.2);
    grid on;
    title('Digital prices');
    xlabel('x = log(F0 / K)');
    ylabel('D(x)');

    % Reconstructed CDF
    subplot(1, 3, 2);
    plot(yGrid, cdfVals, 'LineWidth', 1.2);
    grid on;
    title('Reconstructed CDF');
    xlabel('X = log(F_t / F0)');
    ylabel('F_X(X)');

    % Empirical vs target CDF
    subplot(1, 3, 3);
    cdfplot(xSim);
    hold on;
    plot(yGrid, cdfVals, 'LineWidth', 1.5);
    grid on;
    legend('Empirical CDF', 'Target CDF', 'Location', 'best');
    title('CDF check');
    xlabel('X = log(F_t / F0)');
    ylabel('CDF');

    sgtitle([char(plotPrefix) ' - Digital/CDF diagnostics']);

end