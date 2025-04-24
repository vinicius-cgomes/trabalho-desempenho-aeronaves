% ====================================
% Exercício 2 - Parte A - Isa S. 23/04
% ====================================

clear; clc; close all

% Parâmetros da aeronave e constantes físicas
g = 9.80665;                   
m = 33100;                  
S = 88;                     
CD0 = 0.015;                
k = 0.05;                   
CL_max = 2.0;              
CL_min = -1.0;          
rho0 = 1.225;              

% Condições iniciais e atmosfera ISA
H0 = 10000;                                 
[~, ~, ~, rho_atual] = atmosisa(H0);       

% Coeficientes aerodinâmicos e eficiência
CL = sqrt(CD0/k);           
CD = CD0 + k * CL^2;        
E = CL / CD;                

% Condições iniciais de voo
V0 = sqrt((2 * m * g) / (rho_atual * S) * (1 / sqrt(CL^2 + CD^2)));  
fprintf('V0 = %.2f m/s\n', V0);
gamma0 = -atan(1 / E);        
Y0 = [V0; gamma0; H0; 0];    

% Definição da função dinâmica
f = @(t, Y) voo_planado(t, Y, S, CL, CD, m, g);  

% Intervalo de tempo para simulação
tspan = [0 2000];  

% Simulação com ODE45
[t, Y] = ode45(f, tspan, Y0);  

% Resultados
V = Y(:,1);     
gamma = Y(:,2); 
H = Y(:,3);     
x = Y(:,4);     

% Cálculo das velocidades 
[~,~,~,rho_traj] = atmosisa(Y(:,3));  
TAS = V;                          
EAS = TAS ./ sqrt(rho0 ./ rho_traj);   
CAS = EAS;                             
IAS = CAS;                             

% Gráficos
figure;  

subplot(1,2,1);
plot(x/1000, H);  
xlabel('Distância [km]');
ylabel('Altura [m]');
title('Trajetória');
grid on;
ylim([0, 10000]);
xticks(0:20:300);

subplot(1,2,2);
plot(t, TAS, 'r-', 'LineWidth', 1.2); hold on;  
plot(t, EAS, 'b--', 'LineWidth', 1.2);  
plot(t, CAS, 'g-.', 'LineWidth', 1.2);  
plot(t, IAS, 'm:', 'LineWidth', 1.2);   
xlabel('Tempo [s]');
ylabel('Velocidade [m/s]');
legend('TAS', 'EAS', 'CAS', 'IAS');
title('Velocidades');
grid on;

figure;
plot(t, H);  
xlabel('Tempo [s]');
ylabel('Altura [m]');
title('Altura vs Tempo');
grid on;
ylim([0, 10000]);
xticks(0:300:1600);

% Cálculo do alcance e autonomia
H_final_idx = find(H <= 0, 1);
if isempty(H_final_idx)
    H_final_idx = length(H);
end

autonomia_s = interp1(H, t, 0);              
autonomia_min = autonomia_s / 60;           
alcance_km = interp1(t, x, autonomia_s) / 1000;  

fprintf('\nAlcance: %.2f km\n', alcance_km);
fprintf('Autonomia: %.2f minutos\n', autonomia_min);
fprintf('------------------------------------\n');

% Verificação 
alcance_teorico_km = E * H0 / 1000;  % Alcance teórico em km
fprintf('Alcance teórico: %.2f km\n', alcance_teorico_km);

% Cálculo de erro percentual para o alcance
erro_alcance = abs(alcance_teorico_km - alcance_km) / alcance_teorico_km * 100;
fprintf('Erro percentual alcance: %.2f %%\n', erro_alcance);

Vz = V .* sin(gamma);                 
Vz_media = mean(-Vz);                
autonomia_teorica_s = H0 / Vz_media; 
autonomia_teorica_min = autonomia_teorica_s / 60; % Conversão para minutos

fprintf('Autonomia teórica: %.2f minutos\n', autonomia_teorica_min);

% Cálculo de erro percentual para a autonomia
erro_autonomia = abs(autonomia_teorica_min - autonomia_min) / autonomia_teorica_min * 100;
fprintf('Erro percentual autonomia: %.2f %%\n', erro_autonomia);
