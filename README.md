# 📊 Sistema de Análise de Faturamento - SQL Server

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft%20sql%20server&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)

Este repositório contém um sistema completo de análise de faturamento desenvolvido em SQL Server, projetado para controle de atendimentos e acompanhamento de metas financeiras.

## 🚀 Funcionalidades

- **📦 Criação de Banco de Dados**: Script completo com configurações otimizadas
- **📋 Gestão de Atendimentos**: Registro de clientes, serviços e valores
- **📊 Análise de Faturamento**: Consultas avançadas para insights financeiros
-   **🎯 Sistema de Metas**: Definição e acompanhamento de metas com indicadores de performance
-   **📈 Análise Temporal**: Variação percentual e tendências mensais
-   **🔍 Relatórios Estratégicos**: Dados segmentados por serviço, cliente e tipo de pagamento

## 🗂️ Estrutura do Banco de Dados

### Tabela Principal: `ControleAtendimento`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `ID_Dados` | SMALLINT IDENTITY | Chave primária autoincrementável |
| `Data` | DATE | Data do atendimento (default: data atual) |
| `Comanda` | INT | Número da comanda (maior que 0) |
| `Cliente` | VARCHAR(255) | Nome do cliente |
| `Servico` | VARCHAR(50) | Tipo de serviço prestado |
| `Valores` | DECIMAL(10,2) | Valor do serviço (maior ou igual a 0) |
| `TipoPagamento` | VARCHAR(20) | Forma de pagamento (Dinheiro, VC, PIX, VE) |
| `SaoClientes` | VARCHAR(10) | Indica se são clientes recorrentes (Sim/Não) |
| `Foto` | VARBINARY(MAX) | Foto opcional do atendimento |
| `TipoAtendimento` | VARCHAR(20) | Local do atendimento (Salão/Domicilio) |

## 📋 Consultas Disponíveis

### Consultas Básicas
- **Visualização completa** de registros
- **Maior e menor** faturamento
- **Média** de valores

### Análises Avançadas (Missões)
1. **Faturamento por data e cliente**
2. **Faturamento por tipo de serviço**
3. **Definição de metas** (anual, mensal, semanal, diária)
4. **Variação percentual** entre meses
5. **Comparativo de metas** vs realizado
6. **Análise de tendência** (crescimento, queda, estabilidade)
7. **Metas dinâmicas** com margem de lucro ajustável

## 🛠️ Como Utilizar

### Pré-requisitos
- Microsoft SQL Server (2012 ou superior)
- SQL Server Management Studio (opcional)
- Permissões para criar bancos de dados

### Instalação
1. Clone este repositório:
```bash
git clone https://github.com/matheusmarquezinhub/Analise-de-Faturamento-SQL-Server.git
```

2. Execute o script completo no SQL Server:
```sql
USE master;
GO
\i Atendimento_Database.sql
```

3. Ou execute por seções conforme necessidade

### Personalização
Ajuste as variáveis de acordo com sua realidade:
```sql
-- Meta anual desejada
DECLARE @MetaAnual DECIMAL(10,2) = 80000;

-- Margem de lucro para metas dinâmicas
DECLARE @MargemLucro DECIMAL(5,2) = 15;
```

## 📊 Exemplos de Saída

### Relatório de Metas
| Ano | Mes | TotalAtual | MetaMensal | PercentualMeta | Tendencia |
|-----|-----|------------|------------|----------------|-----------|
| 2024 | 1 | 8500.00 | 6666.67 | 127.50% | Crescimento |

### Análise por Serviço
| Servico | Faturamento | Participação |
|---------|------------|--------------|
| Coloração | 3200.00 | 37.6% |
| Corte | 2800.00 | 32.9% |

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Suporte

Em caso de dúvidas ou problemas:

- **Email**: [marquuezinmatheus@gmail.com](mailto:marquuezinmatheus@gmail.com)
- **Issues**: [GitHub Issues](https://github.com/matheusmarquezinhub/analise-faturamento-sql/issues)

---

**⭐️ Se este projeto foi útil, deixe uma estrela no repositório!**

---

*Última atualização: Setembro 2025*