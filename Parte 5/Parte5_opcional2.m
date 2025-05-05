%Trabalho Final - Desempenho
%Parte 5 - Análise de Decolagem com Pista Balanceada
%Exercício Opcional 2: BFL vs AEO
%Slides 1 a 16 - Aula Desempenho em Pista

%% DADOS DA AERONAVE
m_ref    = 33100;         % Massa de referência [kg]
S        = 88;            % Área da asa [m²]
g        = 9.81;          % Gravidade [m/s²]
T_max    = 55600;         % Tração total ao nível do mar [N]

%% PARÂMETROS DE DECOLAGEM
u_r      = 0.02;          % Coef. de atrito rolamento
u_b      = 0.35;          % Coef. de atrito frenagem
CL0      = 0.3;           % CL no solo (flaps)
CL_max   = 2.5;           % CL máximo (flaps)
CD0      = 0.03;          % Cd parasita
k        = 0.07;          % Cd induzido

%% CONDIÇÕES ATMOSFÉRICAS (ISA–10 a ISA+30)
T_ISA    = 15;                                    % ISA ao nível [°C]
T_vec    = (T_ISA-10):5:(T_ISA+30);               % –10…+30 ISA em 5°C

%% PRÉ-ALOCAR VETORES
nT        = numel(T_vec);
MTOW_BFL  = zeros(1,nT);
V1_vec    = zeros(1,nT);
MTOW_AEO  = zeros(1,nT);

%% LOOP POR TEMPERATURA
for i = 1:nT
    T = T_vec(i);
    rho = 1.225 * (288.15/(T+273.15));           % densidade [kg/m³]
    T_avail = T_max * (rho/1.225)^0.6;            % tração ajustada
    
    % ===== 1) MTOW limitado por BFL =====
    MTOWg = 30000;    % chute inicial [kg]
    V1g   = 50;       % chute inicial [m/s]
    for it = 1:1000
        V_stall = sqrt(2*MTOWg*g/(rho*S*CL_max));
        V_LOF   = 1.1 * V_stall;
        
        % empuxo com um motor inop.
        T_OEI   = 0.5 * T_avail;
        
        % arrasto & sustentação no solo
        CL_gr   = CL0;
        CD_gr   = CD0 + k*CL_gr^2;
        D_avg   = 0.5*rho*V_LOF^2*S*CD_gr;
        L_avg   = 0.5*rho*V_LOF^2*S*CL_gr;
        
        % aceleração média OEI e TOD OEI
        F_net   = T_OEI - D_avg - u_r*(MTOWg*g - L_avg);
        a_avg   = F_net / MTOWg;
        TOD_OEI = V_LOF^2/(2*a_avg);
        
        % abortagem
        t_react = 2;
        d_react = V1g * t_react;
        a_brake = u_b * g;
        d_brake = V1g^2/(2*a_brake);
        ASD     = d_react + d_brake;
        
        BFL = max(TOD_OEI, ASD);
        if abs(BFL-1500)<0.1; break; end
        
        % ajustar chute
        if BFL>1500
            MTOWg = MTOWg * 0.998;
            V1g   = V1g   * 0.998;
        else
            MTOWg = MTOWg * 1.002;
            V1g   = V1g   * 1.002;
        end
    end
    MTOW_BFL(i) = MTOWg;
    V1_vec(i)   = V1g;
    
    % ===== 2) MTOW limitado por AEO =====
    MTOWg = 30000;  % novo chute
    for it = 1:1000
        V_stall = sqrt(2*MTOWg*g/(rho*S*CL_max));
        V_LOF   = 1.1 * V_stall;
        
        % aceleração AEO
        D_avg   = 0.5*rho*V_LOF^2*S*(CD0 + k*CL0^2);
        L_avg   = 0.5*rho*V_LOF^2*S*CL0;
        F_net   = T_avail - D_avg - u_r*(MTOWg*g - L_avg);
        a_avg   = F_net / MTOWg;
        TOD_AEO = V_LOF^2/(2*a_avg);
        
        if abs(TOD_AEO-1500)<0.1; break; end
        
        if TOD_AEO>1500
            MTOWg = MTOWg * 0.998;
        else
            MTOWg = MTOWg * 1.002;
        end
    end
    MTOW_AEO(i) = min(MTOWg, m_ref);  % clip no MTOW certificado
end

%% PLOT FINAL
figure; hold on;
plot(T_vec, MTOW_BFL/1000, 'b-o', 'LineWidth',1.8);
plot(T_vec, MTOW_AEO/1000, 'g--s', 'LineWidth',1.8);
yline(m_ref/1000,'r--','MTOW_{ref} = 33.1 t','LineWidth',1.5);
xlabel('Temperatura [°C]','FontSize',12);
ylabel('MTOW [t]','FontSize',12);
title('MTOW limitado por BFL (OEI) vs AEO','FontSize',14);
legend('MTOW BFL (OEI)','MTOW AEO (todos motores)','MTOW_{ref}','Location','SouthWest');
grid on;
