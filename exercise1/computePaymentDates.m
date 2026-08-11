function [payDates, details] = computePaymentDates(refDate, matDate, paymentsPerYear, dateAdjust)
% computePaymentDates Computes the adjusted payment schedule between
% reference date and maturity date.
%
% INPUTS:
%   refDate          : Initial date of the contract.
%   matDate          : Final maturity date.
%   paymentsPerYear  : Number of payments per year.
%   dateAdjust       : Business day convention, for example
%                      'following' or 'modifiedfollowing'.
%
% OUTPUTS:
%   payDates         : Column vector of adjusted payment dates.
%   details          : Struct containing variables for reporting.

monthsPerStep = 12 / paymentsPerYear;

% Compute number of whole periods between reference date and maturity date
totalMonths = split(between(refDate, matDate, 'Months'), 'Months');
numPeriods = floor(totalMonths / monthsPerStep);

% Preallocate payment schedule
schedule = NaT(numPeriods, 1);

% Build schedule one payment date at a time
for idx = 1:numPeriods
    monthsToAdd = idx * monthsPerStep;
    schedule(idx) = businessDateOffsetTarget(refDate, 0, monthsToAdd, 0, dateAdjust);
end

% Ensure maturity date is included
if ~isempty(schedule) && schedule(end) == matDate
    payDates = schedule;
else
    payDates = [schedule; matDate];
end

% Store report details
details = struct();
details.paymentsPerYear = paymentsPerYear;
details.numPeriods = numPeriods;

end