# 📊 Sistema de Análise de Faturamento - SQL Server

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft%20sql%20server&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-Formula_Language-orange?style=for-the-badge)
![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)

Sistema completo de análise de faturamento desenvolvido com SQL Server, Power BI e DAX para controle de atendimentos, monitoramento financeiro e acompanhamento de metas.

## 📋 Estrutura do Repositório

```
📂 Analise-de-Faturamento-SQL-Server/
├── 📂 sql-database/                 # Scripts SQL Server
│   ├── 📄 database-creation.sql     # Criação do banco e tabelas
│   ├── 📄 queries-analytics.sql     # Consultas analíticas
│   └── 📄 stored-procedures.sql     # Procedures e funções
├── 📂 dax-measures/                 # Medidas DAX Power BI
│   ├── 📄 financial-measures.dax    # Medidas financeiras
│   ├── 📄 operational-measures.dax  # Medidas operacionais
│   └── 📄 comparative-analysis.dax  # Análises comparativas
├── 📂 dashboard-images/             # Screenshots do dashboard
├── 📄 README.md                     # Este arquivo

```

## 🗄️ Estrutura de Banco de Dados SQL Server

### Tabela Principal: `ControleAtendimento`

```sql
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
```

### Principais Consultas SQL

#### 1. Consulta de Faturamento por Período
```sql
SELECT 
    DATEPART(YEAR, Data) AS Ano,
    DATEPART(MONTH, Data) AS Mes,
    SUM(Valores) AS TotalFaturamento,
    COUNT(*) AS QuantidadeAtendimentos
FROM ControleAtendimento
GROUP BY DATEPART(YEAR, Data), DATEPART(MONTH, Data)
ORDER BY Ano, Mes;
```

#### 2. Análise de Ticket Médio
```sql
SELECT 
    Servico,
    AVG(Valores) AS TicketMedio,
    COUNT(*) AS TotalAtendimentos,
    SUM(Valores) AS FaturamentoTotal
FROM ControleAtendimento
GROUP BY Servico
ORDER BY TicketMedio DESC;
```

#### 3. Performance por Tipo de Pagamento
```sql
SELECT 
    TipoPagamento,
    COUNT(*) AS Quantidade,
    SUM(Valores) AS Faturamento,
    AVG(Valores) AS ValorMedio
FROM ControleAtendimento
GROUP BY TipoPagamento
ORDER BY Faturamento DESC;
```

## 📊 Medidas DAX para Power BI

### Medidas Financeiras Principais

```dax
Receita Bruta = 
SUM(fDados[Valores])

Receita Líquida = 
SUMX(
    fDados,
    VAR Receita = fDados[Valores]
    VAR Taxa = 
        SWITCH(
            fDados[TipoPagamento],
            "VE", 0.02,
            "VC", 0.04,
            0
        )
    RETURN Receita * (1 - Taxa)
)

Lucro Líquido = 
[Receita Líquida] - [Despesas]
```

### Medidas de Variação e Performance

```dax
Variação % Mensal = 
DIVIDE(
    [Receita Bruta] - CALCULATE([Receita Bruta], DATEADD(dCalendario[Data], -1, MONTH)),
    CALCULATE([Receita Bruta], DATEADD(dCalendario[Data], -1, MONTH))
)

Ticket Médio = 
DIVIDE(
    [Receita Bruta],
    COUNTROWS(fDados)
)
```

### Medidas de Análise Comparativa

```dax
Performance vs Meta = 
DIVIDE(
    [Receita Bruta],
    [Meta Mensal],
    0
)

% Margem Líquida = 
DIVIDE(
    [Lucro Líquido],
    [Receita Bruta],
    0
)
```

## 📈 Dashboard Power BI - Visualizações

### Visão Geral do Dashboard

**Principais Componentes:**
- Cards com KPIs principais (Receita, Lucro, Ticket Médio)
- Gráficos de tendência temporal
- Comparativos com período anterior
- Indicadores de performance visual

### Análise Financeira Detalhada

**Métricas Incluídas:**
- Evolução da receita e lucro
- Margens de profitability
- Variações percentuais
- Análise por canal de venda

### Métricas Operacionais

**Indicadores Chave:**
- Volume de atendimentos
- Eficiência operacional
- Performance por serviço
- Análise de sazonalidade

## 📊 Principais KPIs Monitorados

### Financeiros
- ✅ Receita Bruta e Líquida
- ✅ Lucro Líquido
- ✅ Margem de Profitability
- ✅ Ticket Médio
- ✅ Variações Percentuais

### Operacionais
- ✅ Volume de Atendimentos
- ✅ Eficiência Operacional
- ✅ Performance por Serviço
- ✅ Taxa de Retenção de Clientes

### Comparativos
- ✅ vs Período Anterior
- ✅ vs Meta Estabelecida
- ✅ vs Ano Anterior
- ✅ Benchmarking setorial

## 🔧 Tecnologias Utilizadas

- **Microsoft SQL Server**: Banco de dados principal
- **Power BI**: Visualização e dashboard
- **DAX**: Linguagem de fórmulas analíticas
- **SQL**: Consultas e manipulação de dados
- **Git**: Controle de versão

## 📋 Pré-requisitos

- SQL Server 2012 ou superior
- Power BI Desktop
- Conhecimento básico de SQL e DAX
- Accesso a dados de transações

## 🛠️ Customização

### Adicionar Novas Métricas
```sql
-- Exemplo: Nova métrica personalizada
ALTER TABLE ControleAtendimento
ADD NovaColuna DECIMAL(10,2);
```

### Modificar Medidas DAX
```dax
// Exemplo: Nova medida personalizada
Nova Métrica = 
CALCULATE(
    [Receita Bruta],
    fDados[TipoAtendimento] = "Salão"
)
```

## 🤝 Contribuição

Contribuições são bem-vindas! Siga estos passos:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou problemas:

- **Email**: [marquuezinmatheus@gmail.com](mailto:marquuezinmatheus@gmail.com)

---

**⭐️ Se este projeto foi útil, deixe uma estrela no repositório!**

---

*Última atualização: Setembro 2025*