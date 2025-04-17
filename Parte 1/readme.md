**Resumo de arquivos da pasta**

**atmosferaISA(H)** —> retorna rho, T e p com base na altitude.

**comparacao_ISA_real.m** —> gera uma tabela da atmosfera padrão ISA e calcula a altitude de densidade com base em temperaturas reais para comparação.

**voo_planado_A.m**  —> simula o voo planado sem tração, calculando a trajetória, altitude vs distância, velocidade vs tempo, alcance e autonomia.

**voo_planado_B.m**  —> simula o voo planado variando o coeficiente de sustentação (CL), calculando o alcance e a autonomia da aeronave para diferentes valores de CL

**evento_altura_zero.m**   —> define um evento no código que interrompe a simulação do voo planado quando a altura da aeronava atinge zero (usado para executar a parte B)

---

### Exercício 1 – Atmosfera ISA e Altitude de Densidade

**O que o enunciado pede:**  
Criar a função `atmosferaISA(H)` que retorna densidade, temperatura e pressão em função da altitude segundo o modelo ISA. A partir dela, construir um gráfico que relacione a atmosfera real com a ISA em termos de **altitude de densidade**, considerando como entrada a **temperatura real** e a **altitude de pressão**.

**O que já foi feito:**  

✅ Função `atmosferaISA(H)` implementada  
✅ Tabela gerada com valores de temperatura, pressão e densidade ISA de 0 a 20.000 m  
✅ Cálculo da altitude de densidade com base na temperatura real  
✅ Gráfico gerado relacionando **temperatura real** com **altitude de densidade**

**O que falta:**  

🟡 Adicionar a **altitude de pressão** como referência no gráfico (ex: marcadores ou linhas horizontais para comparar com a altitude de densidade)

**O que eu entendi:**  
Durante a operação da aeronave, o piloto conhece a **altitude-pressão** (via instrumentos) e a **temperatura externa** (via sensores). O cálculo da **altitude de densidade** é fundamental para avaliar o desempenho real da aeronave, pois afeta diretamente a sustentação, empuxo e eficiência do voo.

--- 

### Exercício 2 – Simulação de Voo Planado

**O que o enunciado pede:**  
Simular o voo planado de uma aeronave a partir de 10.000 m de altitude, utilizando as equações do movimento longitudinal sem tração e considerando atmosfera padrão ISA. O exercício envolve cálculo de velocidades, trajetória, alcance, autonomia e análise para diferentes valores de coeficiente de sustentação (CL), além de variação da atmosfera (ISA + 20°C).

---

### Parte A – Simulação com CL ideal (`CL = sqrt(CD0/k)`)

**Já feito:**

✅ Resolução do sistema com `ode45` para a condição de planeio ideal  
✅ Gráfico da altura da aeronave vs. distância horizontal (H vs. x)  
✅ Gráfico das velocidades verdadeira (TAS) e indicada (IAS), em função do tempo  
✅ Cálculo do alcance [km] e autonomia [min] com interpolação (`interp1`)

**Pendente:**

🟡 Verificar/conferir o gráfico de velocidades (ta meio estranho)

---

### Parte B – Simulação de Voo Planado para Diferentes Valores de CL

**Já feito:**

✅ Simulação de voo planado para diferentes valores de **CL** (0 a 2.5)  
✅ Cálculo do **alcance** e da **autonomia** para cada **CL**  
✅ Cálculo da **eficiência aerodinâmica (E)**  
✅ Geração de gráficos de **alcance**, **autonomia**, **γ_inicial**, **H_dot_inicial** e **V_inicial** vs **CL**  
✅ Tabela com os resultados de **CL**, **E**, **V_inicial**, **γ_inicial**, **alcance** e **autonomia**

---

### Parte C – Simulação de Voo Planado para Atmosfera ISA + 20°C

**Já feito:**

✅ Simulação de voo planado para diferentes valores de CL (0 a 2.5) considerando a atmosfera ISA + 20°C
✅ Cálculo de alcance e autonomia para cada valor de CL
✅ Geração de gráficos de alcance, autonomia, gamma inicial e velocidade inicial em função de CL
✅ Tabela com os resultados de **CL**, **E**, **V_inicial**, **γ_inicial**, **alcance** e **autonomia**


