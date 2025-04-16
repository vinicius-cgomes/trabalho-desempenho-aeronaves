%Trabalho Final - Desempenho
%Parte 2 - Envelope de voo em cruzeiro
%Exercício 3A: Curvas de tração disponível e requerida

%% Modelo da Aeronave
m = 33100; %massa total (kg)
S = 88; %Área da asa (m^2)
CL_max = 2.0; %Coeficiente de sustentação máx. p/ flapes recolhidos
g = 9.81; %gravidade (m/s^2)

%% Cálculos dos demais dados
% Peso (N)
W = m * g;

% Densidade do ar em 3048m (kg/m³)
altitude = 3048;     % 10.000 ft = 3.048 m
rho = 1.225 * exp(-altitude / 8500);
%8500m é uma altitude de escala derivada das propriedades físicas da atmosfera. Representa a altitude onde a densidade cai aproximadamente p/ 36.8% do valor ao nível do mar. Usada para simplificar cálculos de densidade em engenharia aeronáutica.
%confirmar rho, dito que achei por pesquisa na internet kkkkkkkkk

% Arrasto parasita
CD0 = 0.015; %Para flapes Recolhidos: CD = CD0 + k(CL)^2 (p nossa aeronave: CD = 0.015 + 0.05CL^2)
%slide nº 6 (Aula: Envelopes de Voo)

% Coeficiente de arrasto induzido
k = 0.05; %Para flapes Recolhidos: CD = CD0 + k(CL)^2 (p nossa aeronave: CD = 0.015 + 0.05CL^2)
%slide nº 6 (Aula: Envelopes de Voo)

%% Curvas de tração disponível e requerida:

% Velocidades de teste (m/s)
V = 50:1:300; %arbitrário, escolhi a partir do valor máx ISA de 890 km/h ~ 247 m/s

% Coeficiente de sustentação (CL)
CL = (2 * W) ./ (rho * S * V.^2); %slide nº 5 (Aula: Envelopes de Voo)

% Coeficiente de arrasto (CD)
CD = CD0 + k * CL.^2; %slide nº 6 (Aula: Envelopes de Voo)

% Tração requerida (Arrasto Parabólico)
D = 0.5 * rho * V.^2 * S .* CD; %slide nº 6 (Aula: Envelopes de Voo)

% Tração disponível (manete 100%)
T_available = ( (rho/1.225)^0.6 * 55600 ); %slide nº 11 (Aula: Envelopes de Voo)

% Velocidade de estol
V_stall = sqrt(2 * W / (rho * S * CL_max)); %slide nº 16 (Aula: Envelopes de Voo)

% Limite estrutural (Vmo)
Vmo = 890 / 3.6; % 890 km/h -> m/s  %slide nº 16 (Aula: Envelopes de Voo)


%% Plot
figure;
plot(V, D, 'b-', 'LineWidth', 2); hold on;
plot(V, T_available * ones(size(V)), 'r-', 'LineWidth', 2);
xline(V_stall, 'k--', 'V_{stall}');
xline(Vmo, 'g--', 'V_{mo}');
xlabel('Velocidade (m/s)');
ylabel('Tração (N)');
legend('Tração Requerida (Arrasto)', 'Tração Disponível', ...
       'V_{stall}', 'V_{mo}');
title('Tração vs. Velocidade em 10.000 ft');
grid on;
