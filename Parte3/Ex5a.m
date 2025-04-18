%Exercicio 5-a

%Parte 1: Requisito Operacional (AEO - Todos Motores Operando)

gama = deg2rad(5.5); % especificado

g = 9.80665; %m/s^2 aceleração da gravidade

S = 88; % especificado

Clmax = 2.5; % especificado

Clzero = 0.3; % especificado

Cl = Clmax/(1.1^2); % explicação no relatório

Cd = 0.03 + 0.07 * (Cl ^ 2); % valor para Cd de acordo com a polar de arrasto

deltaT = 1; % especificado (100%)

%------Cálculo do rho-------------

R = 287; % J/Kg K SL
Tzero = 288.15; % K (15˚C) SL
rhozero = 1.225; %Kg/m^3 densidade no nivel do mar

pzero = rhozero*R*Tzero; %pressao SL

rho = [pzero/(R*(Tzero-10)) pzero/(R*(Tzero+30))]; % rho nas temperaturas ISA-10 e ISA30 SL

%--------Fim cálculo rho------------

T = deltaT .* ((rho/1.225).^0.6).*55600; % especificado

Resultados = zeros(2, 4); % [Vestol, Vlof, D, m]

for j = 1:1:2

    func = @(x)[
        x(1) - sqrt((2*x(4)*g*cos(gama))/(rho(j)*S*Clmax)); % Slide n 29 (Aula: Envelopes de Voo) x(1) = Vestol
    
        x(2) - (1.1*x(1)); % especificado x(2) = Vlof
    
        x(3) - ((1/2) * rho(j) * (x(2)^2) * S * Cd); %calculo de D -> x(3) = D
    
        x(4) - ((T(j)-x(3))/(g*sin(gama))); %subida permanente -> x(4) = m    
    ];

    x0 = [400, 440, 40000, 33000];

    sol = fsolve(func, x0);

    Resultados(j, :) = sol;
end


fprintf('\nResultados (ISA -10 e ISA +30):\n');
fprintf('%12s %12s %12s %12s\n', 'Vestol (m/s)', 'Vlof (m/s)', 'D (N)', 'm (kg)');
fprintf('%12.2f %12.2f %12.2f %12.2f      <- ISA-10\n', Resultados(1,1), Resultados(1,2), Resultados(1,3), Resultados(1,4));
fprintf('%12.2f %12.2f %12.2f %12.2f      <- ISA+30\n', Resultados(2,1), Resultados(2,2), Resultados(2,3), Resultados(2,4));
