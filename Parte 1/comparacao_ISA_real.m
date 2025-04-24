% ====================================
% Exercício 1
% ====================================
clc; clear; close all;

%================= Vetores ISA =================
Hvec = 0:1000:20000; 
rhovec = zeros(size(Hvec));
pvec = zeros(size(Hvec));
Tvec = zeros(size(Hvec));
Tvec_C = zeros(size(Hvec));

for i = 1:length(Hvec)
    [rho, T, p] = atmosferaISA(Hvec(i));
    rhovec(i) = rho;
    pvec(i) = p;
    Tvec(i) = T;
    Tvec_C(i) = T - 273.15;
end

%================= Altitude de densidade =================
R = 287;
H_densidade_vec = zeros(length(Hvec), length(Tvec));
T_ISA = zeros(size(Hvec));

for i = 1:length(Hvec)
    H_p = Hvec(i);                                              
    [~, T_ISA(i), p_ISA] = atmosferaISA(H_p);
    
    for k = 1:length(Tvec)                                          
        rho_real = p_ISA / (R * Tvec(k));
        H_densidade = fzero(@(x) rho_real - atmosferaISA(x), H_p);
        H_densidade_vec(i, k) = H_densidade;
    end
end

T_ISA_C = T_ISA - 273.15;
Altitude_densidade_m = diag(H_densidade_vec);  

%================= Tabela =================
Tabela1 = table(Hvec', Tvec_C', pvec', rhovec', Altitude_densidade_m, ...
    'VariableNames', {'Altitude_pressao_m', 'Temperatura_C', 'Temperatura_ISA_C', ...
                      'Pressao_Pa', 'Densidade_kg_m3', 'Altitude_densidade_m'});
disp('-------------------- Tabela --------------------');
disp(Tabela1);


%================= Gráfico - Altitude de densidade em metros =================
nH = length(Hvec);
figure;
hold on; grid on;
xlabel('Temperatura (°C)');
ylabel('Altitude de densidade (m)');
title('Altitude de Densidade vs Temperatura');
yticks(0:5000:20000);

% Plotando as linhas cinzas (altitudes de pressão)
for i = 1:nH
    plot(Tvec_C, H_densidade_vec(i,:), 'Color', [0.5 0.5 0.5]);
end

% Linha vermelha (Temperatura ISA)
h_isa = plot(T_ISA_C, Hvec, 'r', 'LineWidth', 2);

% Textos para cada altitude de pressão
for i = 1:nH
    x_vals = Tvec_C(end-1:end);
    y_vals = H_densidade_vec(i,end-1:end);
    angle = atan2d(diff(y_vals), diff(x_vals));
    xpos = Tvec_C(end) + 3;
    ypos = H_densidade_vec(i,end);
    text(xpos, ypos, ['H = ' num2str(Hvec(i)) ' m'], ...
        'FontSize', 8, ...
        'Rotation', angle, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','bottom');
end

% Legenda
legend([h_isa, plot(NaN, NaN, 'Color', [0.5 0.5 0.5])], ...
       {'Temperatura ISA', 'Altitudes de Pressão'}, ...
       'Location', 'Best');

% Remover notação científica
ax = gca;
ax.YAxis.Exponent = 0; 

hold off;


% Salvar o gráfico em um diretório específico sem mudar o diretório de trabalho
saveas(gcf, 'C:\Users\Isabela Soares\Desktop\Desempenho PEE\Projeto_Final');
