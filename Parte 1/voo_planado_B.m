% =====================================
% Exercício 2 - Parte B - Isa S. 23/04
% =====================================
clc; clear; close all;

% Dados da aeronave
g = 9.80665;                         
S = 88;                          
CD0 = 0.015;                    
k = 0.05;                        
m = 33100;                       

% Condições iniciais e atmosfera ISA
x0 = 0;
H0 = 10000;                                 
[~, ~, ~, rho] = atmosisa(H0);   

% Condições de voo (CL)
CL_values = linspace(0, 2.5, 10);  % Usado para a tabela
CL_fino = linspace(0, 2.5, 100);  % Usado para o gráfico
results = [];

% Calcular os resultados para cada CL (usando CL_fino para gráfico)
for i = 1:length(CL_values)
    CL = CL_values(i);
    CD = CD0 + k * CL^2;
    E = CL / CD;

    % Velocidade inicial
    V0 = sqrt((2 * m * g) / (rho * S) * (1 / sqrt(CL^2 + CD^2))); 

    % Ângulo de trajetória
    gamma0 = -atan(1 / E);            
    gamma0_deg = rad2deg(gamma0);     

    % Vetor de estado inicial
    Y0 = [V0; gamma0; H0; x0];        

    % Definição da função dinâmica
    f = @(t, Y) voo_planado(t, Y, S, CL, CD, m, g);  

    % Evento: parar quando altura chegar a zero
    opts = odeset('Events', @evento_altura_zero);

    % Resolver ODE
    [t, Y] = ode45(f, [0 2000], Y0, opts);

    % Extrair variáveis
    V = Y(:,1);     
    gamma = Y(:,2); 
    H = Y(:,3);     
    x = Y(:,4);

    % Cálculo do alcance e autonomia
    autonomia_s = interp1(H, t, 0);              
    autonomia_min = autonomia_s / 60;           
    alcance_km = interp1(t, x, autonomia_s) / 1000;

    % Armazenar resultados
    results(i,:) = [CL, E, V0, gamma0_deg, alcance_km, autonomia_min];
end

% Mostrar tabela no console
disp('Tabela - Parte B')
disp('   #     CL      E        V_inicial[m/s]  gamma_inicial[°]  Alcance[km]  Autonomia[min]')
for i = 1:size(results,1)
    fprintf('%3d   %6.3f   %6.2f     %10.2f      %10.2f      %10.2f     %10.2f\n', ...
        i, results(i,1), results(i,2), results(i,3), results(i,4), results(i,5), results(i,6));
end

% Calcular CL de máximo alcance e máximo autonomia
[max_alcance, idx_alcance] = max(results(:,5));
CL_max_alcance = results(idx_alcance, 1);  % CL correspondente ao máximo alcance
disp('   ');
disp(['CL de Máximo Alcance: ', num2str(CL_max_alcance)]);
disp(['Alcance Máximo: ', num2str(max_alcance), ' km']);

% Encontrar o CL de máxima autonomia
[max_autonomia, idx_autonomia] = max(results(:,6));
CL_max_autonomia = results(idx_autonomia, 1);  % CL correspondente à máxima autonomia
disp('  ');
disp(['CL de Máxima Autonomia: ', num2str(CL_max_autonomia)]);
disp(['Autonomia Máxima: ', num2str(max_autonomia), ' min']);

% Separar vetores para gráficos
CLs = results(:,1);
alcances = results(:,5);
autonomias = results(:,6);
gammas = results(:,4);
V0s = results(:,3);

% Calcular resultados para o gráfico usando CL_fino (mais pontos)
alcances_fino = zeros(length(CL_fino), 1);
autonomias_fino = zeros(length(CL_fino), 1);
gammas_fino = zeros(length(CL_fino), 1);
V0s_fino = zeros(length(CL_fino), 1);

for i = 1:length(CL_fino)
    CL = CL_fino(i);
    CD = CD0 + k * CL^2;
    E = CL / CD;

    % Velocidade inicial
    V0 = sqrt((2 * m * g) / (rho * S) * (1 / sqrt(CL^2 + CD^2))); 

    % Ângulo de trajetória
    gamma0 = -atan(1 / E);            
    gamma0_deg = rad2deg(gamma0);     

    % Vetor de estado inicial
    Y0 = [V0; gamma0; H0; x0];        

    % Definição da função dinâmica
    f = @(t, Y) voo_planado(t, Y, S, CL, CD, m, g);  

    % Evento: parar quando altura chegar a zero
    opts = odeset('Events', @evento_altura_zero);

    % Resolver ODE
    [t, Y] = ode45(f, [0 2000], Y0, opts);

    % Extrair variáveis
    V = Y(:,1);     
    gamma = Y(:,2); 
    H = Y(:,3);     
    x = Y(:,4);

    % Cálculo do alcance e autonomia
    autonomia_s = interp1(H, t, 0);              
    autonomia_min = autonomia_s / 60;           
    alcance_km = interp1(t, x, autonomia_s) / 1000;

    % Armazenar resultados para o gráfico
    alcances_fino(i) = alcance_km;
    autonomias_fino(i) = autonomia_min;
    gammas_fino(i) = gamma0_deg;
    V0s_fino(i) = V0;
end

% Gráficos
figure;

subplot(2,2,1);
plot(CL_fino, alcances_fino, '-');
hold on;
plot(CL_max_alcance, max_alcance, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
title('Alcance vs CL');
xlabel('CL');
ylabel('Alcance (km)');
legend('Alcance', 'Máximo Alcance', 'Location', 'best');

subplot(2,2,2);
plot(CL_fino, autonomias_fino, '-');
hold on;
plot(CL_max_autonomia, max_autonomia, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
title('Autonomia vs CL');
xlabel('CL');
ylabel('Autonomia (min)');
legend('Autonomia', 'Máxima Autonomia', 'Location', 'best');

subplot(2,2,3);
plot(CL_fino, gammas_fino, '-');
title('Gamma Inicial vs CL');
xlabel('CL');
ylabel('Gamma Inicial (°)');

subplot(2,2,4);
plot(CL_fino, V0s_fino, '-');
title('Velocidade Inicial vs CL');
xlabel('CL');
ylabel('Velocidade Inicial (m/s)');

sgtitle('Análise do Voo Planado');
