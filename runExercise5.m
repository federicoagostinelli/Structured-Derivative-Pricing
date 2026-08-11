function resultsEx5 = runExercise5(marketData, forward, dfMat, timeToMaturity, ex5)
% RUNEXERCISE5 Execute NTS calibration and implied-volatility comparison.
%
% INPUTS:
%   marketData     : struct
%                    Market data used for calibration. Required fields:
%                       strikes    : option strikes
%                       marketVols : market implied volatilities
%                    Optional fields:
%                       spot
%                       dividendYield
%
%   forward        : numeric scalar
%                    Forward price at the option maturity.
%
%   dfMat          : numeric scalar
%                    Discount factor to maturity.
%
%   timeToMaturity : numeric scalar
%                    Time to maturity in years.
%
%   ex5            : struct
%                    Calibration settings. Required fields:
%                       alphaNts      : NTS alpha parameter
%                       penaltyValue  : penalty for invalid parameters
%                       params0       : initial guess [sigma; kappa; eta]
%                       optimOptions  : options for fminsearch
%
% OUTPUT:
%   resultsEx5     : struct
%                    Calibrated parameters, model prices, implied vols,
%                    market prices, and calibration diagnostics.

    %% Calibration settings
    alphaNts = ex5.alphaNts;
    penaltyValue = ex5.penaltyValue;
    params0 = ex5.params0(:);
    options = ex5.optimOptions;
    
    %% Market data
    strikes = marketData.strikes(:);
    marketVols = marketData.marketVols(:);

    if ~isfield(marketData, 'spot') || isempty(marketData.spot)
        error('runExercise5:MissingSpot', ...
            'marketData.spot is required for Exercise 5.');
    end

    spot = marketData.spot;

    if ~isscalar(spot) || ~isfinite(spot) || spot <= 0
        error('runExercise5:InvalidSpot', ...
            'marketData.spot must be a positive finite scalar.');
    end

    if isfield(marketData, 'dividendYield')
        dividendYield = marketData.dividendYield;
    else
        dividendYield = 0;
    end

    forward = double(forward);
    dfMat = double(dfMat);

    %% Log-moneyness
    logMoneyness = log(forward ./ strikes);

    %% Market call prices from Black formula
    sqrtT = sqrt(timeToMaturity);
    volSqrtT = marketVols .* sqrtT;

    d1 = (logMoneyness + 0.5 .* marketVols.^2 .* timeToMaturity) ./ volSqrtT;
    d2 = d1 - volSqrtT;

    callMarket = dfMat .* (forward .* normcdf(d1) - strikes .* normcdf(d2));

    %% NTS characteristic exponent
    charExpNts = @(u, sigma, kappa, eta) ...
        (timeToMaturity ./ kappa) .* ((1 - alphaNts) ./ alphaNts) .* ...
        (1 - (1 + (kappa ./ (2 * (1 - alphaNts))) .* sigma.^2 .* ...
        (u.^2 + 1i .* u .* (1 + 2 .* eta))).^alphaNts);

    %% Martingale correction
    martingaleCorrection = @(sigma, kappa, eta) ...
        -real(charExpNts(-1i, sigma, kappa, eta));

    %% NTS characteristic function
    charFuncNts = @(u, sigma, kappa, eta) ...
        exp(charExpNts(u, sigma, kappa, eta) + ...
        1i .* u .* martingaleCorrection(sigma, kappa, eta));

    %% Admissibility bound
    etaBound = @(sigma, kappa) (1 - alphaNts) ./ (kappa .* sigma.^2);

    %% Model prices as a function of p = [sigma, kappa, eta]
    modelCallPrices = @(p) runPricingFourier( ...
        @(u) charFuncNts(u, p(1), p(2), p(3)), ...
        logMoneyness, ...
        dfMat, ...
        forward);

    %% Objective function
    objective = @(p) objectiveNtsCalibration( ...
        p, ...
        modelCallPrices, ...
        callMarket, ...
        etaBound, ...
        penaltyValue);

    %% Calibration
    [paramsOpt, objValue] = fminsearch(objective, params0, options);

    sigmaOpt = paramsOpt(1);
    kappaOpt = paramsOpt(2);
    etaOpt = paramsOpt(3);

    %% Calibrated characteristic function
    charFuncNtsOpt = @(u) charFuncNts(u, sigmaOpt, kappaOpt, etaOpt);

    %% Model call prices
    callModel = runPricingFourier(charFuncNtsOpt, logMoneyness, dfMat, forward);
    callModel = callModel(:);

    undiscountedCallModel = callModel ./ dfMat;

    %% Model implied volatilities
    modelVols = arrayfun(@(strike, price) ...
        blsimpv(forward, strike, 0, timeToMaturity, price), ...
        strikes, ...
        undiscountedCallModel);

    modelVols = modelVols(:);

    %% Report
    idxPrint = unique([1, round(numel(strikes) / 2), numel(strikes)]);

    resultsTable = printCalibrationReport( ...
        alphaNts, ...
        sigmaOpt, ...
        kappaOpt, ...
        etaOpt, ...
        objValue, ...
        strikes, ...
        logMoneyness, ...
        marketVols, ...
        modelVols, ...
        callMarket, ...
        callModel, ...
        idxPrint);

    %% Plot
    plotVolSmile( ...
        logMoneyness, ...
        marketVols, ...
        modelVols, ...
        timeToMaturity);

    %% Package results
    resultsEx5.alphaNts = alphaNts;
    resultsEx5.penaltyValue = penaltyValue;
    resultsEx5.params0 = params0;
    resultsEx5.optimOptions = options;

    resultsEx5.paramsOpt = paramsOpt;
    resultsEx5.sigmaOpt = sigmaOpt;
    resultsEx5.kappaOpt = kappaOpt;
    resultsEx5.etaOpt = etaOpt;
    resultsEx5.objValue = objValue;

    resultsEx5.strikes = strikes;
    resultsEx5.logMoneyness = logMoneyness;
    resultsEx5.marketVols = marketVols;
    resultsEx5.modelVols = modelVols;
    resultsEx5.callMarket = callMarket;
    resultsEx5.callModel = callModel;
    resultsEx5.absError = abs(callModel - callMarket);
    resultsEx5.resultsTable = resultsTable;

    resultsEx5.spot = spot;
    resultsEx5.forward = forward;
    resultsEx5.discountFactor = dfMat;
    resultsEx5.dividendYield = dividendYield;
    resultsEx5.timeToMaturity = timeToMaturity;

end