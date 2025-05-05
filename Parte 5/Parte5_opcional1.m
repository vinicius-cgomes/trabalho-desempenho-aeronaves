%Trabalho Final - Desempenho
%Parte 5 - Análise de Decolagem com Pista Balanceada
%Exercício Opcional 1: Cálculo do MTOW Limitado por BFL
%Slides 1 a 16 - Aula Desempenho em Pista

%% DADOS DA CONDIÇÃO ESPECÍFICA (ISA+15°C = 30°C)
T = 30;                          % Temperatura [°C]
g = 9.80665;                     % Aceleração da gravidade [m/s²]
rho = 1.225 * (288.15 / (T + 273.15));  % Densidade do ar [kg/m³]
MTOW = 24550.1;                  % Massa limitada por BFL [kg]
V1 = 40.9;                       % Velocidade de decisão [m/s]
V_stall = sqrt(2 * MTOW * g / (rho * 88 * 2.5)); % Velocidade de estol
V_LOF = 1.1 * V_stall;           % Velocidade de decolagem [m/s]

%% PARÂMETROS DINÂMICOS
dt = 0.1;                        % Passo de tempo [s]
t_max = 60;                      % Tempo máximo de simulação [s]
t = 0:dt:t_max;                  % Vetor de tempo [s]

%% PRÉ-ALOCAÇÃO DE VARIÁVEIS
% Decolagem (OEI)
V_OEI = zeros(size(t));          % Velocidade (TAS) [m/s]
x_OEI = zeros(size(t));          % Distância [m]

% Abortagem (RTO)
V_RTO = zeros(size(t));          % Velocidade (TAS) [m/s]
x_RTO = zeros(size(t));          % Distância [m]

%% DECOLAGEM (OEI)
T_max = 55600;                   % Tração máxima (2 motores) [N]
T_OEI = 0.5 * T_max;             % Tração com 1 motor [N]
CL = 0.3;                        % Coef. de sustentação
CD = 0.03 + 0.07 * CL^2;         % Coef. de arrasto

for i = 2:length(t)
    % Fase 1: Aceleração com 2 motores até V1
    if V_OEI(i-1) < V1
        T_current = T_max;
    else
        T_current = T_OEI;       % Falha em V1 (OEI)
    end
    
    % Forças atuantes
    L = 0.5 * rho * V_OEI(i-1)^2 * 88 * CL;
    D = 0.5 * rho * V_OEI(i-1)^2 * 88 * CD;
    R = 0.02 * (MTOW * g - L);
    a = (T_current - D - R) / MTOW;
    
    % Atualiza velocidade e distância
    V_OEI(i) = V_OEI(i-1) + a * dt;
    x_OEI(i) = x_OEI(i-1) + V_OEI(i) * dt;
    
    % Condição de parada (atingiu V_LOF)
    if V_OEI(i) >= V_LOF
        break;
    end
end

%% ABORTAGEM (RTO)
braking_started = false;         % Flag para início da frenagem
reaction_time = 2;               % Tempo de reação do piloto [s]
reaction_distance = 0;           % Distância durante reação

for i = 2:length(t)
    % Fase 1: Aceleração com 2 motores até V1
    if ~braking_started
        T_current = T_max;
        L = 0.5 * rho * V_RTO(i-1)^2 * 88 * CL;
        D = 0.5 * rho * V_RTO(i-1)^2 * 88 * CD;
        R = 0.02 * (MTOW * g - L);
        a = (T_current - D - R) / MTOW;
        
        % Atualiza velocidade e distância
        V_RTO(i) = V_RTO(i-1) + a * dt;
        x_RTO(i) = x_RTO(i-1) + V_RTO(i) * dt;
        
        % Verifica se atingiu V1
        if V_RTO(i) >= V1
            braking_started = true;
            reaction_distance = x_RTO(i); % Armazena distância até V1
            t_reaction = t(i); % Armazena tempo até V1
        end
    else
        % Fase 2: Frenagem após V1
        if t(i) <= t_reaction + reaction_time
            % Período de reação (2s) - velocidade constante
            V_RTO(i) = V1;
            x_RTO(i) = x_RTO(i-1) + V1 * dt;
        else
            % Frenagem efetiva
            a = -0.35 * g;        % Desaceleração constante
            V_RTO(i) = max(0, V_RTO(i-1) + a * dt);
            x_RTO(i) = x_RTO(i-1) + V_RTO(i) * dt;
        end
        
        % Condição de parada (velocidade <= 0)
        if V_RTO(i) <= 0
            break;
        end
    end
end

%% RESULTADOS
% Tempo e distância para OEI (até V_LOF)
t_OEI = t(find(V_OEI >= V_LOF, 1));
dist_OEI = x_OEI(find(V_OEI >= V_LOF, 1));

% Tempo e distância para RTO (até parada)
t_RTO = t(find(V_RTO <= 0, 1));
dist_RTO = x_RTO(find(V_RTO <= 0, 1));

%% IMPRESSÃO DOS RESULTADOS
fprintf('\n--- RESULTADOS PARA ISA+15°C (30°C) ---\n');
fprintf('MTOW: %.1f kg\n', MTOW);
fprintf('V1: %.1f m/s\n', V1);
fprintf('V_LOF: %.1f m/s\n', V_LOF);
fprintf('\nDECOLAGEM (OEI):\n');
fprintf('Tempo até V_LOF: %.1f s\n', t_OEI);
fprintf('Distância percorrida: %.1f m\n', dist_OEI);
fprintf('\nABORTAGEM (RTO):\n');
fprintf('Tempo até parada: %.1f s\n', t_RTO);
fprintf('Distância percorrida: %.1f m\n', dist_RTO);

%% GRÁFICOS
figure;

% Velocidade vs Tempo
subplot(3,1,1);
plot(t(1:length(V_OEI)), V_OEI(1:length(V_OEI)), 'b', 'LineWidth', 2); hold on;
plot(t(1:length(V_RTO)), V_RTO(1:length(V_RTO)), 'r', 'LineWidth', 2);
xline(t(find(V_OEI >= V1, 1)), '--k', 'V_1');
xline(t(find(V_OEI >= V_LOF, 1)), '--g', 'V_{LOF}');
xlabel('Tempo [s]', 'FontSize', 12);
ylabel('Velocidade [m/s]', 'FontSize', 12);
legend('Decolagem (OEI)', 'Abortagem (RTO)', 'Location', 'NorthWest');
title('Velocidade vs Tempo', 'FontSize', 14);
grid on;

% Distância vs Tempo
subplot(3,1,2);
plot(t(1:length(x_OEI)), x_OEI(1:length(x_OEI)), 'b', 'LineWidth', 2); hold on;
plot(t(1:length(x_RTO)), x_RTO(1:length(x_RTO)), 'r', 'LineWidth', 2);
xlabel('Tempo [s]', 'FontSize', 12);
ylabel('Distância [m]', 'FontSize', 12);
legend('Decolagem (OEI)', 'Abortagem (RTO)', 'Location', 'NorthWest');
title('Distância Percorrida vs Tempo', 'FontSize', 14);
grid on;

% Massa vs Tempo (constante)
subplot(3,1,3);
plot(t, MTOW * ones(size(t)), 'k', 'LineWidth', 2);
xlabel('Tempo [s]', 'FontSize', 12);
ylabel('Massa [kg]', 'FontSize', 12);
title('Massa vs Tempo (Consumo Desprezível)', 'FontSize', 14);
grid on;