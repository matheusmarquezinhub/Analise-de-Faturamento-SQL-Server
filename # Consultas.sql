## Banco de dados utilizado

USE Atendimentos;

-- Visualizar todos os registros da tabela ControleAtendimento
SELECT *
FROM ControleAtendimento;

-- Obter o maior faturamento
SELECT Cliente, Valores, Data, Servico
FROM ControleAtendimento
WHERE Valores = (
    SELECT MAX(Valores)
    FROM ControleAtendimento
);

-- Obter o menor faturamento
SELECT Cliente, Valores, Data, Servico
FROM ControleAtendimento
WHERE Valores = (
    SELECT MIN(Valores)
    FROM ControleAtendimento
);

-- Obter média dos valores
SELECT AVG(Valores) AS Media
FROM ControleAtendimento;

-- 🎯 Missão 1 — Aquecer os motores
-- Faturamento por data e cliente, ordenado do maior para o menor
SELECT Data, Cliente, SUM(Valores) AS Faturamento
FROM ControleAtendimento
GROUP BY Data, Cliente
ORDER BY Faturamento DESC;

-- 🎯 Missão 2 — Escalar o desafio
-- Faturamento por serviço, ordenado do maior para o menor
SELECT Servico, SUM(Valores) AS Faturamento
FROM ControleAtendimento
GROUP BY Servico
ORDER BY Faturamento DESC;

-- Visualizar todos os serviços da tabela dServico
SELECT *
FROM dServico;

-- Faturamento por data e descrição do serviço (join com dServico)
SELECT Data, s.Descricao, a.Servico, SUM(Valores) AS Faturamento
FROM ControleAtendimento a
INNER JOIN dbo.dServico s ON a.Servico = s.IDServico
GROUP BY Data, s.Descricao, a.Servico
ORDER BY Faturamento DESC;

-- 🎯 Missão 3 — Metas
-- Definir meta anual e calcular metas mensal, semanal e diária
DECLARE @MetaAnual DECIMAL(10,2) = 80000;

SELECT 
    @MetaAnual AS MetaAnual,
    @MetaAnual / 12 AS MetaMensal,
    @MetaAnual / 52 AS MetaSemanal,
    @MetaAnual / 365 AS MetaDiaria;

-- 🎯 Missão 4 — Variação percentual
-- Total faturado por ano e mês para os dois últimos meses
SELECT 
    DATEPART(YEAR, Data) AS Ano,
    DATEPART(MONTH, Data) AS Mes,
    SUM(Valores) AS Total
FROM ControleAtendimento
WHERE Data >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
   OR Data >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data);

-- 🎯 Missão 5 — Comparar meta com resultado real
DECLARE @MetaAnual DECIMAL(10,2) = 80000;
DECLARE @MetaMensal DECIMAL(10,2) = @MetaAnual / 12;

WITH Faturamento AS (
    SELECT 
        DATEPART(YEAR, Data) AS Ano,
        DATEPART(MONTH, Data) AS Mes,
        SUM(Valores) AS Total,
        CASE 
            WHEN SUM(Valores) >= @MetaMensal THEN 'Sim'
            ELSE 'Não'
        END AS MetaBatida
    FROM ControleAtendimento
    GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data)
)
SELECT * FROM Faturamento;

-- 🎯 Missão 6 — Calcular variação percentual entre meses consecutivos e análise de metas

-- Declaração de variáveis para controle de metas
DECLARE @MetaAnual DECIMAL(10,2) = 80000;    -- Meta anual de faturamento
DECLARE @MetaMensal DECIMAL(10,2) = @MetaAnual / 12;  -- Meta mensal

WITH Faturamento AS (
    SELECT 
        DATEPART(YEAR, Data) AS Ano,
        DATEPART(MONTH, Data) AS Mes,
        SUM(CAST(Valores AS DECIMAL(18,2))) AS Total,
        CASE 
            WHEN SUM(CAST(Valores AS DECIMAL(18,2))) >= @MetaMensal THEN 'Sim'
            ELSE 'Não'
        END AS MetaBatida
    FROM ControleAtendimento
    GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data)
)

