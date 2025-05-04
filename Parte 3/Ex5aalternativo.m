%Exercicio 5-a

%Parte 1: Requisito Operacional (AEO - Todos Motores Operando)

gama = deg2rad(5.5); % especificado

g = 9.80665; %m/s^2 aceleração da gravidade

S = 88; % especificado

Clmax = 2.5; % especificado

Clzero = 0.3; % especificado

deltaT = 1; % especificado (100%)

%------Cálculo do rho-------------
R = 287;

[rhozero, Tzero, pzero] = atmosferaISA(0); % utilização da função desenvolvida na primeira questão em SL

rho = [pzero/(R*(Tzero-10)) pzero/(R*(Tzero+30))]; % rho nas condições de temperatura ISA-10 e ISA30 SL

%--------Fim cálculo rho------------

T = deltaT .* ((rho/1.225).^0.6).*55600; % especificado

Resultados = zeros(2, 6); % [Vestol, Vlof, D, m]

for j = 1:1:2

    func = @(x)[
        x(1) - sqrt((2*x(4)*g*cos(gama))/(rho(j)*S*Clmax)); % Slide n 29 (Aula: Envelopes de Voo) x(1) = Vestol
    
        x(2) - (1.1*x(1)); % especificado x(2) = Vlof
    
        x(3) - ((1/2) * rho(j) * (x(2)^2) * S * x(6)); %calculo de D -> x(3) = D
    
        x(4) - ((T(j)-x(3))/(g*sin(gama))); %subida permanente -> x(4) = m

        x(5) - (2*x(4)*g*cos(gama))/(rho(j)*S*x(2)^2);

        x(6) - 0.03 - 0.07*x(5)^2;
    ];

    x0 = [400, 440, 40000, 33000, 2.5, 2.0];

    opts = optimset('Diagnostics','off', 'Display','off');

    sol = fsolve(func, x0, opts);

    Resultados(j, :) = sol;
end


fprintf('\nResultados (ISA-10 e ISA30):\n');
fprintf('%12s %12s %12s %12s %12s\n', 'Cond Temp', 'Vestol (m/s)', 'Vlof (m/s)', 'D (N)', 'm (kg)');
fprintf('%12s %12.2f %12.2f %12.2f %12.2f\n', 'ISA-10', Resultados(1,1), Resultados(1,2), Resultados(1,3), Resultados(1,4));
fprintf('%12s %12.2f %12.2f %12.2f %12.2f\n', 'ISA30', Resultados(2,1), Resultados(2,2), Resultados(2,3), Resultados(2,4));
