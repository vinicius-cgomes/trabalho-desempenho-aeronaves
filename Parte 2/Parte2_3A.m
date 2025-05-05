% Trabalho Final - Desempenho
% Parte 2 - Envelope de voo em cruzeiro
% Exercício 3A: Curvas de tração disponível e requerida

%% Modelo da Aeronave
m = 33100;          % massa total (kg)
S = 88;             % area da asa (m^2)
CL_max = 2.0;       % Coeficiente de sustentação max. p/ flapes recolhidos
g = 9.80665;        % gravidade (m/s^2)
T0 = 55600;         % Tração disponivel ao nível do mar (N)
Vmo_sl = 890/3.6;   % Velocidade máxima estrutural ao nível do mar (m/s)

%% Cálculos iniciais
W = m * g;          % Peso (N)
altitude = 3048;    % 10.000 ft = 3.048 m

% Obter parametros atmosféricos usando a função atmosferaISA
[rho, T_ISA, p] = atmosferaISA(altitude);
rho_sl = 1.225;     % Densidade ao nível do mar (kg/m³)

% Coeficientes aerodinâmicos
CD0 = 0.015;        % Coeficiente de arrasto parasita
k = 0.05;           % Fator de arrasto induzido

%% Velocidades de teste (m/s)
V_min_calc = 40;    % Valor minimo para cálculo
V_max_calc = 400;   % Valor maximo para cálculo
V_step = 1;         % Incremento de velocidade
V = V_min_calc:V_step:V_max_calc;

%% Calculos aerodinamicos
% Coeficiente de sustentacao
CL = (2 * W) ./ (rho * S * V.^2);

% Coeficiente de arrasto (polar de arrasto)
CD = CD0 + k * CL.^2;

% Tração requerida (Arrasto Total)
D = 0.5 * rho * V.^2 * S .* CD;

% Tracao disponivel (manete 100%) - modelo corrigido
T_available = T0 * (rho/rho_sl)^0.6;

% Velocidade de estol
V_stall = sqrt(2 * W / (rho * S * CL_max));

% Velocidade maxima estrutural corrigida para altitude
v_stc_funh = @(h) Vmo_sl * sqrt(rho_sl./atmosferaISA(h));
Vmo = v_stc_funh(altitude);

%% Determinação dos pontos de operação
% Encontrar interseções entre tração disponível e requerida
intersections = find(diff(sign(D - T_available)));
V_min_oper = V(intersections(1));
V_max_oper = V(intersections(end));

%% Cálculo e exibicao das velocidades características
fprintf('\n=== RESULTADOS PARA ALTITUDE DE %.0f m (%.0f ft) ===\n', altitude, altitude/0.3048);
fprintf(' - Densidade do ar: %.4f kg/m³\n', rho);
fprintf(' - Velocidade de estol (Vstall): %.2f m/s (%.2f km/h)\n', V_stall, V_stall*3.6);
fprintf(' - Velocidade mínima de operação (Vmin): %.2f m/s (%.2f km/h)\n', V_min_oper, V_min_oper*3.6);
fprintf(' - Velocidade máxima de operação (Vmax): %.2f m/s (%.2f km/h)\n', V_max_oper, V_max_oper*3.6);
fprintf(' - Velocidade máxima estrutural (Vmo): %.2f m/s (%.2f km/h)\n\n', Vmo, Vmo*3.6);

%% Plotagem das curvas
figure;
set(gcf, 'Position', [100, 100, 800, 600]); % Tamanho da figura

% Curvas principais
plot(V, D, 'b-', 'LineWidth', 2); 
hold on;
plot(V, T_available * ones(size(V)), 'r-', 'LineWidth', 2);

% Linhas de referência
xline(V_stall, 'k--', 'LineWidth', 1.5, 'Label', 'V_{stall}', 'LabelOrientation', 'horizontal');
xline(Vmo, 'g--', 'LineWidth', 1.5, 'Label', 'V_{mo}', 'LabelOrientation', 'horizontal');

% Marcar Vmin e Vmax com X
plot(V_min_oper, T_available, 'kx', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'V_{min}');
plot(V_max_oper, T_available, 'kx', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'V_{max}');

% Configurações do gráfico
xlabel('Velocidade (m/s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Tração (N)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Tração vs. Velocidade em %d ft (%.0f m)', altitude/0.3048, altitude), ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Tração Requerida', 'Tração Disponível', 'V_{stall}', 'V_{MO}', ...
       'Location', 'best', 'FontSize', 10);
grid on;
set(gca, 'FontSize', 11, 'GridAlpha', 0.3);

% Adicionar informações no gráfico
text(0.05, 0.95, sprintf('Altitude: %.0f m (%.0f ft)', altitude, altitude/0.3048), ...
     'Units', 'normalized', 'FontSize', 10, 'BackgroundColor', 'w');
text(0.05, 0.90, sprintf('Densidade do ar: %.4f kg/m³', rho), ...
     'Units', 'normalized', 'FontSize', 10, 'BackgroundColor', 'w');

%% Função para modelo atmosférico ISA
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
        [rho_11, ~, ~] = atmosferaISA(11000); % Densidade a 11.000 m
        T = T11;
        rho = rho_11 * exp(-g * (H - 11000)/(R * T11));
        p = rho * R * T;
    end
end