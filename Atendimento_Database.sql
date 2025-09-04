-- =============================================
-- BANCO DE DADOS: SISTEMA DE CONTROLE DE ATENDIMENTO
-- ARQUIVO: Atendimento_Database.sql
-- DESCRIÇÃO: Criação do banco, tabelas e consultas analíticas
-- DATA: 2024
-- =============================================

-- =============================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- =============================================

CREATE DATABASE Atendimento
ON PRIMARY 
(
    NAME = Atendimento_Data,
    FILENAME = 'C:\SQLData\Atendimento.mdf',
    SIZE = 20MB,           
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 10MB     
)
LOG ON 
(
    NAME = Atendimento_Log,
    FILENAME = 'C:\SQLData\Atendimento.ldf',
    SIZE = 10MB,           
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5MB     
);
GO

-- =============================================
-- 2. CRIAÇÃO DA TABELA PRINCIPAL
-- =============================================

USE Atendimento;
GO

CREATE TABLE ControleAtendimento
(
  ID_Dados SMALLINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Data DATE NOT NULL DEFAULT GETDATE(),
  Comanda INT NOT NULL CHECK (Comanda > 0),
  Cliente VARCHAR(255) NOT NULL,
  Servico VARCHAR(50) NOT NULL,
  Valores DECIMAL(10,2) NOT NULL CHECK (Valores >= 0),
  TipoPagamento VARCHAR(20) NOT NULL CHECK (TipoPagamento IN ('Dinheiro', 'VC', 'PIX', 'VE')),
  SaoClientes VARCHAR(10) CHECK (SaoClientes IN ('Sim', 'Não')),
  Foto VARBINARY(MAX),
  TipoAtendimento VARCHAR(20) CHECK (TipoAtendimento IN ('Salão', 'Domicilio'))
);
GO

-- =============================================
-- 3. INSERÇÃO DE DADOS DE EXEMPLO
-- =============================================

INSERT INTO ControleAtendimento (Data, Comanda, Cliente, Servico, Valores, TipoPagamento, SaoClientes, Tipo_Atendimento)
VALUES 
('2024-01-15', 100, 'Cliente 01', 'Corte', 30.00, 'PIX', 'Sim', 'Salão'),
('2024-01-15', 101, 'Cliente 02', 'Penteado', 45.00, 'Dinheiro', 'Não', 'Salão'),
('2024-01-16', 102, 'Cliente 03', 'Barba', 20.00, 'VC', 'Sim', 'Domicilio'),
('2024-01-16', 103, 'Cliente 04', 'Coloração', 80.00, 'PIX', 'Sim', 'Salão'),
('2024-01-17', 104, 'Cliente 05', 'Corte', 35.00, 'VE', 'Não', 'Salão');
GO

-- =============================================
-- 4. CONSULTAS BÁSICAS
-- =============================================

USE Atendimentos;

-- Visualizar todos os registros da tabela ControleAtendimento
SELECT *
FROM ControleAtendimento;

-- Maior faturamento
SELECT Cliente, Valores, Data, Servico
FROM ControleAtendimento
WHERE Valores = (
    SELECT MAX(Valores)
    FROM ControleAtendimento
);

-- Menor faturamento
SELECT Cliente, Valores, Data, Servico
FROM ControleAtendimento
WHERE Valores = (
    SELECT MIN(Valores)
    FROM ControleAtendimento
);

-- Média dos valores
SELECT AVG(Valores) AS Media
FROM ControleAtendimento;

-- =============================================
-- 5. CONSULTAS ANALÍTICAS (MISSÕES)
-- =============================================
-- 🎯 Missão 1 - Faturamento por data e cliente
-- Faturamento por data e cliente, ordenado do maior para o menor
SELECT Data, Cliente, SUM(Valores) AS Faturamento
FROM ControleAtendimento
GROUP BY Data, Cliente
ORDER BY Faturamento DESC;

-- 🎯 Missão 2 - Faturamento por serviço
-- Faturamento por serviço, ordenado do maior para o menor
SELECT Servico, SUM(Valores) AS Faturamento
FROM ControleAtendimento
GROUP BY Servico
ORDER BY Faturamento DESC;

/*-- Visualizar todos os serviços da tabela dServico
SELECT *
FROM dServico;

-- Faturamento por data e descrição do serviço (join com dServico)
SELECT Data, s.Descricao, a.Servico, SUM(Valores) AS Faturamento
FROM ControleAtendimento a
INNER JOIN dbo.dServico s ON a.Servico = s.IDServico
GROUP BY Data, s.Descricao, a.Servico
ORDER BY Faturamento DESC;*/

-- 🎯 Missão 3 - Metas de faturamento
-- Definir meta anual e calcular metas mensal, semanal e diária
DECLARE @MetaAnual DECIMAL(10,2) = 80000;

SELECT 
    @MetaAnual AS MetaAnual,
    @MetaAnual / 12 AS MetaMensal,
    @MetaAnual / 52 AS MetaSemanal,
    @MetaAnual / 365 AS MetaDiaria;

-- 🎯 Missão 4 - Variação percentual mensal
-- Total faturado por ano e mês para os dois últimos meses
SELECT 
    DATEPART(YEAR, Data) AS Ano,
    DATEPART(MONTH, Data) AS Mes,
    SUM(Valores) AS Total
FROM ControleAtendimento
WHERE Data >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
   OR Data >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data);

-- 🎯 Missão 5 - Comparação com meta mensal
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

-- 🎯 Missão 6 - Variação percentual e tendência

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

-- 🎯 Missão 7 - Meta dinâmica com margem de lucro

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

-- =============================================
-- 6. CONSULTAS ADICIONAIS (OPCIONAIS)
-- =============================================

-- Total faturado por tipo de pagamento
SELECT TipoPagamento, SUM(Valores) AS Total
FROM ControleAtendimento
GROUP BY TipoPagamento
ORDER BY Total DESC;
GO

-- Clientes recorrentes vs novos clientes
SELECT SaoClientes, COUNT(*) AS Quantidade, SUM(Valores) AS TotalFaturado
FROM ControleAtendimento
WHERE SaoClientes IS NOT NULL
GROUP BY SaoClientes;
GO

SELECT * FROM ControleAtendimento

-- Faturamento por tipo de atendimento
SELECT Tipo_Atendimento, SUM(Valores) AS Total
FROM ControleAtendimento
WHERE Tipo_Atendimento IS NOT NULL
GROUP BY Tipo_Atendimento
ORDER BY Total DESC;
GO

-- =============================================
-- FIM DO ARQUVO
-- =============================================
