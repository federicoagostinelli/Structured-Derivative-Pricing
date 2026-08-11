function resultsTable = printCalibrationReport(alphaNts, sigmaOpt, kappaOpt, etaOpt, objValue, ...
                                                        strikes, logMoneyness, marketVols, modelVols, ...
                                                        callMarket, callModel, idxPrint)
% PRINTCALIBRATIONREPORT Print NTS calibration results for Exercise 5.
%
%   resultsTable = printCalibrationReport( ...
%       alphaNts, sigmaOpt, kappaOpt, etaOpt, objValue, ...
%       strikes, logMoneyness, marketVols, modelVols, callMarket, callModel)
%
%   Prints the calibrated NTS parameters, the final objective value, and a
%   table comparing market and model quantities at each strike.
%
% INPUTS:
%   alphaNts     : NTS alpha parameter.
%   sigmaOpt     : calibrated sigma.
%   kappaOpt     : calibrated kappa.
%   etaOpt       : calibrated eta.
%   objValue     : final calibration objective value.
%   strikes      : option strikes.
%   logMoneyness : log-moneyness values, x = log(F0/K).
%   marketVols   : market implied volatilities.
%   modelVols    : model implied volatilities.
%   callMarket   : market call prices.
%   callModel    : model call prices.
%   idxPrint     : optional indices of rows to print.
% OUTPUT:
%   resultsTable : table
%                  Table containing strikes, log-moneyness, market/model
%                  implied volatilities, market/model call prices, and
%                  absolute pricing errors.

    strikes = strikes(:);
    logMoneyness = logMoneyness(:);
    marketVols = marketVols(:);
    modelVols = modelVols(:);
    callMarket = callMarket(:);
    callModel = callModel(:);
    if nargin < 12 || isempty(idxPrint)
        idxPrint = 1:numel(strikes);
    end
    absError = abs(callModel - callMarket);
    resultsTable = table( ...
        strikes, ...
        logMoneyness, ...
        marketVols, ...
        modelVols, ...
        callMarket, ...
        callModel, ...
        absError, ...
        'VariableNames', { ...
            'Strike', ...
            'LogMoneyness', ...
            'MarketIV', ...
            'ModelIV', ...
            'CallMarket', ...
            'CallModel', ...
            'AbsError'});
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('EXERCISE 5 - NTS CALIBRATION WITH FMINSEARCH\n');
    fprintf('========================================\n');
    fprintf('alpha    = %.8f\n', alphaNts);
    fprintf('sigma*   = %.8f\n', sigmaOpt);
    fprintf('kappa*   = %.8f\n', kappaOpt);
    fprintf('eta*     = %.8f\n', etaOpt);
    fprintf('objValue = %.12e\n', objValue);
    disp(resultsTable(idxPrint, :));
    fprintf('max |Model - Market|  = %.6e\n', max(absError));
    fprintf('mean |Model - Market| = %.6e\n', mean(absError));
    relAbsError = absError ./ callMarket;
    etaBoundValue = (1 - alphaNts) / (kappaOpt * sigmaOpt^2);
    fprintf('max relative price error  = %.6e\n', max(relAbsError));
    fprintf('mean relative price error = %.6e\n', mean(relAbsError));
    fprintf('eta admissibility bound   = %.6f\n', etaBoundValue);
    fprintf('eta / bound               = %.6f\n', etaOpt / etaBoundValue);
    fprintf('Full calibration table stored in resultsEx5.resultsTable.\n');

end