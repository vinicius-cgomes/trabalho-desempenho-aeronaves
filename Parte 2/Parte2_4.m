%Trabalho Final - Desempenho
%Parte 2 - Análise de Envelope em Voo de cruzeiro
%Exercício 4: Envelope em Voo

function Ex4teste()
    %% Dados Básicos
    m_total = 33100;             % Massa total [kg]
    W_total = m_total * 9.81;    % Peso total [N]

    %% Características Aerodinâmicas p/ flap recolhido
    S = 88;                      % Área da asa [m²]
    CL_max = 2.0;                % Coef. de sustentação máximo
    CD0 = 0.015;                 % Coef. de arrasto parasita
    k = 0.05;                    % Fator de arrasto induzido

    %% Propulsão
    T0_single = 27800;           % Tração por motor [N]
    n_engines = 2;               % Número de motores
    delta_T = 1.0;               % Fator de manete (100%)

    n_rho = 0.6;                 % Parâmetro empírico para a modelagem da diminuição da tração máxima (F_max) com a altitude em modelos simplificados de envelope de voo.
    %depende do motor utilizado: Pistão 0.7/0.8 ou Turboélice simples 0.8/0.9 ou Turbojato	1.0

    F_max = T0_single * n_engines * delta_T;  % Tração máxima total ao nível do mar [N]

    %% Parâmetros
    Vmo_SL = 247.22;             % Velocidade máxima operacional 890km/h (nível do mar) [m/s]
    rho0 = 1.225;                % Densidade ao nível do mar [kg/m³]
    precisao_H = 10;            % Incremento de altitude [m]

    %% Geração do envelope
    plot_envelope_voo_cruzeiro(m_total, k, S, CD0, F_max, rho0, n_rho, CL_max, Vmo_SL, precisao_H);
end

function plot_envelope_voo_cruzeiro(m, k, S, Cd0, F_max, rho0, n_rho, CL_max, Vmo_SL, precisao_H)
    g = 9.81;
    
    % Determinar o teto absoluto
    Tmin = 2 * m * g * sqrt(k * Cd0);
    rho_teto = rho0 * (Tmin / F_max)^(1 / n_rho);
    H_teto = fzero(@(H) atmosferaISA(H) - rho_teto, 10000);
    H_vec = 0:precisao_H:ceil(H_teto);

    % Inicialização de vetores
    n = length(H_vec);
    V_min_vec = zeros(1, n);
    V_max_vec = zeros(1, n);
    V_estol_vec = zeros(1, n);

    % Cálculo das velocidades em cada altitude
    for i = 1:n
        H_i = H_vec(i);
        rho = atmosferaISA(H_i);

        % Estol
        V_estol_vec(i) = sqrt(2 * m * g / (rho * S * CL_max));

        % Velocidades mínima e máxima possíveis em cruzeiro permanente
        [Vmin, Vmax] = V_min_max_cruzeiro(m, H_i, S, Cd0, k, F_max, rho0, n_rho);
        Vmo = Vmo_SL * sqrt(rho0 / rho); % Limite por Vmo
        V_min_vec(i) = Vmin;
        V_max_vec(i) = min(Vmax, Vmo);
    end

    % Plot
    figure('Name','Envelope de Voo Longitudinal de Cruzeiro');
    hold on; grid on;

    % Área preenchida do envelope (opcional - pode manter ou remover)
    fill([V_min_vec fliplr(V_max_vec)], [H_vec fliplr(H_vec)], [0.8 0.9 1], 'EdgeColor','none', 'FaceAlpha',0.3, 'DisplayName', 'Zona Operacional');

    % Curva de V_max em azul escuro
    plot(V_max_vec, H_vec, 'b-', 'LineWidth', 2, 'DisplayName', 'Velocidade Máxima (V_{max})');

    % Curva de V_min em vermelho escuro
    plot(V_min_vec, H_vec, 'r-', 'LineWidth', 2, 'DisplayName', 'Velocidade Mínima (V_{min})');

    % Curva de estol em magenta
    plot(V_estol_vec, H_vec, 'm--', 'LineWidth', 1.5, 'DisplayName', 'Velocidade de Estol');

    % Teto absoluto
    plot([V_min_vec(end) V_max_vec(end)], [H_vec(end) H_vec(end)], 'ko--', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor','k', 'DisplayName', 'Teto Absoluto');
    text(mean([V_min_vec(end), V_max_vec(end)]), H_vec(end), sprintf('Teto: %.0f m', H_vec(end)), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

    % Configurações do gráfico
    xlabel('Velocidade (m/s)', 'FontWeight', 'bold');
    ylabel('Altitude (m)', 'FontWeight', 'bold');
    title('Envelope de Voo Longitudinal', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 10);
    set(gca, 'FontWeight', 'bold');
    hold off;

    % Impressão dos resultados finais
    fprintf('Teto absoluto de voo: %.2f metros\n', H_vec(end));
    fprintf('Velocidade máxima alcançável: %.2f m/s\n', max(V_max_vec));
    fprintf('Densidade no teto (rho_teto): %.6f kg/m³\n', rho_teto);
end

function [V_min, V_max] = V_min_max_cruzeiro(m, H, S, Cd0, k, F_max, rho0, n_rho)
    rho = atmosferaISA(H);
    g = 9.81;
    a = 0.5 * rho * S * Cd0;
    b = -F_max * (rho / rho0)^n_rho;
    c = 2 * k * (m * g)^2 / (rho * S);
    raizes = roots([a, b, c]);
    raizes_reais = raizes(imag(raizes) == 0 & real(raizes) > 0);
    V_roots = sqrt(real(raizes_reais));
    V_min = min(V_roots);
    V_max = max(V_roots);
end

function [rho, T, p] = atmosferaISA(H) %exercício 1
    % Constantes
    R = 287;                % Constante dos gases [J/kg·K]
    g = 9.80665;            % Gravidade [m/s²]
    rho_SL = 1.225;         % Densidade ao nível do mar [kg/m³]
    T_SL = 15 + 273.15;     % Temperatura ao nível do mar [K] = 15°C
    gradT = -6.5 / 1000;    % Gradiente térmico da troposfera [K/m]

    if H <= 11000  % Troposfera
        T = T_SL + gradT * H;
        rho = rho_SL * (1 + (gradT * H)/T_SL)^(-g/(R * gradT) - 1);
        p = rho * R * T;
    else  % Estratosfera até 20.000 m
        T11 = T_SL + gradT * 11000;
        rho_11 = atmosferaISA(11000); % Chama a função para obter a densidade a 11.000 m
        T = T11;
        rho = rho_11 * exp(-g * (H - 11000)/(R * T11));
        p = rho * R * T;
    end
end
