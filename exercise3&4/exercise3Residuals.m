function price = exercise3Residuals(p_plus, p_minus, mu, F0, B, x)
% exercise3Residuals Price of a European call for Exercise 3 using Cauchy's 
% Residue theorem.
%
% INPUTS:
%   p_plus  : positive rate of the upward exponential component
%   p_minus : positive rate of the downward exponential component
%   mu      : drift fixed by the martingale condition
%   F0      : ATM forward
%   B       : discount factor
%   x       : log-moneyness, x = ln(F0/K)
%
% OUTPUTS:
%   price   : price of the Call due to residue's theorem.

    % Initialize the output array to match the size of x
    integral = zeros(size(x));

    % Create logical masks for our two conditions (Upper or Lower Half Plane) 
    idxUHP = (x + mu) < 0; 
    idxLHP = ~idxUHP;      

    % Pre-calculate the scalar coefficients
    coeffUHP = p_minus / ((p_plus - 1) * (p_plus + p_minus));
    coeffLHP = p_plus / ((p_minus + 1) * (p_plus + p_minus));

    % Process all UHP elements simultaneously (if there are any)
    if any(idxUHP)
       xUHP = x(idxUHP); 

       Res1UHP = exp(xUHP ./ 2); % 2*pi*Res(0.5i).
       Res2UHP = -coeffUHP .* exp(p_plus .* (xUHP + mu)) .* exp(-xUHP ./ 2); % 2*pi*Res((p_plus-0.5)i).

       % Drop the computed values exactly back into their original slots
       integral(idxUHP) = Res1UHP + Res2UHP;
    end

    % Process all LHP elements simultaneously (if there are any)
    if any(idxLHP)
       xLHP = x(idxLHP);

       Res1LHP = exp(-xLHP ./ 2); % 2*pi*Res(-0.5i).
       Res2LHP = -coeffLHP .* exp(-p_minus .* (xLHP + mu)) .* exp(-xLHP ./ 2); % 2*pi*Res(-i(p_minus+0.5).

       % Drop the computed values exactly back into their original slots
       integral(idxLHP) = Res1LHP + Res2LHP;
    end

    price = B * F0 .* (1 - exp(-x./2) .* real(integral));

end