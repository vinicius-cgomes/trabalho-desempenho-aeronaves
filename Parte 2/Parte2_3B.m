% Trabalho Final - Desempenho
% Parte 2 - Envelope de voo em cruzeiro
% Exercício 3B: Comparação com Nível do Mar (SL) e FL450 (45000ft ou 13716m)

%% Modelo da Aeronave
m = 33100;          % massa total (kg)
S = 88;             % Área da asa (m^2)
CL_max = 2.0;       % Coeficiente de sustentação máx. p/ flapes recolhidos
g = 9.80665;        % gravidade (m/s^2)
T0 = 55600;         % Tração disponível ao nível do mar (N)
W = m * g;          % Peso (N)

%% Configurações
altitudes = [0, 3048, 13716];  % Nível do mar, 10.000 ft, 45.000 ft (m)
alt_names = {'Nível do Mar', '10.000 ft', '45.000 ft'};
colors = [0, 0.4470, 0.7410;    % Azul
          0.8500, 0.3250, 0.0980; % Laranja
          0.4660, 0.6740, 0.1880]; % Verde
line_styles = {'-', '--', '-.'};

%% Preparar figura
figure;
set(gcf, 'Position', [100, 100, 900, 600]);
hold on;
grid on;
box on;

%% Vetores para armazenar handles
h_req = gobjects(length(altitudes),1); % Tração requerida
h_disp = gobjects(length(altitudes),1); % Tração disponível
h_stall = gobjects(length(altitudes),1); % Velocidade de estol

%% Loop para cada altitude
for i = 1:length(altitudes)
    % Obter parâmetros atmosféricos
    [rho, ~, ~] = atmosferaISA(altitudes(i));
    
    % Velocidades de teste
    V = linspace(40, 400, 500);
    
    % Tração disponível
    T_available = T0 * (rho/1.225)^0.6;
    
    % Cálculos aerodinâmicos
    CL = (2 * W) ./ (rho * S * V.^2);
    CD = 0.015 + 0.05 * CL.^2;
    D = 0.5 * rho * V.^2 * S .* CD;
    
    % Velocidade de estol
    V_stall = sqrt(2 * W / (rho * S * CL_max));
    
    % Plot da velocidade de estol (linha vertical pontilhada)
    h_stall(i) = plot([V_stall V_stall], [0 60000], ':', 'Color', colors(i,:), ...
                    'LineWidth', 1, 'DisplayName', [alt_names{i} ' - V_{estol}']);
    
    % Encontrar pontos de operação
    intersections = find(diff(sign(D - T_available)));
    if ~isempty(intersections)
        V_min_oper = V(intersections(1));
        V_max_oper = V(intersections(end));
    else
        V_min_oper = NaN;
        V_max_oper = NaN;
    end
    
    % Exibir resultados
    fprintf('\n=== RESULTADOS PARA %s (%.0f m) ===\n', alt_names{i}, altitudes(i));
    fprintf(' - Densidade do ar: %.4f kg/m³\n', rho);
    fprintf(' - Velocidade de estol: %.2f m/s (%.2f km/h)\n', V_stall, V_stall*3.6);
    
    if ~isnan(V_min_oper)
        fprintf(' - Velocidade mínima de operação: %.2f m/s (%.2f km/h)\n', V_min_oper, V_min_oper*3.6);
        fprintf(' - Velocidade máxima de operação: %.2f m/s (%.2f km/h)\n', V_max_oper, V_max_oper*3.6);
    else
      
    end
    
    % Plot das curvas
    h_req(i) = plot(V, D, 'Color', colors(i,:), 'LineWidth', 2, ...
               'LineStyle', line_styles{i}, ...
               'DisplayName', [alt_names{i} ' - Tração Requerida']);
    
    h_disp(i) = plot(V, T_available * ones(size(V)), ':', 'Color', colors(i,:), ...
               'LineWidth', 1.5, 'DisplayName', [alt_names{i} ' - Tração Disponível']);
    
    % Marca pontos de operação
    if ~isnan(V_min_oper)
        plot(V_min_oper, T_available, 'o', 'Color', colors(i,:), ...
            'MarkerSize', 8, 'LineWidth', 1.5, 'HandleVisibility', 'off');
        plot(V_max_oper, T_available, 'o', 'Color', colors(i,:), ...
            'MarkerSize', 8, 'LineWidth', 1.5, 'HandleVisibility', 'off');
    end
end

%% Configurações do gráfico
xlabel('Velocidade (m/s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Tração (N)', 'FontSize', 12, 'FontWeight', 'bold');
title('Envelope de Tração em Diferentes Altitudes', ...
      'FontSize', 14, 'FontWeight', 'bold');

% Legendas
legend([h_req; h_disp; h_stall], 'Location', 'northeast', 'FontSize', 10);
set(gca, 'FontSize', 11, 'GridAlpha', 0.3);

% Ajustar eixos
xlim([40 400]);
ylim([0 60000]);

%% Função atmosferaISA
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