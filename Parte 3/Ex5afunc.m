function ResultadosAEO = Ex5afunc()
%Exercicio 5-a

%Parte 1: Requisito Operacional (AEO - Todos Motores Operando)

gama = deg2rad(5.5); % especificado

g = 9.80665; %m/s^2 aceleracao da gravidade

S = 88; % especificado

Clmax = 2.5; % especificado

Clzero = 0.3; % especificado

Cl = Clmax/(1.1^2); % explicacao no relatorio

Cd = 0.03 + 0.07 * (Cl ^ 2); % valor para Cd de acordo com a polar de arrasto

deltaT = 1; % especificado (100%)

%------Calculo do rho-------------
R = 287;

[rhozero, Tzero, pzero] = atmosferaISA(0); % utilizacao da funcao desenvolvida na primeira questao em SL

Tlinha = Tzero-10:Tzero+30; % Vetor com temperaturas entre ISA-10 e ISA+30 SL

rho = pzero./(R.*Tlinha); % rho para as condiçoes de temperatura entre ISA-10 e ISA30 SL

%--------Fim calculo rho------------

T = deltaT .* ((rho/1.225).^0.6).*55600; % especificado

ResultadosAEO = zeros(length(rho), 5); % [Vestol, Vlof, D, m, W]

for j = 1:1:length(rho)

    func = @(x)[
        x(1) - sqrt((2*x(4)*g*cos(gama))/(rho(j)*S*Clmax)); % Slide n 29 (Aula: Envelopes de Voo) x(1) = Vestol
    
        x(2) - (1.1*x(1)); % especificado x(2) = Vlof
    
        x(3) - ((1/2) * rho(j) * (x(2)^2) * S * Cd); %calculo de D -> x(3) = D
    
        x(4) - ((T(j)-x(3))/(g*sin(gama))); %subida permanente -> x(4) = m  
        x(5) - x(4)*g; % x(5) = W
    ];

    x0 = [400, 440, 40000, 33000, 323620];

    opts = optimset('Diagnostics','off', 'Display','off');

    sol = fsolve(func, x0, opts);

    ResultadosAEO(j, :) = sol;
end

end