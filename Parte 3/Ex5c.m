%Exercicio 5-c

%Parte 3: Condicao mais restritiva: OEI - One Engine Inoperative

gradiente = 2.4/100; % Gradiente de subida 2.4% (altura ganha por distancia horizontal percorrida)
gama = atan(gradiente); % angulo de subida arco tangente do gradiente

g = 9.80665; %m/s^2 aceleracao da gravidade

S = 88; % especificado

Clmax = 2.5; % especificado

Clzero = 0.3; % especificado

Cl = Clmax/(1.2^2); % explicacao no relatorio

Cd = 0.03 + 0.07 * (Cl ^ 2); % valor para Cd de acordo com a polar de arrasto

deltaT = 1; % especificado (100%)

%------Cálculo do rho-------------
R = 287;

[rhozero, Tzero, pzero] = atmosferaISA(0); % utilizacao da funcao desenvolvida na primeira questao em SL

Tlinha = Tzero-10:Tzero+30; % Vetor com temperaturas entre ISA-10 e ISA+30 SL

rho = pzero./(R.*Tlinha); % rho para as condiçoes de temperatura entre ISA-10 e ISA30 SL

%--------Fim cálculo rho------------

T = (deltaT .* ((rho/1.225).^0.6).*55600)/2; % especificado - Potencia total pela metade por ter apenas um motor operando

Resultados = zeros(length(rho), 5); % [Vestol, Vlof, D, m, W]

for j = 1:1:length(rho)

    func = @(x)[
        x(1) - sqrt((2*x(4)*g*cos(gama))/(rho(j)*S*Clmax)); % Slide n 29 (Aula: Envelopes de Voo) x(1) = Vestol
    
        x(2) - (1.2*x(1)); % especificado x(2) = Vlof
    
        x(3) - ((1/2) * rho(j) * (x(2)^2) * S * Cd); %calculo de D -> x(3) = D
    
        x(4) - ((T(j)-x(3))/(g*sin(gama))); %subida permanente -> x(4) = m  

        x(5) - x(4)*g; % x(5) = W
    ];

    x0 = [400, 440, 40000, 33000, 323620];

    opts = optimset('Diagnostics','off', 'Display','off');

    sol = fsolve(func, x0, opts);

    ResultadosOei(j, :) = sol;
end



figure; hold on;
plot(Tlinha-288.15, Resultados(:,5)', "LineWidth",1, "Color","r");
grid on;
ylabel("MTOW (N)");
xlabel("Temperatura ISA");
title("Peso Máximo de Decolagem");
subtitle("Limitado pela condição mais restritiva - OEI com gradiente de subida 2.4%");