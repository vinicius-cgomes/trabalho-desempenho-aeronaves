function [value, isterminal, direction] = evento_altura_zero(t, y)
    value = y(3);         % y(3) é a altura H
    isterminal = 1;       % para a simulação quando H = 0
    direction = -1;       % só detectar quando estiver descendo
end
