% Exercicio 5-c
% Parte 3
ResultadosAEO = Ex5afunc();
ResultadosOEI = Ex5bfunc();

figure; hold on;

% Plot
plot(Tlinha - 288.15, ResultadosAEO(:,5)', 'LineWidth', 2.5, 'Color', 'r');
plot(Tlinha - 288.15, ResultadosOEI(:,5)', 'LineWidth', 2.5, 'Color', 'b');

% Grade e título
grid on;
title("Peso Máximo de Decolagem", 'FontSize', 26, 'FontWeight', 'bold');
subtitle("Limitado pela condição mais restritiva - OEI com gradiente de subida 2.4%", 'FontSize', 22);

% Eixos
xlabel("Temperatura ISA (°C)", 'FontSize', 22);
ylabel("MTOW (N)", 'FontSize', 22);

% Legenda
legend({'Requisito Operacional AEO', 'Requisito de Certificação OEI'}, ...
       'FontSize', 22, 'Location', 'best');

set(gca, 'FontSize', 22);

