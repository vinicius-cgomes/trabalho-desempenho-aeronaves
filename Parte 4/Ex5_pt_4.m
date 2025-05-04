% Trabalho Final - Desempenho
% Parte 4 - Cálculo de alcance e consumo de combustível
% Exercício 5: Análise de Missão com MTOW Fixo

close all

% ============ Dados do problema ============

% Modelo da aeronave

MTOW = 33100; % Peso máximo de decolagem [kg]
OEW = 16400; % Peso operacional vazio [kg]

fuelMax = 12700; % Capacidade máxima de combustível [kg]
fuelTaxi = 150; % Massa para taxeamento [kg]
fuelTaxiOut = 75; % Massa usada antes de decolar [kg]
fuelReserva = 1200; % Combustível reserva [kg]

CD0 = 0.015;
k = 0.05;
CL_Emax = sqrt(CD0/k); % CL na máxima eficiência aerodinâmica
CLCDmax = 1/(2*sqrt(k*CD0)); % Máxima eficiência aerodinâmica
CD_Emax = CD0 + k*CL_Emax^2; % CD na máxima eficiência aerodinâmica sem flaps estendidos
S = 88; % Area da asa [m²]

Hcruise = 10668; % Altitude de cruzeiro [m].
Havg = Hcruise/2; % Altitude média [m].
[~,~,~,rhoCruise,~,~] = atmosisa(Hcruise); 
[~,~,~,rhoAvg,~,~] = atmosisa(Havg); 
[~,~,~,rho0,~,~] = atmosisa(0);
g = 9.8; % Gravidade [m/s²] 

deltaT = 1; % Posição da manete
Tmax_SL = 55600; % Tração máxima [N]; AEO; manete = 100%
Tavg = deltaT * Tmax_SL * (rhoAvg/rho0)^0.6; % Modelo de tração; Considerar rhoAvg (mas na prática, rho varia com H)
TSFC = 0.7/3600; % Consumo específico TSFC [1/s]

% ============ Estimativas de Subida ============
% Subida: SL a FL350

gamaClimb = atan(0.05); % Gradiente de subida [rad]

% Determinar fuelClimb (combustível gasto na subida) iterativamente

startClimb = MTOW - fuelTaxi; % Massa total no início da subida [kg]
fuelClimb = 0; % Chute inicial [kg]
difVector = 0; % Vetor com as diferenças entre as iterações de fuelClimb

N = 100; % Número máximo de iterações; pode ser alterado conforme necessidade
for i=1:N
    climbAvg = startClimb - fuelClimb(end)/2; % Massa média da subida [kg]
    W_climbAvg = g*climbAvg; % Peso médio de subida [N]
    vClimb = sqrt((2*W_climbAvg*cos(gamaClimb))/(rhoAvg*CL_Emax*S)); % Velocidade de subida [m/s]0
    D = 0.5*rhoAvg*S*CD_Emax*vClimb^2; % Arrasto médio [N]
    T_req = D + W_climbAvg*sin(gamaClimb); % Tração requerida [N]
    timeClimb = Hcruise/(vClimb*sin(gamaClimb)); % Tempo de subida [s]
    W_fuelClimb_i = TSFC*T_req*timeClimb; % Peso do combustível consumido na subida calculado para a i-ésima iteração [N]
    fuelClimb_i = W_fuelClimb_i/g; % Massa do combustível consumido na subida calculado para a i-ésima iteração [kg]
    fuelClimb = [fuelClimb, fuelClimb_i];
    dif = fuelClimb(end-1) - fuelClimb(end);
    difVector = [difVector, dif];
    N_i = i; % Número de iterações que foram necessárias
    if abs(dif) < 0.005
        break
    end
end

figure(1);
set(gcf, 'Position', [100 100 800 400]); % [left bottom width height]
sgtitle('Gráfico de convergência do combustível gasto na subida'); % Figure title

subplot(1,2,1)
plot(0:N_i, fuelClimb, 'o-')
grid()
title('fuel_{Climb}');
xlabel('Iteração');
ylabel('fuel_{Climb} (kg)');

subplot(1,2,2)
plot(0:N_i, difVector, 'o-r')
grid()
title('Diferença entre iterações');
xlabel('Iteração');
ylabel('fuel_{Climb}^{(i-1)} - fuel_{Climb}^{(i)} (kg)');
exportgraphics(figure(1), 'fuelClimb.pdf')

