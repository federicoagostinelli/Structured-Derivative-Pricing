function out = compareNigMoments(charFuncNig, hBase, hGrid)
% compareNigMoments
% Computes raw moments from a characteristic function, compares them with
% moments obtained from the cumulant-generating function, and prints a
% sensitivity table.
%
% INPUTS:
%   charFuncNig : characteristic function handle, phi(u)
%   hBase       : base finite-difference step, e.g. 5e-3
%   hGrid       : vector of steps for sensitivity, e.g. [1e-2 5e-3 1e-3 1e-4]
%
% OUTPUT:
%   out : struct containing analytical moments, numerical moments, errors,
%         and sensitivity results.

    if nargin < 2 || isempty(hBase)
        hBase = 5e-3;
    end

    if nargin < 3 || isempty(hGrid)
        hGrid = [1e-2, 5e-3, 1e-3, 1e-4];
    end

    %% Moment-generating function and cumulant-generating function
    mgf = @(s) charFuncNig(-1i .* s);
    cgf = @(s) log(mgf(s));

    %% Analytical moments from cumulants
    hAna = 1e-4;

    K0  = cgf(0);
    Kp1 = cgf(hAna);
    Km1 = cgf(-hAna);
    Kp2 = cgf(2*hAna);
    Km2 = cgf(-2*hAna);

    kappa1 = real((Kp1 - Km1) / (2*hAna));
    kappa2 = real((Kp1 - 2*K0 + Km1) / hAna^2);
    kappa3 = real((Kp2 - 2*Kp1 + 2*Km1 - Km2) / (2*hAna^3));
    kappa4 = real((Kp2 - 4*Kp1 + 6*K0 - 4*Km1 + Km2) / hAna^4);

    m1_ana = kappa1;
    m2_ana = kappa2 + kappa1^2;
    m3_ana = kappa3 + 3*kappa2*kappa1 + kappa1^3;
    m4_ana = kappa4 + 4*kappa3*kappa1 + 3*kappa2^2 + ...
             6*kappa2*kappa1^2 + kappa1^4;

    momAna = [m1_ana; m2_ana; m3_ana; m4_ana];

    %% Numerical moments from CF
    momentsNum = computeRawMomentsFromCF(charFuncNig, hBase);

    momNum = [
        momentsNum.m1;
        momentsNum.m2;
        momentsNum.m3;
        momentsNum.m4
    ];

    absErr = abs(momNum - momAna);
    relErr = absErr ./ max(abs(momAna), eps);

    %% Print comparison
    fprintf('\n--- NIG raw moments: numerical vs analytical ---\n');
    fprintf('Base finite-difference step h = %.1e\n', hBase);
    fprintf('%8s %18s %18s %18s %18s\n', ...
        'Moment', 'Numerical', 'Analytical', 'Abs Error', 'Rel Error');

    for j = 1:4
        fprintf('%8s %18.10e %18.10e %18.10e %18.10e\n', ...
            sprintf('m%d', j), momNum(j), momAna(j), absErr(j), relErr(j));
    end

    %% Sensitivity table
    sensitivity = struct();

    fprintf('\n--- NIG moment sensitivity vs analytical moments ---\n');
    fprintf('%10s %18s %18s %18s %18s\n', ...
        'h', 'err m1', 'err m2', 'err m3', 'err m4');

    for q = 1:numel(hGrid)
        h = hGrid(q);

        momTmpStruct = computeRawMomentsFromCF(charFuncNig, h);
        momTmp = [
            momTmpStruct.m1;
            momTmpStruct.m2;
            momTmpStruct.m3;
            momTmpStruct.m4
        ];

        errTmp = abs(momTmp - momAna);

        fprintf('%10.1e %18.10e %18.10e %18.10e %18.10e\n', ...
            h, errTmp(1), errTmp(2), errTmp(3), errTmp(4));

        sensitivity(q).h = h;
        sensitivity(q).moments = momTmp;
        sensitivity(q).absError = errTmp;
    end

    %% Store output
    out = struct();

    out.hBase = hBase;
    out.hGrid = hGrid;

    out.cumulants = struct( ...
        'kappa1', kappa1, ...
        'kappa2', kappa2, ...
        'kappa3', kappa3, ...
        'kappa4', kappa4);

    out.analyticalMoments = struct( ...
        'm1', momAna(1), ...
        'm2', momAna(2), ...
        'm3', momAna(3), ...
        'm4', momAna(4));

    out.numericalMoments = momentsNum;

    out.absError = struct( ...
        'm1', absErr(1), ...
        'm2', absErr(2), ...
        'm3', absErr(3), ...
        'm4', absErr(4));

    out.relError = struct( ...
        'm1', relErr(1), ...
        'm2', relErr(2), ...
        'm3', relErr(3), ...
        'm4', relErr(4));

    out.sensitivity = sensitivity;
end