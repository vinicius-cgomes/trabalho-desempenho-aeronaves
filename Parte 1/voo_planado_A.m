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
[rho, T, p] = atmosferaISA(H0);  

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

%% 6. Cálculo da velocidade indicada (CAS ≈ EAS ≈ TAS)
CAS = V .* sqrt(rho / rho0);  % como f = 1 e erro de posição nulo

%% 7. Gráficos

% Altura vs Distância horizontal
figure
plot(x/1000, H)
xlabel('Distância horizontal [km]')
ylabel('Altura [m]')
title('Trajetória de planeio')
grid on

% Velocidade verdadeira e indicada vs tempo
% !!!!!!!!!!! PRECISA CONFERIR !!!!!!!!!!!
figure
plot(t, V, 'b', 'DisplayName', 'TAS (m/s)')
hold on
plot(t, CAS, 'r--', 'DisplayName', 'CAS (m/s)')
xlabel('Tempo [s]')
ylabel('Velocidade [m/s]')
legend
title('Velocidades ao longo do tempo')
grid on

%% 8. Alcance e Autonomia com interp1

H_final_idx = find(H <= 0, 1);
if isempty(H_final_idx)
    H_final_idx = length(H);
end

alcance_km = interp1(H, x, 0, 'linear', 'extrap') / 1000;
autonomia_min = interp1(H, t, 0, 'linear', 'extrap') / 60;

fprintf('Alcance: %.2f km\n', alcance_km);
fprintf('Autonomia: %.2f minutos\n', autonomia_min);
