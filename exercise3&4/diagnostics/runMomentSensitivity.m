function momentSensitivity = runMomentSensitivity(charFunc, hGrid)
% RUNMOMENTSENSITIVITY Print sensitivity of numerical raw moments to h.
%
%   momentSensitivity = runMomentSensitivity(charFunc, hGrid)
%
%   Computes numerical raw moments from a characteristic function for
%   different finite-difference steps h. The routine is mainly used to check
%   the stability of moment estimates, especially the fourth moment, which is
%   more sensitive to round-off errors for very small h.
%
% INPUTS:
%   charFunc : function handle
%              Characteristic function of the log-return.
%
%   hGrid    : numeric vector
%              Finite-difference step sizes used in the numerical moment
%              approximation.
%
% OUTPUT:
%   momentSensitivity : struct containing:
%                       hGrid : tested finite-difference steps
%                       m1    : first raw moment for each h
%                       m2    : second raw moment for each h
%                       m3    : third raw moment for each h
%                       m4    : fourth raw moment for each h
%
% NOTES:
%   - Moments are computed by computeRawMomentsFromCF.
%   - Very small h can make high-order derivatives unstable due to
%     floating-point round-off error.
%   - The fourth moment is usually the first one to show numerical
%     instability.

    disp(' ')
    disp('--- NTS alpha = 1/3 moment sensitivity to h ---')

    hGrid = hGrid(:).';

    nH = numel(hGrid);

    m1 = zeros(1, nH);
    m2 = zeros(1, nH);
    m3 = zeros(1, nH);
    m4 = zeros(1, nH);

    fprintf('%10s %14s %14s %14s %14s\n', ...
        'h', 'm1', 'm2', 'm3', 'm4');

    for j = 1:nH
        h = hGrid(j);
        moments = computeRawMomentsFromCF(charFunc, h);

        m1(j) = moments.m1;
        m2(j) = moments.m2;
        m3(j) = moments.m3;
        m4(j) = moments.m4;

        fprintf('%10.1e %14.6e %14.6e %14.6e %14.6e\n', ...
            h, m1(j), m2(j), m3(j), m4(j));
    end

    % Optional warning if the fourth moment visibly changes across h values.
    if nH >= 2
        m4Range = max(m4) - min(m4);
        m4Scale = max(abs(m4));

        if m4Scale > 0 && m4Range / m4Scale > 1e-2
            fprintf('Note: m4 changes noticeably across h values, indicating numerical sensitivity.\n');
        end
    end

    momentSensitivity.hGrid = hGrid;
    momentSensitivity.m1 = m1;
    momentSensitivity.m2 = m2;
    momentSensitivity.m3 = m3;
    momentSensitivity.m4 = m4;

end