# 📊 Repositório de Medidas DAX - Sistema de Análise de Faturamento

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-Formula_Language-orange?style=for-the-badge)
![Data Analysis](https://img.shields.io/badge/Data_Analysis-Expertise-blue?style=for-the-badge)

Este repositório contém um conjunto completo de medidas DAX para análise de desempenho financeiro e operacional, desenvolvidas para dashboards Power BI com foco em controle de faturamento, lucratividade e métricas de atendimento.


## 🎯 Categorias de Medidas

### 📈 **Medidas Financeiras Principais**
- **Receita Bruta**: Soma total dos valores faturados
- **Receita Líquida**: Receita bruta menos taxas e impostos
- **Lucro Líquido**: Receita líquida menos despesas operacionais
- **% Margem Líquida**: Percentual de lucratividade sobre a receita bruta
- **Ticket Médio**: Valor médio por atendimento

### 📅 **Medidas Temporais**
- **Comparativos Mês Anterior**: Variações mensais
- **Comparativos Ano Anterior**: Variações anuais
- **Análise Semanal**: Performance por semana
- **Análise Quinzenal**: Performance por quinzena

### 📊 **Medidas de Performance**
- **Ícones de Setas**: Indicadores visuais de performance (↑↓)
- **Gráficos SVG**: Visualizações customizadas em SVG
- **Escalas Coloridas**: Indicadores tipo "Fear & Greed"

### 👥 **Medidas Operacionais**
- **Quantidade de Atendimentos**: Volume total de serviços
- **Eficiência Operacional**: Métricas de produtividade

## 🛠️ **Como Utilizar**

### Pré-requisitos
- Power BI Desktop
- Conhecimento básico de DAX
- Estrutura de dados compatível

### Implementação Básica
1. **Clone o repositório**:
```bash
git clone https://github.com/seu-usuario/medidas-dax.git
```

2. **Importe as medidas** no Power BI:
- Abra o Power Query Editor
- Cole as medidas nas tabelas apropriadas
- Ajuste as referências de tabela conforme necessário

### Estrutura de Dados Esperada
As medidas assumem a existência das seguintes tabelas:
- `fDados`: Tabela fatos com transações
- `dCalendario`: Tabela de datas
- `dServico`: Tabela de serviços
- `Metrics`: Tabela de metadados para métricas

## 📖 **Exemplos de Medidas**

### Medida de Receita Líquida
```dax
Receita Líquida = 
SUMX(
    fDados,
    VAR Receita = fDados[Valores]
    VAR Atendimento = fDados[Tipo_Atendimento]
    VAR Pagamento = fDados[TipoPagamento]
    VAR Taxa = 
        SWITCH(
            TRUE(),
            Atendimento = "Particular", 0,
            Pagamento = "VE", 0.02,
            Pagamento = "VC", 0.04,
            0
        )
    RETURN
        Receita * (1 - Taxa)
)
```

### Medida de Variação Percentual
```dax
Variacao % Mes = 
DIVIDE(
    [Receita Mes Atual] - [Receita Mes Anterior],
    [Receita Mes Anterior]
)
```

## 📊 **Métricas de Performance**

### Indicadores Chave (KPIs)
1. **Receita Bruta**: Tendência e variação
2. **Lucro Líquido**: Rentabilidade real
3. **Margem Líquida**: Eficiência operacional
4. **Ticket Médio**: Valor por transação
5. **Volume de Atendimentos**: Capacidade operacional

### Métricas de Comparação
- **Mês vs Mês Anterior**
- **Ano vs Ano Anterior**
- **Semana vs Semana Anterior**
- **Performance Acumulada**

## 🤝 **Contribuição**

Contribuições são bem-vindas! Para contribuir:

1. Faça um Fork do projeto
2. Crie uma Branch para sua feature
3. Commit suas mudanças
4. Push para a Branch
5. Abra um Pull Request

## 📞 **Suporte**

Para dúvidas ou problemas:

- **Email**: [marquuezinmatheus@gmail.com](mailto:marquuezinmatheus@gmail.com)

---

**⭐️ Se este projeto foi útil, deixe uma estrela no repositório!**

---

*Última atualização: Setemrbo 2025*