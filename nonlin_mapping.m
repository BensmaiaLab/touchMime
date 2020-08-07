% get the parameters vector for X for lsqcurvefit
function [F] = nonlin_mapping(params, X)
    %SIGMF(X, [A, C]) = 1./(1 + EXP(-A*(X-C)));
    F = params(1)+X*params(2:end-3);
    F = params(end-2)*sigmf(F,[params(end-1) params(end)]);
    F(F<0)=0;

end