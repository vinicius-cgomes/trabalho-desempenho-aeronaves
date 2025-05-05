%Trabalho Final - Desempenho
%Parte 5 - Análise de Decolagem com Pista Balanceada
%Exercício 1: Cálculo do MTOW Limitado por BFL
%Slides 1 a 16 - Aula Desempenho em Pista

%% DADOS DA AERONAVE
m_ref = 33100;          % Massa de referência da aeronave [kg]
S = 88;                 % Área da asa [m²]
g = 9.81;               % Aceleração da gravidade [m/s²]
T_max = 55600;          % Tração máxima dos 2 motores ao nível do mar [N]

%% PARÂMETROS DE DECOLAGEM (BFL)
u_r = 0.02;             % Coeficiente de atrito de rolamento (pista seca)
u_b = 0.35;             % Coeficiente de atrito de frenagem (pista seca)
CL0 = 0.3;              % Coef. de sustentação inicial (flapes abaixados)
CL_max = 2.5;           % Coef. de sustentação máximo (flapes abaixados)
CD0 = 0.03;             % Coef. de arrasto parasita
k = 0.07;               % Coef. de arrasto induzido

%% CONDIÇÕES ATMOSFÉRICAS ISA
T_ISA = 15;             % Temperatura ISA ao nível do mar [°C]
T_vec = (T_ISA-10):5:(T_ISA+30);  % Vetor de temperaturas: de ISA-10°C a ISA+30°C, em passos de 5°C

%% PRÉ-ALOCAÇÃO DE VETORES DE RESULTADOS
MTOW = zeros(size(T_vec)); % Vetor para armazenar MTOW em cada temperatura [kg]
V1 = zeros(size(T_vec));   % Vetor para armazenar velocidades V1 [m/s]

%% LOOP PRINCIPAL
for i = 1:length(T_vec)
    T = T_vec(i);  % Temperatura atual do loop [°C]
    
    % ----- 1. Cálculo da densidade do ar (lei dos gases ideais) -----
    rho = 1.225 * (288.15 / (T + 273.15));  % [kg/m³] (15°C ISA → 288.15 K)
    
    % ----- 2. Tração disponível (modelo empírico) -----
    T_available = T_max * (rho/1.225)^0.6;  % Tração reduz com densidade
    
    % ----- 3. Chutes iniciais para MTOW e V1 -----
    MTOW_guess = 30000;  % Valor inicial estimado [kg]
    V1_guess = 50;       % Valor inicial estimado [m/s]
    
    % ----- 4. Iteração para encontrar MTOW e V1 que satisfazem BFL = 1500 m -----
    for iter = 1:1000  % Número máximo de iterações
        % --- 4.1 Cálculo da velocidade de estol e decolagem ---
        V_stall = sqrt(2 * MTOW_guess * g / (rho * S * CL_max));  % Velocidade de estol [m/s]
        V_LOF = 1.1 * V_stall;  % Velocidade de decolagem (10% acima do estol)
        
        % --- 4.2 Cálculo da distância de decolagem (TOD) com 1 motor inoperante ---
        T_OEI = 0.5 * T_available;  % Tração com 1 motor (OEI: One Engine Inoperative)
        
        % Forças durante o rolamento:
        CL_ground = CL0;  % Coef. de sustentação no solo
        CD_ground = CD0 + k * CL_ground^2;  % Coef. de arrasto no solo
        D_avg = 0.5 * rho * V_LOF^2 * S * CD_ground;  % Arrasto médio [N]
        L_avg = 0.5 * rho * V_LOF^2 * S * CL_ground;   % Sustentação média [N]
        F_avg = T_OEI - D_avg - u_r*(MTOW_guess*g - L_avg);  % Força resultante [N]
        a_avg = F_avg / MTOW_guess;  % Aceleração média [m/s²]
        TOD = V_LOF^2 / (2 * a_avg);  % Distância de decolagem [m]
        
        % --- 4.3 Cálculo da distância de abortagem (ASD) ---
        t_reaction = 2;  % Tempo de reação do piloto [s]
        d_reaction = V1_guess * t_reaction;  % Distância percorrida durante reação [m]
        a_brake = u_b * g;  % Desaceleração durante frenagem [m/s²]
        d_brake = V1_guess^2 / (2 * a_brake);  % Distância de frenagem [m]
        ASD = d_reaction + d_brake;  % Distância total de abortagem [m]
        
        % --- 4.4 Verificação do BFL ---
        BFL = max(TOD, ASD);  % Pista balanceada: BFL = maior entre TOD e ASD
        
        % Critério de parada: BFL ≈ 1500 m (tolerância de 10 cm)
        if abs(BFL - 1500) < 0.1
            break;
        end
        
        % --- 4.5 Ajuste de MTOW e V1 ---
        if BFL > 1500
            % Reduz MTOW e V1 se BFL está muito longo
            MTOW_guess = MTOW_guess * 0.998;
            V1_guess = V1_guess * 0.998;
        else
            % Aumenta MTOW e V1 se BFL está muito curto
            MTOW_guess = MTOW_guess * 1.002;
            V1_guess = V1_guess * 1.002;
        end
    end
    
    % ----- 5. Armazena resultados -----
    MTOW(i) = MTOW_guess;
    V1(i) = V1_guess;
    
    % Exibe resultados para a temperatura atual
    fprintf('T = %2d°C: MTOW = %6.1f kg (%.1f t) | V1 = %.1f m/s | Iter = %d\n', ...
            T, MTOW(i), MTOW(i)/1000, V1(i), iter);
end

%% Gráficos
figure;
plot(T_vec, MTOW/1000, 'bo-', 'LineWidth', 2);  % MTOW em toneladas
xlabel('Temperatura [°C]', 'FontSize', 12);
ylabel('MTOW [toneladas]', 'FontSize', 12);
title('MTOW Limitado por BFL = 1500 m', 'FontSize', 14);
grid on;

% Adiciona linhas de referência
hold on;
yline(33.1, '--r', 'MTOW Referência (33.1 t)');  % Linha de referência da massa nominal
legend('MTOW Calculado', 'Referência', 'Location', 'SouthWest');