function m = computeRawMomentsFromCF(phi, h)
% computeRawMomentsFromCF
% Compute the first four raw moments numerically from a characteristic function.
%
% INPUTS:
%   phi : function handle
%         Characteristic function phi(u)
%   h   : scalar
%         Finite-difference step
%
% OUTPUT:
%   m   : struct with fields
%         m.m1, m.m2, m.m3, m.m4

    phi0  = phi(0);
    phi_p = phi(h);
    phi_m = phi(-h);
    phi_2p = phi(2*h);
    phi_2m = phi(-2*h);

    % numerical derivatives of phi at 0
    phi1 = (phi_p - phi_m) / (2*h);
    phi2 = (phi_p - 2*phi0 + phi_m) / h^2;
    phi3 = (phi_2p - 2*phi_p + 2*phi_m - phi_2m) / (2*h^3);
    phi4 = (phi_2p - 4*phi_p + 6*phi0 - 4*phi_m + phi_2m) / h^4;

    % raw moments
    m.m1 = real(phi1 / (1i));
    m.m2 = real(phi2 / (1i)^2);
    m.m3 = real(phi3 / (1i)^3);
    m.m4 = real(phi4 / (1i)^4);
end