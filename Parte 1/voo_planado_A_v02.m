% ====================================
% Simulação de voo planado - Parte A
% ====================================

clear; clc; close all

%% 1. Dados da aeronave e constantes
g = 9.8;                    
m = 33100;                  
S = 88;                     
rho0 = 1.225;               % densidade ao nível do mar [kg/m³]

% Flapes recolhidos (configuração de cruzeiro)
CD0 = 0.015;                
k = 0.05;                   
CL_max = 2.0;
CL_min = -1.0;

%% 2. Altura inicial e atmosfera ISA
H0 = 10000;                      % altura inicial [m]
[rho, T, p] = atmosferaISA(H0);  % Calcular densidade inicial, temperatura e pressão

%% 3. Cálculo dos coeficientes aerodinâmicos
CL = sqrt(CD0 / k);         
CD = CD0 + k * CL^2;        
E = CL / CD;                 

%% 4. Condições iniciais de voo
V0 = sqrt((2 * m * g) / (rho * S) * (1 / sqrt(CL^2 + CD^2)));
gamma0 = -atan(1 / E);     % ângulo de planeio ótimo
Y0 = [V0; gamma0; H0; 0];  % [V, gamma, H, x]

%% 5. Simulação com ode45
tspan = [0 2000];

f = @(t, Y) [
    (-0.5 * rho * Y(1)^2 * S * CD - m * g * sin(Y(2))) / m;
    (0.5 * rho * Y(1)^2 * S * CL - m * g * cos(Y(2))) / (m * Y(1));
    Y(1) * sin(Y(2));
    Y(1) * cos(Y(2))
];

[t, Y] = ode45(f, tspan, Y0);

V = Y(:,1); gamma = Y(:,2); H = Y(:,3); x = Y(:,4);

%% 6. Atualizando a densidade ao longo da trajetória
rho_traj = zeros(size(H));  % Vetor para armazenar a densidade em cada ponto
for i = 1:length(H)
    [rho_traj(i), ~, ~] = atmosferaISA(H(i));  % Atualiza densidade para cada altura
end

%% 7. Cálculo da velocidade indicada (CAS ≈ EAS ≈ TAS)
CAS = V .* sqrt(rho_traj / rho0);  % Calculando CAS com a densidade variável
% Fómula EAS slide 3 - aula velocidades

%% 8. Gráficos

% Altura vs Distância horizontal
figure
plot(x/1000, H)
xlabel('Distância horizontal [km]')
ylabel('Altura [m]')
title('Trajetória de planeio')
grid on

% Obs: altura da aeronave diminui com o tempo, 
% e a distância horizontal aumenta

% Velocidade verdadeira e indicada vs tempo
figure
plot(t, V, 'b', 'DisplayName', 'TAS (m/s)')
hold on
plot(t, CAS, 'r--', 'DisplayName', 'CAS (m/s)')
xlabel('Tempo [s]')
ylabel('Velocidade [m/s]')
legend
title('Velocidades ao longo do tempo')
grid on

% Obs: TAS se mantém constante (equilíbrio entre arrasto e sustentação)
% CAS está relacionada com a densidade do ar, 
% e se a aeronave perde altitude, a densidade do ar diminui, e CAS aumenta.

%% 9. Alcance e Autonomia com interp1

H_final_idx = find(H <= 0, 1);
if isempty(H_final_idx)
    H_final_idx = length(H);
end

alcance_km = interp1(H, x, 0, 'linear', 'extrap') / 1000;
autonomia_min = interp1(H, t, 0, 'linear', 'extrap') / 60;

fprintf('Alcance: %.2f km\n', alcance_km);
fprintf('Autonomia: %.2f minutos\n', autonomia_min);
