    % ====================================
    % Exercíco 2 - Parte B
    % ====================================
    clc; clear;
    
    % Dados da aeronave
    g = 9.8;                        
    S = 88;                         
    CD0 = 0.015;                    
    k = 0.05;                       
    m = 33100;                      
    H0 = 10000;                     
    x0 = 0;                         
    rho = atmosferaISA(H0); 
    
    % Condições de voo (CL)
    CL_values = linspace(0, 2.5, 10);
    results = [];
    
    % Calcular os resultados para cada CL
    for i = 1:length(CL_values)
        CL = CL_values(i);
        CD = CD0 + k * CL^2;
        E = CL / CD;
    
        % Velocidade inicial
        V0 = sqrt((2*m*g)/(rho*S)) * 1/(CL^2+CD^2)^(1/4); 
    
        % Ângulo de trajetória
        gamma0 = -atan(1 / E);            % [rad]
        gamma0_deg = rad2deg(gamma0);     % [graus]
    
        y0 = [V0; gamma0; H0; x0];        % Estado inicial [V; γ; H; x]
    
        % Equações diferenciais do voo planado
        f = @(t, y) [
            -(0.5 * rho * y(1)^2 * S * CD) / m - g * sin(y(2));           % dV/dt
            (0.5 * rho * y(1)^2 * S * CL - m * g * cos(y(2))) / (m*y(1)); % dγ/dt
            y(1) * sin(y(2));                                             % dH/dt
            y(1) * cos(y(2))                                              % dx/dt
        ];
    
        % Evento: parar quando altura chegar a zero
        opts = odeset('Events', @evento_altura_zero);
    
        % Resolver ODE
        [t, y] = ode45(f, [0 10000], y0, opts);
    
        alcance_km = y(end, 4) / 1000;
        autonomia_min = t(end) / 60;
    
        results = [results;
            i, CL, E, V0, gamma0_deg, alcance_km, autonomia_min];
    end
    
    % Mostrar tabela no console
    disp('Tabela - Parte B')
    disp('   #     CL      E        V_inicial[m/s]  gamma_inicial[°]  Alcance[km]  Autonomia[min]')
    fprintf('%3d   %6.3f   %6.2f     %10.2f      %10.2f      %10.2f     %10.2f\n', results')
    
    % % Salvar como tabela
    % T = array2table(results, 'VariableNames', ...
    %   {'Caso', 'CL', 'E', 'V_inicial', 'gamma_inicial_deg', 'Alcance_km', 'Autonomia_min'});
    % writetable(T, 'tabela_voo_planado_Aeronautica.csv');
    % 
    % disp('Tabela salva como tabela_voo_planado_Aeronautica.csv');
    
    
    % CL de máximo alcance e máximo autonomia
    [max_alcance, idx_alcance] = max(results(:,6));
    CL_max_alcance = results(idx_alcance, 2);  
    disp('   ');
    disp(['CL de Máximo Alcance: ', num2str(CL_max_alcance)]);
    disp(['Alcance Máximo: ', num2str(max_alcance), ' km']);
    
    % Encontrar o CL de máxima autonomia
    [max_autonomia, idx_autonomia] = max(results(:,7));
    CL_max_autonomia = results(idx_autonomia, 2); 
    disp('  ');
    disp(['CL de Máxima Autonomia: ', num2str(CL_max_autonomia)]);
    disp(['Autonomia Máxima: ', num2str(max_autonomia), ' min']);
    
    % Gráficos
    figure;
    
    % Gráfico de Alcance vs CL
    subplot(2,2,1);      % 2 linhas e 2 colunas
    plot(results(:,2), results(:,6), '-o'); %coluna 2 e 6 de results
    title('Alcance vs CL');
    xlabel('CL');
    ylabel('Alcance (km)');
    
    % Gráfico de Autonomia vs CL
    subplot(2,2,2);
    plot(results(:,2), results(:,7), '-o');
    title('Autonomia vs CL');
    xlabel('CL');
    ylabel('Autonomia (min)');
    
    % Gráfico de Gamma Inicial vs CL
    subplot(2,2,3);
    plot(results(:,2), results(:,5), '-o');
    title('Gamma Inicial vs CL');
    xlabel('CL');
    ylabel('Gamma Inicial (°)');
    
    % Gráfico de Velocidade Inicial vs CL
    subplot(2,2,4);
    plot(results(:,2), results(:,4), '-o');
    title('Velocidade Inicial vs CL');
    xlabel('CL');
    ylabel('Velocidade Inicial (m/s)');
    
    % Ajuste nos gráficos
    sgtitle('Análise do Voo Planado');
