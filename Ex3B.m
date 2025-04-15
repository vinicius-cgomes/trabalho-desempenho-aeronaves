%Trabalho Final - Desempenho
%Parte 2 - Envelope de voo em cruzeiro
%Exercício 3B: Comparação com Nível do Mar (SL) e FL450 (45000ft ou 13716m)

%% Modelo da Aeronave
m = 33100; %massa total (kg)
S = 88; %Área da asa (m^2)
CL_max = 2.0; %Coeficiente de sustentação máx. p/ flapes recolhidos
g = 9.81; %gravidade (m/s^2)

%% Cálculos dos demais dados
% Peso (N)
W = m * g;

% Densidade do ar para as 3 altitudes (kg/m³)
altitude = [0, 3048, 13716];% Nível do mar = 0; 10.000 ft = 3.048m e 45000ft = 13716m.
rho = 1.225 * exp(-altitude / 8500);
%confirmar rho, dito que achei a fórmula por pesquisa na internet kkkkkkkkk

% Arrasto parasita
CD0 = 0.015; %Para flapes Recolhidos: CD = CD0 + k(CL)^2 (p nossa aeronave: CD = 0.015 + 0.05CL^2)
%slide nº 6 (Aula: Envelopes de Voo)

% Coeficiente de arrasto induzido
k = 0.05; %Para flapes Recolhidos: CD = CD0 + k(CL)^2 (p nossa aeronave: CD = 0.015 + 0.05CL^2)
%slide nº 6 (Aula: Envelopes de Voo)

% Velocidades de teste (m/s)
V = 50:1:400; % Ampliada para cobrir FL450

%% Plot
% Cores para cada altitude
colors = ['r', 'g', 'b'];

figure; hold on;

%% Loop para cada altitude
for i = 1:length(altitudes)
    % Tração disponível (manete 100%)
    T_available = 2 * ( (rho(i)/1.225).^(0.6) * 55600 ); %slide nº 11 (Aula: Envelopes de Voo)
    
    % Tração requerida (Arrasto):

    % Coeficiente de sustentação (CL)
    CL = (2 * W) ./ (rho(i) .* S .* V.^2); %slide nº 5 (Aula: Envelopes de Voo)

    % Coeficiente de arrasto (CD)
    CD = CD0 + k * CL.^2; %slide nº 6 (Aula: Envelopes de Voo)

    % Tração requerida (Arrasto Parabólico)
    D = 0.5 * rho(i) * V.^2 * S .* CD; %slide nº 6 (Aula: Envelopes de Voo)
    
    % Plot das curvas
    plot(V, D, 'Color', colors(i), 'LineWidth', 2, ...
         'DisplayName', ['Tração Requerida em ' num2str(altitudes(i)/1000) ' km']);
    plot(V, T_available * ones(size(V)), '--', 'Color', colors(i), 'LineWidth', 2, ...
         'DisplayName', ['Tração Disponível em ' num2str(altitudes(i)/1000) ' km']);
    
    % Velocidade de estol
    V_stall = sqrt(2 * W / (rho(i) * S * CL_max)); %slide nº 16 (Aula: Envelopes de Voo)
    xline(V_stall, '--', 'Color', colors(i), 'HandleVisibility', 'off');
end

% Limite de velocidade máxima (Vmo)
Vmo = 890 / 3.6; % 890 km/h -> m/s
xline(Vmo, 'k--', 'LineWidth', 1.5, 'DisplayName', 'V_{mo}');

% Ajustes do gráfico
xlabel('Velocidade (m/s)');
ylabel('Tração/Arrasto (N)');
title('Tração vs. Velocidade em Diferentes Altitudes');
legend('Location', 'northeast');
grid on;