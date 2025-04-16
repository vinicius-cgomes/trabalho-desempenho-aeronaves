% Trabalho Final - Desempenho
% Parte 4 - Cálculo de alcance e consumo de combustível
% Exercício 5: Análise de Missão com MTOW Fixo

% Dados do enunciado

% Massas:
MTOW = 33100; % Peso máximo de decolagem [kg]
m_f_max = 12700; % Capacidade máxima de combustível [kg]
OEW = 16400; % Peso operacional vazio [kg]

% Coef. aerodinâmicos:
CD0 = 0.015;
k = 0.05;
CD_noFlap = CD0 + k*CL^2;

% Parâmetros construtivos do avião
S = 88; % Area da asa [m²]

% Combustível
ct = 0.7/3600; % Consumo específico TSFC [1/s]
Tmax = 55600; % Tração máxima [N]