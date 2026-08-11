function printExercise1Report(principal, refDate, matDate, protection, alpha, spread, rho, dfMat, bpvFloater, coupon, couponMC, xPerc, xPercMC, detailsDates, detailsCoupon, detailsMC)
% printExercise1Report Prints a formatted valuation report for Exercise 1.
%
% INPUTS:
%   principal      : Contract notional amount.
%   refDate        : Start date.
%   matDate        : Maturity date.
%   protection     : Protection level.
%   alpha          : Participation coefficient.
%   spread         : Floating leg spread.
%   rho            : Correlation between assets.
%   dfMat          : Discount factor at maturity.
%   bpvFloater     : Basis point value of the floater.
%   coupon         : Final monetary coupon value (Analytical/LogNormal).
%   couponMC       : Final monetary coupon value (Monte Carlo).
%   xPerc          : Calculated upfront percentage via LogNormal approximation.
%   xPercMC        : Calculated upfront percentage via MC simulation.
%   detailsDates   : Struct containing schedule details.
%   detailsCoupon  : Struct containing basket calculation details.
%   detailsMC      : Struct containing Monte Carlo simulation details.

fprintf('\n');
fprintf('============================================================\n');
fprintf('    EXERCISE 1: CERTIFICATE PRICING & UPFRONT CALCULATION\n');
fprintf('============================================================\n');
fprintf('Principal Amount (N)      : EUR %15.2f\n', principal);
fprintf('Start Date                : %19s\n', datestr(refDate, 'dd-mmm-yyyy'));
fprintf('Maturity Date             : %19s\n', datestr(matDate, 'dd-mmm-yyyy'));
fprintf('Protection Level (P)      : %15.2f %%\n', protection * 100);
fprintf('Participation (alpha)     : %15.2f %%\n', alpha * 100);
fprintf('Euribor Spread            : %15.2f bps\n', spread * 10000);
fprintf('Correlation (rho)         : %15.2f %%\n', rho * 100);
fprintf('------------------------------------------------------------\n');
fprintf('--- Basket & Option Parameters (Moment Matching) ---\n');
fprintf('Synthetic Basket Variance : %15.6f\n', detailsCoupon.basketVariance);
fprintf('Synthetic Basket Vol      : %15.2f %%\n', detailsCoupon.basketSigma * 100);
fprintf('Total Payment Periods     : %15d\n', detailsDates.numPeriods);
fprintf('------------------------------------------------------------\n');
fprintf('--- Valuation Components (Analytical) ---\n');
fprintf('Discount Factor @ Maturity: %15.6f\n', dfMat);
fprintf('BPV Floater               : %15.6f\n', bpvFloater);
fprintf('Call Price                : %15.6f\n', detailsCoupon.callPrice);
fprintf('Coupon Value (Party B)    : EUR %15.2f\n', coupon);

% Monte Carlo Comparison
fprintf('------------------------------------------------------------\n');
fprintf('--- Monte Carlo Comparison (Basket Call) ---\n');
fprintf('MC Simulations (Nsim)     : %15d\n', detailsMC.Nsim);
fprintf('MC Call Price             : %15.6f\n', detailsMC.CallMC);
fprintf('MC Coupon Value           : EUR %15.2f\n', couponMC);
fprintf('MC Standard Error         : %15.6f\n', detailsMC.MCError);
fprintf('Abs. Diff (LogN vs MC)    : EUR %15.2f\n', abs(coupon - couponMC));

fprintf('============================================================\n');
fprintf('>>> FINAL UPFRONT (LogNormal) (X%%)    : %15.4f %%\n', xPerc * 100);
fprintf('>>> UPFRONT AMOUNT (LogNormal)         : EUR %15.2f\n', xPerc * principal);
fprintf('>>> FINAL UPFRONT (MC) (X%%)    : %15.4f %%\n', xPercMC * 100);
fprintf('>>> UPFRONT AMOUNT (MC)         : EUR %15.2f\n', xPercMC * principal);
fprintf('============================================================\n\n');

% Asset details table
fprintf('BASKET ASSET DETAILS\n');
fprintf('-----------------------------------------------------------------------\n');
assetNames = ["ENI"; "AXA"];
initialPrice = [12.3; 22.1];
volatilityPct = [20.1; 18.3];
dividendPct = [3.2; 2.9];
weightPct = [50; 50];

detailTable = table( ...
    assetNames, initialPrice, volatilityPct, dividendPct, weightPct, ...
    'VariableNames', {'Asset', 'SpotEur', 'VolatilityPct', 'DividendPct', 'WeightPct'});
disp(detailTable);
fprintf('\n');
end