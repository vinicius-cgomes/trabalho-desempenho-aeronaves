**Resumo de arquivos da pasta**

**atmosferaISA(H)** —> retorna rho, T e p com base na altitude.

**comparacao_ISA_real.m** —> Gera uma tabela da atmosfera padrão ISA e calcula a altitude de densidade com base em temperaturas reais para comparação.



---

### Exercício 1 – Atmosfera ISA e Altitude de Densidade

**O que o enunciado pede:**  
Criar a função `atmosferaISA(H)` que retorna densidade, temperatura e pressão em função da altitude segundo o modelo ISA. A partir dela, construir um gráfico que relacione a atmosfera real com a ISA em termos de **altitude de densidade**, considerando como entrada a **temperatura real** e a **altitude de pressão**.

**O que já foi feito:**  
- ✅ Função `atmosferaISA(H)` implementada  
- ✅ Tabela gerada com valores de temperatura, pressão e densidade ISA de 0 a 20.000 m  
- ✅ Cálculo da altitude de densidade com base na temperatura real  
- ✅ Gráfico gerado relacionando **temperatura real** com **altitude de densidade**

**O que falta:**  
- 🟡 Adicionar a **altitude de pressão** como referência no gráfico (ex: marcadores ou linhas horizontais para comparar com a altitude de densidade)

**O que eu entendi:**  
Durante a operação da aeronave, o piloto conhece a **altitude-pressão** (via instrumentos) e a **temperatura externa** (via sensores). O cálculo da **altitude de densidade** é fundamental para avaliar o desempenho real da aeronave, pois afeta diretamente a sustentação, empuxo e eficiência do voo.

--- 
