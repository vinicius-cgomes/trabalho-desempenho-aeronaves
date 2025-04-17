function [rho, T, p] = atmosferaISA(H)
    % Constantes
    R = 287;                % Constante dos gases [J/kg·K]
    g = 9.80665;            % Gravidade [m/s²]
    rho_SL = 1.225;         % Densidade ao nível do mar [kg/m³]
    T_SL = 15 + 273.15;     % Temperatura ao nível do mar [K] = 15°C
    gradT = -6.5 / 1000;    % Gradiente térmico da troposfera [K/m]

    if H <= 11000  % Troposfera
        T = T_SL + gradT * H;
        rho = rho_SL * (1 + (gradT * H)/T_SL)^(-g/(R * gradT) - 1);
        p = rho * R * T;
    else  % Estratosfera até 20.000 m
        T11 = T_SL + gradT * 11000;
        rho_11 = atmosferaISA(11000); % Chama a função para obter a densidade a 11.000 m
        T = T11;
        rho = rho_11 * exp(-g * (H - 11000)/(R * T11));
        p = rho * R * T;
    end
end
