function printExercise2Report(notional, digitalPayoff, refDate, matDate, dfMat, blackPrice, correctionTerm, correctedPrice, detailsBP, detailsCorr)
% printExercise2Report Prints a formatted valuation report for Exercise 2.
%
% INPUTS:
%   notional        : Contract notional.
%   digitalPayoff   : Digital payoff amount.
%   refDate         : Valuation date.
%   matDate         : Maturity date.
%   dfMat           : Discount factor at maturity.
%   blackPrice      : Digital price under Black approximation.
%   correctionTerm  : Smile correction term.
%   correctedPrice  : Smile-corrected digital price.
%   detailsBP       : Struct with Black pricing details.
%   detailsCorr     : Struct with correction term details.

fprintf('\n');
fprintf('============================================================\n');
fprintf('        EXERCISE 2: DIGITAL OPTION PRICING WITH SMILE\n');
fprintf('============================================================\n');
fprintf('Notional                  : EUR %15.2f\n', notional);
fprintf('Digital Payoff            : EUR %15.2f\n', digitalPayoff);
fprintf('Reference Date            : %19s\n', datestr(refDate, 'dd-mmm-yyyy'));
fprintf('Maturity Date             : %19s\n', datestr(matDate, 'dd-mmm-yyyy'));
fprintf('Time to Maturity          : %19.6f\n', detailsBP.timeToMaturity);
fprintf('Discount Factor @ Maturity: %15.6f\n', dfMat);
fprintf('------------------------------------------------------------\n');
fprintf('--- Black Approximation ---\n');
fprintf('ATM Forward               : %19.2f\n', detailsBP.forward);
fprintf('ATM Volatility            : %15.2f %%\n', detailsBP.sigmaAtm * 100);
fprintf('Black Digital Price       : %15.6f\n', blackPrice*digitalPayoff);
fprintf('------------------------------------------------------------\n');
fprintf('--- Smile Correction ---\n');
fprintf('Volatility Slope          : %15.6f\n', detailsCorr.slope);
fprintf('Black Vega                : %15.6f\n', detailsCorr.vega);
fprintf('Correction Term           : %15.6f\n', correctionTerm*digitalPayoff);
fprintf('------------------------------------------------------------\n');
fprintf('>>> CORRECTED DIGITAL PRICE: %14.6f\n', correctedPrice*digitalPayoff);
fprintf('============================================================\n\n');

end