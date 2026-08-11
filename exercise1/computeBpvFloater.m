function bpvFloater = computeBpvFloater(payDates, curveDates, curveDiscounts, refDate)
% computeBpvFloater Computes the basis point value of a floating leg.
%
% INPUTS:
%   payDates        : Column vector of payment dates.
%   curveDates      : Yield curve pillar dates.
%   curveDiscounts  : Discount factors at curve pillar dates.
%   refDate         : Initial date of the contract.
%
% OUTPUTS:
%   bpvFloater      : Basis point value of the floating leg.

% Extract discount factors at payment dates
discountFactors = getDiscountFactorByZeroRatesLinearInterp( ...
    refDate, payDates, curveDates, curveDiscounts);

% Build full schedule including reference date
scheduleDates = [refDate; payDates(:)];

% Compute accrual fractions with Act/360 convention
accrualFactors = yearfrac(scheduleDates(1:end-1), scheduleDates(2:end), 2);

% Compute BPV
bpvFloater = sum(discountFactors(:) .* accrualFactors(:));

end