% Calcular a distância de subida na direção x com timeClimb e V_climb convergida
xClimb = vClimb*cos(gamaClimb)*timeClimb; % [m]

% ============ Estimativas de Descida ============

gamaDesc = deg2rad(-3); % [rad]
xDesc = Hcruise/abs(tan(gamaDesc)); % valor parece alto [m]
xDesc_NM = xDesc/1852;
% Assumir consumo de combustível fixo para a descida
fuelDesc = 150; % [kg]

% ============ Tarefa: Análise das Missões ============

x1_NM = 500;  % Missão 1 [NM]
x2_NM = 1500; % Missão 2 [NM]
x3_NM = 3000; % Missão 3 [NM]

xTotal_NM = [x1_NM, x2_NM, x3_NM];
xClimb_NM = xClimb/1852; 
xDesc_NM = xDesc/1852; 
xCruise_NM = [];

startCruise = MTOW - fuelTaxiOut - fuelClimb(end); % Massa total no início do cruzeiro [kg]
W_startCruise = g*startCruise; % Peso no início do cruzeiro

% Avaliar a viabilidade das missões do ponto de vista de distância
% percorrida, com base nas distâncias necessárias para subida e descida.
% Por ex, não seria possível caso a distância que deseja-se percorrer seja
% menor do que a soma da subida e descida; a subida e descida é o mínimo
% que avião precisa andar.

fprintf("Avaliando a viabilidade da missão de acordo com a distância total: \n")
for i=1:3 
    xCruise_NM_i = xTotal_NM(i) - xClimb_NM - xDesc_NM; 
    xCruise_NM = [xCruise_NM,xCruise_NM_i];
    if xCruise_NM_i >= 0
        fprintf('A missão %d é possível ', i) 
        fprintf('para a distância total %d', xTotal_NM(i))
        fprintf(' NM \n')
    end
    if xCruise_NM_i < 0
        fprintf('A missão %d NÃO é possível', i) 
        fprintf('para a distância total %d', xTotal_NM(i))
        fprintf(' NM \n')
    end
end

% Calcular a velocidade de cruzeiro

% Transformar de NM para m
xCruise = xCruise_NM*1852;

vCruiseAvg = [0, 0, 0]; % Velocidade média de cruzeiro [m/s]
fuelCruise = [0, 0, 0]; % Combustível gasto em cruzeiro [kg]

color = ["b", "r", "g"];
legendPosition = [0.4, 0.15, 0.1, 0.1]; % [x, y, width, height]

% figure(2)
for i=1:3
    % Criar os vetores de tempo, velocidade e deslocamento
    t = 0; % Tempo no início do cruzeiro 
    vCruise = sqrt((startCruise*g)/(0.5*rhoAvg*S*CL_Emax)); % Velocidade no início do cruzeiro
    xCruiseVector = 0; % Deslocamento no início do cruzeiro. Será completado de acordo com i no loop abaixo
    timeStep = 1*60; % Time step; a cada minuto recalcula a velocidade de cruzeiro
    
    n = 0;
    xCruise_n = 0; % Inicializar a variável
    % fprintf("começou \n")

    while xCruise_n < xCruise(i) % Enquanto a distância instantânea de cruzeiro for menor que a distância de cruzeiro calculada
        n = n+1;
        % Incremento de tempo:
        t_n = t(end) + timeStep;
        t = [t, t_n]; % append o último t calculado no vetor de tempos
    
        % Recalcular a velocidade de cruzeiro
        vCruise_n = sqrt((startCruise*g)/(0.5*rhoCruise*S*(CL_Emax + TSFC*CD_Emax*n*timeStep)));
        vCruise = [vCruise, vCruise_n];
        
        % Recalcular a distância percorrida em cruzeiro
        xCruise_n = vCruise_n*timeStep*n;
        xCruiseVector = [xCruiseVector, xCruise_n];
    end

    % Calcular a velocidade média de cruzeiro

    vCruiseAvg(i) = mean(vCruise(2:end)); % Velocidade média de cruzeiro

    subplot(3,1,i)
    plot(t/(60*60),vCruise, "color",color(i), 'linewidth',1)
    hold on
    plot(t/(60*60),repmat(vCruiseAvg(i), size(t)), "color","k", 'linewidth',1)
    grid()
    xlabel('Tempo (h)');
    ylabel('V_{Cruise} (m/s)');
    title(strcat('Velocidade de cruzeiro para a missão de ', " ", num2str(xTotal_NM(i)), " NM"));
    legend('Velocidade de em função do tempo', 'Velocidade média', 'Location', 'south');
    ylim([130 190])
    exportgraphics(figure(i+1), strcat('vCruise_',num2str(xTotal_NM(i)), "NM.pdf"));

    % Calcular o combustível de cruzeiro.
    % Simplificação adotada: estamos considerando a velocidade média de
    % cruzeiro para calcular o combustível gasto.

    W_endCruise = W_startCruise * exp(-xCruise(i)*TSFC/(vCruiseAvg(i)*CLCDmax)); % Peso do avião no final do cruzeiro [N]
    fuelCruise(i) = (W_startCruise - W_endCruise)/g; % Massa de combustível gasta em cruzeiro, em média

