% Função para as equações diferenciais do voo planado

function dYdt = voo_planado(t, Y, S, CL, CD, m, g)
    
    % Entradas:
    % t   - Tempo
    % Y   - Vetor de estado [V, gamma, H, X]
    % S   - Área da asa
    % CL  - Coeficiente de sustentação
    % CD  - Coeficiente de arrasto
    % m   - Massa da aeronave
    % g   - Aceleração devido à gravidade

    % Abrindo o vetor de estado
    V = Y(1);     
    gamma = Y(2);  
    H = Y(3);      
    x = Y(4);      

    % Cálculo da densidade do ar
    [~, ~, ~, rho_traj] = atmosisa(H);

    % Forças aerodinâmicas
    L = 0.5 * rho_traj * V^2 * S * CL;  
    D = 0.5 * rho_traj * V^2 * S * CD; 

    % Equações diferenciais
    dVdt = -D / m - g * sin(gamma);  
    dgamma_dt = (L / m - g * cos(gamma)) / V;  
    dHdt = V * sin(gamma);           
    dxdt = V * cos(gamma);            

    % Retorno das equações diferenciais
    dYdt = [dVdt; dgamma_dt; dHdt; dxdt];
end
