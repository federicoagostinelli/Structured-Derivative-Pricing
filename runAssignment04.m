% runAssignment04_Group01
% Group 01, AY2025-2026

clc; clear; close all
format long

projectRoot = fileparts(which('runAssignment04_Group01.m'));
addpath(genpath(projectRoot));

%% Read and bootstrap the discount curve
[curveDatesSet, curveRatesSet] = readExcelData('MktData_CurveBootstrap.xls', 'dd-mmm-yy');
[curveDates, curveDiscounts, curveZeroRates] = bootstrap(curveDatesSet, curveRatesSet);

% Market inputs
market.dates = curveDates;
market.discounts = curveDiscounts;
market.zeroRates = curveZeroRates;

%% Exercise 1
% Dates
dateInfo.refDate = market.dates(1);
dateInfo.maturityAdjust = 'following';
dateInfo.paymentAdjust = 'modifiedfollowing';
dateInfo.matDate = businessDateOffsetTarget( ...
      dateInfo.refDate, 5, 0, 0, dateInfo.maturityAdjust);

% additional Market input
market.rho = 0.49;

% Product parameters
product.principal = 1e8;
product.protection = 0.95;
product.alpha = 1.1;
product.weights = [1/2; 1/2];
product.spread = 0.013;
product.paymentsPerYear = 4;

% Underlyings
eni.spot = 12.3;
eni.sigma = 0.201;
eni.dividendYield = 0.032;

axa.spot = 22.1;
axa.sigma = 0.183;
axa.dividendYield = 0.029;

% Simulation parameter
mc.numSim = 1e7;

% Run Exercise 1
% Set random seed for reproducible Monte Carlo simulations
rng(42, 'twister');
resultsEx1 = runExercise1(dateInfo, product, eni, axa, market, mc.numSim);

%% Exercise 2
% Dates
dateInfo.dateAdjust = 'modifiedfollowing';
dateInfo.matDate = businessDateOffsetTarget(dateInfo.refDate, 1, 0, 0, dateInfo.dateAdjust);
dateInfo.timeToMaturity = yearfrac(dateInfo.refDate, dateInfo.matDate, 3);

% Market data
marketDataEx2 = load("eurostoxx_Poli.mat");
% Market data for the underlying
underlying.strikes = double(marketDataEx2.cSelect.strikes(:));
underlying.volSmile = double(marketDataEx2.cSelect.surface(:));
underlying.spot = double(marketDataEx2.cSelect.reference);
underlying.dividendYield = double(marketDataEx2.cSelect.dividends);
    
% Product parameters
productEx2.notional = 1e7;
productEx2.digitalCoupon = 0.05;

% Run Exercise 2
resultsEx2 = runExercise2(underlying, dateInfo, productEx2, marketDataEx2, market);

%% Shared inputs for Exercises 3, 4 and 5
forward = resultsEx2.forward;
dfMat = resultsEx2.dfMat;

%% Exercise 3
% Model parameters
model3.xVals = [-0.05223; 0.0; 0.15];
model3.pPlus = 1.5;
model3.pMinus = 0.9;

model3.charFuncBase = @(u) 1 ./ ...
    ((1 - 1i .* u / model3.pPlus) .* (1 + 1i .* u / model3.pMinus));
model3.mu = -log(model3.charFuncBase(-1i));
model3.charFunc = @(u) model3.charFuncBase(u) .* exp(1i .* u .* model3.mu);

% FFT parameters
fft3.M = 15;
fft3.N = 2^fft3.M;
fft3.xLeft = -500;
fft3.dx = 0.0305185094759972;
fft3.xRight = fft3.xLeft + fft3.N * fft3.dx;
fft3.zLeft = -102.934389095871;
fft3.dz = 0.00628280825805664;

% Run Exercise 3
rng(100, 'twister'); 
resultsEx3 = runExercise3(model3, fft3, dfMat, forward, mc.numSim);

%% Exercise 4
% Required pricing grid: moneyness from -25% to +25% in 1% steps
model4.xVals = (-0.25:0.01:0.25).';

% NTS parameters
model4.sigma = 0.20;
model4.kappa = 1.0;
model4.eta = 3.0;
model4.timeToMaturity = 1.0;

% FFT parameters for NTS with alpha=1/2 (NIG)
fftNIG.M = 15;
fftNIG.N = 2^fftNIG.M;
fftNIG.dz = 0.0025;
fftNIG.dx = 2 * pi / (fftNIG.N * fftNIG.dz);

% Centered grids
fftNIG.xLeft  = -fftNIG.N / 2 * fftNIG.dx;
fftNIG.xRight =  fftNIG.N / 2 * fftNIG.dx;

fftNIG.zLeft  = -fftNIG.N / 2 * fftNIG.dz;
fftNIG.zRight =  fftNIG.N / 2 * fftNIG.dz;

fftNIG.xGrid = fftNIG.xLeft + (0:fftNIG.N - 1) * fftNIG.dx;
fftNIG.zGrid = fftNIG.zLeft + (0:fftNIG.N - 1) * fftNIG.dz;

% FFT parameters for NTS with alpha=1/3 
fftNts.M = 16;
fftNts.N = 2^fftNts.M;
fftNts.xLeft = -250;
fftNts.xRight = 250;
fftNts.dx = (fftNts.xRight - fftNts.xLeft) / fftNts.N;
fftNts.xGrid = fftNts.xLeft + (0:fftNts.N - 1) * fftNts.dx;
fftNts.dz = 2 * pi / (fftNts.N * fftNts.dx);
fftNts.zLeft = -fftNts.N / 2 * fftNts.dz;

% Run Exercise 4
rng(200, 'twister');
resultsEx4 = runExercise4(model4, fftNIG, fftNts, dfMat, forward, mc.numSim);

%% Exercise 5

timeToMaturity = dateInfo.timeToMaturity;

% Exercise 5 market data
marketEx5.strikes = underlying.strikes(:);
marketEx5.marketVols = underlying.volSmile(:);
marketEx5.spot = underlying.spot;
marketEx5.dividendYield = underlying.dividendYield;

% Exercise 5 calibration settings
ex5.alphaNts = 2 / 3;
ex5.penaltyValue = 1e12;

% Initial guess: p = [sigma; kappa; eta]
ex5.params0 = [0.20; 1.00; 0.10];

% Optimisation settings
ex5.optimOptions = optimset( ...
    'Display', 'off', ...
    'TolX', 1e-6, ...
    'TolFun', 1e-6, ...
    'MaxFunEvals', 5000, ...
    'MaxIter', 5000);

% Run Exercise 5
resultsEx5 = runExercise5( ...
    marketEx5, ...
    forward, ...
    dfMat, ...
    timeToMaturity, ...
    ex5);