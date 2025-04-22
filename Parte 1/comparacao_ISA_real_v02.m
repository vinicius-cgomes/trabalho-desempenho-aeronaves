clc; clear;

%================= Vetores ISA =================
Hvec = 0:1000:20000;  % Altitudes de 0 a 20.000 m
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
Altitude_densidade_m = diag(H_densidade_vec);  % Apenas a diagonal

%================= Tabela 1 - Metros =================
Tabela1 = table(Hvec', Tvec', Tvec_C', pvec', rhovec', ...
    'VariableNames', {'Altitude_m', 'Temperatura_K', 'Temperatura_C', 'Pressao_Pa', 'Densidade_kg_m3'});
disp('-------------------- Tabela 1 (em metros) --------------------');
disp(Tabela1);

%================= Tabela 2 - Pés =================
Hvec_ft = Hvec' * 3.28084;
Altitude_densidade_ft = Altitude_densidade_m * 3.28084;

Tabela2 = table(Hvec_ft, Tvec', Tvec_C', pvec', rhovec', ...
    'VariableNames', {'Altitude_ft', 'Temperatura_K', 'Temperatura_C', 'Pressao_Pa', 'Densidade_kg_m3'});
disp('-------------------- Tabela 2 (em pés) --------------------');
disp(Tabela2);

%================= Gráfico 1 - Altitude de densidade em metros =================
figure;
hold on; grid on;
xlabel('Temperatura (°C)');
ylabel('Altitude de densidade (m)');
title('Altitude de Densidade vs Temperatura');

[lin, col] = size(H_densidade_vec);
for i = 1:lin
    if i <= col
        plot(Tvec_C, H_densidade_vec(i, :), 'Color', [0.5 0.5 0.5]); % Diagonal em cinza
    end
end

plot(T_ISA_C, Hvec, 'r', 'LineWidth', 2); % Linha vermelha ISA

%================= Gráfico 2 - Altitude de densidade em pés =================
H_densidade_vec_ft = H_densidade_vec * 3.28084;

figure;
hold on; grid on;
xlabel('Temperatura (°C)');
ylabel('Altitude de densidade (ft)');
title('Altitude de Densidade vs Temperatura');

for i = 1:lin
    if i <= col
        plot(Tvec_C, H_densidade_vec_ft(i, :), 'Color', [0.5 0.5 0.5]); % Diagonal em cinza
    end
end

plot(T_ISA_C, Hvec_ft, 'r', 'LineWidth', 2); % Linha vermelha ISA
