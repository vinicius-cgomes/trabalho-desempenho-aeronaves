clc,clear
%================= Vetores ISA =================
Hvec = 0:1000:20000;  % Altitudes de 0 a 20.000 m
rhovec = zeros(size(Hvec));
pvec = zeros(size(Hvec));
Tvec = zeros(size(Hvec));

for i = 1:length(Hvec)
    [rho, T, p] = atmosferaISA(Hvec(i));
    rhovec(i) = rho;
    pvec(i) = p;
    Tvec(i) = T;
    Tvec_C(i) = Tvec(i) - 273.15;
end

%================= Tabela ISA =================
TabelaISA = table(Hvec', Tvec', Tvec_C', pvec', rhovec', ...
    'VariableNames', {'Altitude_m', 'Temperatura_K', 'Temperatura_C', 'Pressao_Pa', 'Densidade_kg_m3'});
disp('-------------------- Tabela ISA -------------------- ');
disp(TabelaISA);

%================= Gráfico final =================

H_pressao_vec = [0, 2000, 4000, 6000, 8000];   % metros
T_real_vec = [288.15, 275.15, 262.15, 249.15, 236.15];  % K
R = 287;
rho_real_vec = zeros(size(H_pressao_vec));
H_densidade_vec = zeros(size(H_pressao_vec));

for i = 1:length(H_pressao_vec)
    H_p = H_pressao_vec(i);
    [~, ~, p_ISA] = atmosferaISA(H_p);
    rho_real = p_ISA / (R * T_real_vec(i));
    rho_real_vec(i) = rho_real;
    H_densidade = fzero(@(x) rho_real - atmosferaISA(x), H_p);
    H_densidade_vec(i) = H_densidade;
    
    T_real_C(i) = T_real_vec(i) - 273.15; 
end

figure;
hold on; grid on;
plot(T_real_C, H_densidade_vec)
xlabel('Temperatura (K)'); 
ylabel('Altitude de densidade (m)');