end

% set(gcf, 'Position', [0 0 900 800]) % posx, posy, Width, Height
% exportgraphics(gcf, 'combined_vCruise_plots.pdf');

% Cálculo do combustível total e payload

fuelTrip = fuelClimb(end) + fuelCruise + fuelDesc; % Combustível gasto na viagem [kg]
fuelTotal = fuelTrip + fuelReserva + fuelTaxi; % Combustível total requerido para a missão [kg]
ZFW = MTOW - fuelTotal; % Peso zero combustível resultante [kg]
payload = ZFW-OEW; % Carga paga (payload) [kg]

fprintf("\nAvaliando a viabilidade de acordo com a capacidade de combustíbvel: \n")
for i=1:3
    if fuelTotal(i) <= fuelMax
        fprintf('A missão %d ', i) 
        fprintf('de %d', xTotal_NM(i))
        fprintf(' NM é possível\n')
    end
    if fuelTotal(i) > fuelMax
        fprintf('A missão %d ', i) 
        fprintf('de %d', xTotal_NM(i))
        fprintf(' NM NÃO é possível\n')
    end
end

fprintf("\nAvaliando se a aeronave é capaz de carregar pelo menos seu próprio peso com combustível (payload > 0): \n")
for i=1:3
    if payload(i) >= 0
        fprintf('A missão %d ', i) 
        fprintf('de %d', xTotal_NM(i))
        fprintf(' NM tem payload positiva\n')
    end
    if payload(i) < 0
        fprintf('A missão %d ', i) 
        fprintf('de %d', xTotal_NM(i))
        fprintf(' NM tem payload negativa, ou seja, não é capaz de carregar seu próprio peso com combustível\n')
    end
end

% Análise de consumo
% Calcular o percentual de combustível gasto em cada etapa

fuelTaxiOut_pct = fuelTaxiOut./fuelTotal;
fuelClimb_pct = fuelClimb(end)./fuelTotal;
fuelCruise_pct = fuelCruise./fuelTotal;
fuelDesc_pct = fuelDesc./fuelTotal;
fuelTaxiLnd_pct = (fuelTaxi - fuelTaxiOut)./fuelTotal;
fuelReserva_pct = fuelReserva./fuelTotal;

%% Gráficos finais

figure(4);

plot(xTotal_NM, fuelTotal, "o-", "color", color(1), "linewidth",1)
hold on
plot(xTotal_NM, payload, "o-", "color", color(2), "linewidth",1)
grid()
legend('Combustível Total Requerido', 'Payload', 'Location', 'best');
title('Comparação entre combustível requerido e payload');
xlabel('Distância Total da Missão (NM)');
ylabel('Massa (kg)');
exportgraphics(figure(4), 'pesos.pdf')

%% Gráfico comparando o precentual gasto em cada etapa por cada missão

fuelData = [fuelTaxiOut_pct; fuelClimb_pct; fuelCruise_pct; fuelDesc_pct; fuelTaxiLnd_pct; fuelReserva_pct];
x=1:6;

figure(5);
h = bar(x,[100*fuelData(:,1),100*fuelData(:,2),100*fuelData(:,3)]);
set(h(1),'facecolor',color(1))
set(h(2),'facecolor',color(2))
set(h(3),'facecolor',color(3))
title('Percentual de combustível gasto por etapa');
xlabel('Etapa de Voo');
ylabel('Percentual de combustível consumido');
grid()

xticklabels({'Táxi Decolagem', 'Subida', 'Cruzeiro', 'Descida', 'Táxi Pouso', 'Reserva'});
xticks(1:6);  % Posicionalmento dos labels

legend('500 NM', '1500 NM', '3000 NM', 'Location', 'best');
exportgraphics(figure(5), 'percentualCombGasto.pdf')