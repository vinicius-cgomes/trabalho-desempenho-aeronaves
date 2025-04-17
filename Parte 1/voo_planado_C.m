% ==================================================
% Simulação de voo planado - Parte C (ISA + 20°C)
% ==================================================
clc; clear;

%% Dados da aeronave
g = 9.8;                        
S = 88;                         
CD0 = 0.015;                    
k = 0.05;                       
m = 33100;                      
H0 = 10000;                     
x0 = 0;                         
rho = 1.225 * exp(-(H0 - 0) / 8000) * (1 - 0.0065*20/288.15); % ISA + 20°C (mudança na densidade)

%% Condições de voo (CL)
CL_values = linspace(0, 2.5, 10);  
results = [];

for i = 1:length(CL_values)
    CL = CL_values(i);
    CD = CD0 + k * CL^2;
    E = CL / CD;

    % Velocidade inicial
    V0 = sqrt((2*m*g)/(rho*S)) * 1/(CL^2+CD^2)^(1/4); 

    % Ângulo de trajetória
    gamma0 = -atan(1 / E);            
    gamma0_deg = rad2deg(gamma0);     

    y0 = [V0; gamma0; H0; x0];        

    % Equações diferenciais do voo planado
    f = @(t, y) [
        -(0.5 * rho * y(1)^2 * S * CD) / m - g * sin(y(2));           
        (0.5 * rho * y(1)^2 * S * CL - m * g * cos(y(2))) / (m*y(1)); 
        y(1) * sin(y(2));                                             
        y(1) * cos(y(2))                                              
    ];

    % Resolver ODE
    opts = odeset('Events', @evento_altura_zero);
    [t, y] = ode45(f, [0 10000], y0, opts);

    alcance_km = y(end, 4) / 1000;
    autonomia_min = t(end) / 60;

    results = [results;
        i, CL, E, V0, gamma0_deg, alcance_km, autonomia_min];
end

%% Exibir resultados
disp('Tabela - Parte B')
disp('   #     CL      E        V_inicial[m/s]  gamma_inicial[°]  Alcance[km]  Autonomia[min]')
fprintf('%3d   %6.3f   %6.2f     %10.2f      %10.2f      %10.2f     %10.2f\n', results')

%% Gerar gráficos para comparação
figure;

% Gráfico de Alcance vs CL
subplot(2,2,1);
plot(results(:,2), results(:,6), '-o');
title('Alcance vs CL (ISA + 20°C)');
xlabel('CL');
ylabel('Alcance (km)');

% Gráfico de Autonomia vs CL
subplot(2,2,2);
plot(results(:,2), results(:,7), '-o');
title('Autonomia vs CL (ISA + 20°C)');
xlabel('CL');
ylabel('Autonomia (min)');

% Gráfico de Gamma Inicial vs CL
subplot(2,2,3);
plot(results(:,2), results(:,5), '-o');
title('Gamma Inicial vs CL (ISA + 20°C)');
xlabel('CL');
ylabel('Gamma Inicial (°)');

% Gráfico de Velocidade Inicial vs CL
subplot(2,2,4);
plot(results(:,2), results(:,4), '-o');
title('Velocidade Inicial vs CL (ISA + 20°C)');
xlabel('CL');
ylabel('Velocidade Inicial (m/s)');

% Ajuste nos gráficos
sgtitle('Análise do Voo Planado - ISA + 20°C');