SELECT 
    F1.Ano,
    F1.Mes,
    F1.Total AS TotalAtual,
    F2.Total AS TotalAnterior,
    @MetaMensal AS MetaMensal,
    F1.MetaBatida,
    ROUND(F1.Total - @MetaMensal, 2) AS DiferencaMeta,
    ROUND((F1.Total / NULLIF(@MetaMensal, 0)) * 100, 2) AS PercentualMeta,
    ROUND(((F1.Total - F2.Total) / NULLIF(F2.Total, 0)) * 100, 2) AS VariacaoPercentual,
    CASE 
        WHEN F2.Total IS NULL THEN 'Sem comparação'
        WHEN F1.Total > F2.Total THEN 'Crescimento'
        WHEN F1.Total < F2.Total THEN 'Queda'
        ELSE 'Estável'
    END AS Tendencia
FROM Faturamento F1
LEFT JOIN Faturamento F2 ON (F1.Ano * 100 + F1.Mes) = (F2.Ano * 100 + F2.Mes + 1)
ORDER BY F1.Ano, F1.Mes;

-- 🎯 Missão 7 — Meta dinâmica com margem de lucro

DECLARE @MargemLucro DECIMAL(5,2) = 15;  -- 15% de margem sobre a média histórica

WITH CalculoMeta AS (
    SELECT 
        AVG(TotalMensal) AS MediaMensal,
        AVG(TotalMensal) * (1 + @MargemLucro/100) AS MetaMensal
    FROM (
        SELECT 
            DATEPART(YEAR, Data) AS Ano,
            DATEPART(MONTH, Data) AS Mes,
            SUM(CAST(Valores AS DECIMAL(18,2))) AS TotalMensal
        FROM ControleAtendimento
        WHERE DATEPART(YEAR, Data) = YEAR(GETDATE())
        GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data)
    ) SubTotal
),

Faturamento AS (
    SELECT 
        DATEPART(YEAR, Data) AS Ano,
        DATEPART(MONTH, Data) AS Mes,
        SUM(CAST(Valores AS DECIMAL(18,2))) AS Total,
        CASE 
            WHEN SUM(CAST(Valores AS DECIMAL(18,2))) >= (SELECT MetaMensal FROM CalculoMeta) THEN 'Sim'
            ELSE 'Não'
        END AS MetaBatida
    FROM ControleAtendimento
    GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data)
)

SELECT 
    F1.Ano,
    F1.Mes,
    F1.Total AS TotalAtual,
    F2.Total AS TotalAnterior,
    ROUND(CM.MediaMensal, 2) AS MediaMensal,
    ROUND(CM.MetaMensal, 2) AS MetaMensal,
    CONCAT(@MargemLucro, '%') AS MargemAplicada,
    F1.MetaBatida,
    ROUND(F1.Total - CM.MetaMensal, 2) AS DiferencaMeta,
    ROUND((F1.Total / NULLIF(CM.MetaMensal, 0)) * 100, 2) AS PercentualMeta,
    ROUND(((F1.Total - F2.Total) / NULLIF(F2.Total, 0)) * 100, 2) AS VariacaoPercentual,
    CASE 
        WHEN F2.Total IS NULL THEN 'Sem comparação'
        WHEN F1.Total > F2.Total THEN 'Crescimento'
        WHEN F1.Total < F2.Total THEN 'Queda'
        ELSE 'Estável'
    END AS Tendencia
FROM Faturamento F1
CROSS JOIN CalculoMeta CM
LEFT JOIN Faturamento F2 ON (F1.Ano * 100 + F1.Mes) = (F2.Ano * 100 + F2.Mes + 1)
ORDER BY F1.Ano, F1.Mes;