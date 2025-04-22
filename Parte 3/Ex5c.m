%Exercicio 5-c

%Parte 3: Comdição mais restritiva: OEI - One Engine Inoperative

gradiente = 2.4/100; % Gradiente de subida 2.4% (altura ganha por distância horizontal percorrida)
gama = atan(gradiente); % ângulo de subida arco tangente do gradiente

g = 9.80665; %m/s^2 aceleração da gravidade

S = 88; % especificado

Clmax = 2.5; % especificado

Clzero = 0.3; % especificado

Cl = Clmax/(1.2^2); % explicação no relatório

Cd = 0.03 + 0.07 * (Cl ^ 2); % valor para Cd de acordo com a polar de arrasto

deltaT = 1; % especificado (100%)

%------Cálculo do rho-------------

R = 287; % J/Kg K SL
Tzero = 288.15; % K (15˚C) SL
rhozero = 1.225; %Kg/m^3 densidade no nivel do mar

pzero = rhozero*R*Tzero; %pressao SL

Tlinha = Tzero-10:Tzero+30; % Vetor com temperaturas entre ISA-10 e ISA+30 SL

rho = pzero./(R.*Tlinha); % rho para as temperaturas entre ISA-10 e ISA30 SL

%--------Fim cálculo rho------------

T = (deltaT .* ((rho/1.225).^0.6).*55600)/2; % especificado - Potência total pela metade por ter apenas um motor operando

Resultados = zeros(length(rho), 4); % [Vestol, Vlof, D, m]

for j = 1:1:length(rho)

    func = @(x)[
        x(1) - sqrt((2*x(4)*g*cos(gama))/(rho(j)*S*Clmax)); % Slide n 29 (Aula: Envelopes de Voo) x(1) = Vestol
    
        x(2) - (1.2*x(1)); % especificado x(2) = Vlof
    
        x(3) - ((1/2) * rho(j) * (x(2)^2) * S * Cd); %calculo de D -> x(3) = D
    
        x(4) - ((T(j)-x(3))/(g*sin(gama))); %subida permanente -> x(4) = m    
    ];

    x0 = [400, 440, 40000, 33000];

    opts = optimset('Diagnostics','off', 'Display','off');

    sol = fsolve(func, x0, opts);

    Resultados(j, :) = sol;
end

figure; hold on;
plot(Tlinha-288.15, Resultados(:,4)', "LineWidth",1, "Color","r");
grid on;
ylabel("MTOW");
xlabel("Temperatura ISA");
title("Peso Máximo de Decolagem");
subtitle("");