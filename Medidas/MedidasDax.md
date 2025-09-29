Name	Expression	DisplayFolder	Description
Eixo_	"
VAR max_val = 
MAXX(
    ALLSELECTED(dCalendario[Mes Abreviado], dCalendario[Mês]),
    [01_Metrics]*1.4
)
RETURN
max_val"		
Base	0		
01_Max	"
VAR max_val = 
MAXX(
    ALLSELECTED(dCalendario[Mes Abreviado], dCalendario[Mês]),
    [01_Metrics]
)
VAR check = IF(max_val = [01_Metrics], max_val, BLANK() )
RETURN
check"		
02_MesAnterior	"
IF(
    HASONEVALUE(dCalendario[Ano]),
    CALCULATE(
        [01_Metrics],
        DATEADD(dCalendario[Id Data],-1,MONTH)
    ),
    BLANK()
)"		
01_Metrics	"
VAR SelectedVariableOrder = SELECTEDVALUE(Metrics[Metrics Pedido])
RETURN
    SWITCH(
        SelectedVariableOrder,
        0, [Receita Bruta],
        1, [Lucro Líquido],
        2, [Quantidade de Atendimento],
        3, [% Margem Liquida],
        4, [Ticket Médio],
        BLANK()
    )"		
RT_Dinamico	"
VAR _Metrics = SELECTEDVALUE(Metrics[Metrics Pedido])

VAR _ValorAtual = 
    SWITCH(
        _Metrics,
        0, [Receita Bruta],
        1, [Lucro Líquido],
        2, [Quantidade de Atendimento],
        3, [% Margem Liquida],
        4, [Ticket Médio]
    )

VAR _TabelaDatas = ALLSELECTED(dCalendario[Id Data])

VAR _MAX = 
    MAXX(
        _TabelaDatas,
        SWITCH(
            _Metrics,
            0, [Receita Bruta],
            1, [Lucro Líquido],
            2, [Quantidade de Atendimento],
            3, [% Margem Liquida],
            4, [Ticket Médio]
        )
    )

VAR _MIN = 
    MINX(
        _TabelaDatas,
        SWITCH(
            _Metrics,
            0, [Receita Bruta],
            1, [Lucro Líquido],
            2, [Quantidade de Atendimento],
            3, [% Margem Liquida],
            4, [Ticket Médio]
        )
    )

VAR _IS_MAX = _ValorAtual = _MAX
VAR _IS_MIN = _ValorAtual = _MIN

// Escolhe o formato de acordo com a métrica
VAR _Formato = 
    SWITCH(
        _Metrics,
        3, ""0.00%"",        // % Margem Líquida
        0, ""#,##0"",        // Receita Bruta
        1, ""#,##0"",        // Lucro Líquido
        2, ""#,##0"",        // Quantidade de Atendimento
        4, ""#,##0"",        // Ticket Médio
        ""#,##0""            // padrão caso outro
    )

// Gera o texto final se for máx ou mín
RETURN
SWITCH(
    TRUE(),
    _IS_MAX, ""🟢 Máx: "" & FORMAT(_ValorAtual, _Formato),
    _IS_MIN, ""🔴 Mín: "" & FORMAT(_ValorAtual, _Formato),
    BLANK()
)
"		
Eixo Metrics	"
VAR _ReceitaBruta = 
    MAXX(
        ALLSELECTED(dCalendario[Id Data]),
        [Receita Bruta]*1.4
        )
VAR _LucroLiquido = 
     MAXX(
        ALLSELECTED(dCalendario[Id Data]),
        [Lucro Líquido]*1.4
        )
VAR _QtdAtendimento = 
     MAXX(
        ALLSELECTED(dCalendario[Id Data]),
        [Quantidade de Atendimento]*1.4
        )
VAR _Margem = 
     MAXX(
        ALLSELECTED(dCalendario[Id Data]),
        [% Margem Liquida]*1.4
        )
VAR _Ticket = 
     MAXX(
        ALLSELECTED(dCalendario[Id Data]),
        [Ticket Médio]*1.4
        )
VAR _Metrics = SELECTEDVALUE(Metrics[Metrics Pedido])

RETURN 
    SWITCH(
        _Metrics,
        0,_ReceitaBruta,
        1,_LucroLiquido,
        2,_QtdAtendimento,
        3,_Margem,
        4,_Ticket,
        BLANK()
    )
"		
KPI Label	"
Var _KPI = SELECTEDVALUE('Metrics'[Metrics Pedido])
Var _Int = ""#,##0""
Var _Percentage = ""0.0%""
Var _Currency = ""$0,,.0M""

Return
SWITCH(
    _KPI,
    0,FORMAT([Receita Bruta],_Int),
    1,FORMAT([Lucro Líquido], _Int),
    2,FORMAT([Quantidade de Atendimento], _Int),
    3,FORMAT([% Margem Liquida], _Percentage),
    4,FORMAT([Ticket Médio], _Int)

)
"		
Atualizado em	""" Atualizado em "" & SELECTEDVALUE(Atualizado[Reload])"		
Receita Bruta Variacao	DIVIDE([Receita Bruta]-[Receita Bruta Mes Anterior],[Receita Bruta Mes Anterior])	Receita Bruta\Medidas	
Quantidade de Atendimento Variacao	DIVIDE([Quantidade de Atendimento]-[Quantidade de Atendimento Mes Anterior],[Quantidade de Atendimento Mes Anterior])	Qtd	
% Margem Liquida Variacao	"
DIVIDE([% Margem Liquida] - [% Margem Liquida Mes Anterior],[% Margem Liquida Mes Anterior])"	Lucro\Medidas	
% Margem Liquida Mes Anterior	"
CALCULATE(
    [% Margem Liquida],
    DATEADD(dCalendario[Id Data],-1,MONTH
    )
)"	Lucro\Medidas	
Ticket Medio Variacao	DIVIDE([Ticket Médio]-[Ticket Medio Mes Anterior],[Ticket Medio Mes Anterior])	Lucro\Medidas	
Ticket Medio Mes Anterior	"
CALCULATE(
    [Ticket Médio],
    DATEADD(dCalendario[Id Data],-1,MONTH))"	Lucro\Medidas	
TESTE LUCRO LIQUIDO	[TESTE RECEITA LIQUIDA]-[TESTE Despesas]		
TESTE Despesas	"
SUMX(
    fDados,
    VAR Atendimento = fDados[Tipo_Atendimento]
    VAR Receita = fDados[Valores]
    VAR Pagamento = fDados[TipoPagamento]
    VAR Taxa =
        SWITCH(
            TRUE(),
            Atendimento = ""Particular"", 0,
            Pagamento = ""VE"", 0.02,
            Pagamento = ""VC"", 0.04,
            0
        )
    VAR ReceitaLiquida = Receita * (1 - Taxa)
    RETURN
        IF(Atendimento = ""Salão"", ReceitaLiquida * 0.4, 0)
)
"		
TESTE RECEITA LIQUIDA	"
SUMX(
    fDados,
    VAR Receita = fDados[Valores]
    VAR Atendimento = fDados[Tipo_Atendimento]
    VAR Pagamento = fDados[TipoPagamento]
    VAR Taxa = 
        SWITCH(
            TRUE(),
            Atendimento = ""Particular"", 0,
            Pagamento = ""VE"", 0.02,
            Pagamento = ""VC"", 0.04,
            0
        )
    RETURN
        Receita * (1 - Taxa)
)
"		
dif salao	[Valor_Pago_Salao]-[Lucro Líquido]	Pagamento Salão	
Valor_Pago_Salao	BLANK()	Pagamento Salão	
Performance_Icon_Quinzena	IF([Variacao Quinzena] < 0, [Down Arrow], [Up Arrow])	Lucro\Lucro Card Mes Atual	
SVG_Escala_FearGreed	"
VAR TotalBlocos = 46
VAR LarguraBloco = 5
VAR Espaco = 1
VAR AlturaBloco = 25
VAR LarguraTotal = (TotalBlocos * LarguraBloco) + ((TotalBlocos - 1) * Espaco)

-- Converte variação percentual em índice de bloco
VAR Variacao = 0.95 * 100
VAR Progresso = 
    MAX(0, MIN(100, 50 + Variacao / 2)) -- Normaliza para 0-100%

VAR BlocoAtual = INT(Progresso * TotalBlocos / 100)

-- Tabela de cores como fonte de dados
VAR TabelaCores = DATATABLE(
    ""Index"", INTEGER,
    ""Cor"", STRING,
    {
        {1, ""#BC1648""}, {2, ""#BC1648""}, {3, ""#BC1648""}, {4, ""#BC1648""}, {5, ""#BC1648""},
        {6, ""#D23463""}, {7, ""#D23463""}, {8, ""#D23463""}, {9, ""#D23463""}, {10, ""#D23463""},
        {11, ""#C73863""}, {12, ""#C73863""}, {13, ""#C73863""}, {14, ""#C73863""}, {15, ""#C73863""},
        {16, ""#D26284""}, {17, ""#D26284""}, {18, ""#D26284""}, {19, ""#D26284""}, {20, ""#D26284""},
        {21, ""#F6CCD9""}, {22, ""#F6CCD9""}, {23, ""#F3EFF0""}, {24, ""#BBF7D0""}, {25, ""#BBF7D0""},
        {26, ""#86EFAC""}, {27, ""#86EFAC""}, {28, ""#86EFAC""}, {29, ""#86EFAC""}, {30, ""#86EFAC""},
        {31, ""#86EFAC""}, {32, ""#86EFAC""}, {33, ""#86EFAC""}, {34, ""#86EFAC""}, {35, ""#86EFAC""},
        {36, ""#5FEB92""}, {37, ""#5FEB92""}, {38, ""#5FEB92""}, {39, ""#2DE971""}, {40, ""#2DE971""},
        {41, ""#0CBC4C""}, {42, ""#0CBC4C""}, {43, ""#0CBC4C""}, {44, ""#33A675""}, {45, ""#33A675""},
        {46, ""#33A675""}
    }
)

-- Geração dos blocos SVG
VAR Blocos =
    CONCATENATEX(
        ADDCOLUMNS(
            GENERATESERIES(1, TotalBlocos),
            ""CorBloco"", 
                MAXX(
                    FILTER(TabelaCores, [Index] = [Value]),
                    [Cor]
                )
        ),
        VAR Posicao = [Value]
        VAR CorPreenchida = [CorBloco]
        VAR CorVazia = ""#E5E7EB""
        VAR CorFinal = IF(Posicao <= BlocoAtual, CorPreenchida, CorVazia)
        RETURN
        ""<rect x='"" & ((Posicao - 1) * (LarguraBloco + Espaco)) & 
        ""' y='0' rx='2' ry='2' width='"" & LarguraBloco & 
        ""' height='"" & AlturaBloco & 
        ""' fill='"" & CorFinal & ""' />"",
        """"
    )

-- SVG final
RETURN
""
<svg viewBox='0 0 "" & LarguraTotal & "" 40' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMidYMid meet'>
  <g transform='translate(0, 12)'>
    "" & Blocos & ""
  </g>
</svg>
"""	Setas	
Quinzena Variacao Formatado Receita	"

SWITCH(
    TRUE(),
    [Variacao Quinzena Receita] > 0, "" "" & FORMAT([Variacao Quinzena Receita], ""0.0%""),
    [Variacao Quinzena Receita] < 0, "" (-"" & FORMAT(ABS([Variacao Quinzena Receita]), ""0.0%"") & "")"",
    FORMAT([Variacao Quinzena Receita], ""0.0%"")  -- valor igual a zero
)
"	Receita Bruta\Receita Card Mes Atual	
Variacao Quinzena Receita	"
DIVIDE([Quinzena Receita] - [Quinzena Anterior Receita], [Quinzena Anterior Receita])
"	Receita Bruta\Receita Card Mes Atual	
Quinzena Anterior Receita	"

VAR Hoje = TODAY()
VAR DiaHoje = DAY(Hoje)
VAR MesHoje = MONTH(Hoje)
VAR AnoHoje = YEAR(Hoje)

-- Lógica para datas da quinzena anterior
VAR DataInicialAnterior =
    IF(
        DiaHoje <= 15,
        DATE(AnoHoje, MesHoje - 1, 16),
        DATE(AnoHoje, MesHoje, 1)
    )

VAR DataFinalAnterior =
    IF(
        DiaHoje <= 15,
        EOMONTH(DATE(AnoHoje, MesHoje - 1, 1), 0),
        DATE(AnoHoje, MesHoje, 15)
    )

RETURN
    CALCULATE(
        [Receita Bruta],
        FILTER(
            dCalendario,
            dCalendario[Id Data] >= DataInicialAnterior &&
            dCalendario[Id Data] <= DataFinalAnterior
        )
    )
"	Receita Bruta\Receita Card Mes Atual	
Quinzena Variacao Formatado Lucro	"

SWITCH(
    TRUE(),
    [Variacao Quinzena] > 0, "" "" & FORMAT([Variacao Quinzena], ""0.0%""),
    [Variacao Quinzena] < 0, "" (-"" & FORMAT(ABS([Variacao Quinzena]), ""0.0%"") & "")"",
    FORMAT([Variacao Quinzena], ""0.0%"")  -- valor igual a zero
)
"	Lucro\Lucro Card Mes Atual	
Quinzena Anterior Lucro	"
VAR Hoje = TODAY()
VAR DiaHoje = DAY(Hoje)
VAR MesHoje = MONTH(Hoje)
VAR AnoHoje = YEAR(Hoje)

-- Lógica para datas da quinzena anterior
VAR DataInicialAnterior =
    IF(
        DiaHoje <= 15,
        DATE(AnoHoje, MesHoje - 1, 16),
        DATE(AnoHoje, MesHoje, 1)
    )

VAR DataFinalAnterior =
    IF(
        DiaHoje <= 15,
        EOMONTH(DATE(AnoHoje, MesHoje - 1, 1), 0),
        DATE(AnoHoje, MesHoje, 15)
    )

RETURN
    CALCULATE(
        [Lucro Líquido],
        FILTER(
            dCalendario,
            dCalendario[Id Data] >= DataInicialAnterior &&
            dCalendario[Id Data] <= DataFinalAnterior
        )
    )
"	Lucro\Lucro Card Mes Atual	
Variacao Quinzena	"
DIVIDE([Quinzena Lucro] - [Quinzena Anterior Lucro], [Quinzena Anterior Lucro])
"	Lucro\Lucro Card Mes Atual	
Variacao Ano Formatada Receita	"

SWITCH(
    TRUE(),
    [Variacao Ano Anterior % Receita] > 0, ""🡵 "" & FORMAT([Variacao Ano Anterior % Receita], ""0.0%""),
    [Variacao Ano Anterior % Receita] < 0, ""🡶 (-"" & FORMAT(ABS([Variacao Ano Anterior % Receita]), ""0.0%"") & "")"",
    FORMAT([Variacao Ano Anterior % Receita], ""0.0%"")  -- valor igual a zero
)
"	Receita Bruta\Receita Card Ano	
Variacao Ano Anterior % Receita	"
DIVIDE(
    [Receita Bruta] - [Receita Ano Anterior],[Receita Ano Anterior],0
)"	Receita Bruta\Receita Card Ano	
Performance_Icon_Receitas_Ano	IF([Variacao Ano Anterior %] < 0, [Down Arrow], [Up Arrow])	Receita Bruta\Receita Card Ano	
Receita Ano Anterior	"
CALCULATE(
    [Receita Bruta],
    SAMEPERIODLASTYEAR(dCalendario[Id Data])
)"	Receita Bruta\Receita Card Ano	
Variacao Receita Formatada Mes	"

SWITCH(
    TRUE(),
    [Variacao Receita Dinamica % Mes] > 0, "" "" & FORMAT([Variacao Receita Dinamica % Mes], ""0.0%""),
    [Variacao Receita Dinamica % Mes] < 0, "" (-"" & FORMAT(ABS([Variacao Receita Dinamica % Mes]), ""0.0%"") & "")"",
    FORMAT([Variacao Receita Dinamica % Mes], ""0.0%"")  -- valor igual a zero
)
"	Receita Bruta\Receita Card Mes Atual	
Variacao Receita Dinamica % Mes	DIVIDE([Receita Mes Atual Dinamico]-[Receita Mes Anterior Dinamico],[Receita Mes Anterior Dinamico])	Receita Bruta\Receita Card Mes Atual	
Quinzena Receita	"
VAR Hoje = TODAY()
VAR DiaHoje = DAY(Hoje)
VAR MesHoje = MONTH(Hoje)
VAR AnoHoje = YEAR(Hoje)

VAR DataInicial =
    DATE(AnoHoje, MesHoje, IF(DiaHoje <= 15, 1, 16))
VAR DataFinal =
    IF(DiaHoje <= 15,
        DATE(AnoHoje, MesHoje, 15),
        EOMONTH(Hoje, 0)
    )

RETURN
CALCULATE(
    [Receita Bruta],
    FILTER(
        dCalendario,
        dCalendario[Id Data] >= DataInicial &&
        dCalendario[Id Data] <= DataFinal
    )
)
"	Receita Bruta\Receita Card Mes Atual	
Performance_Icon_Mes_Receita	IF([Variacao Lucro Dinamica % Mes] < 0, [Down Arrow], [Up Arrow])	Receita Bruta\Receita Card Mes Atual	
Receita Mes Atual Dinamico	"

VAR DataSelecionada = 
    SELECTEDVALUE(dCalendario[Id Data], MAX(fDados[Data]))

VAR DataReferencia = 
    SWITCH(
        TRUE(),
        DataSelecionada = TODAY(), EOMONTH(TODAY(), -1)+1,
        EOMONTH(DataSelecionada, -1)+1
    )

RETURN
    CALCULATE(
        [Receita Bruta],
        FILTER(
            ALLSELECTED(dCalendario[Id Data]),
            YEAR(dCalendario[Id Data]) = YEAR(DataReferencia) &&
            MONTH(dCalendario[Id Data]) = MONTH(DataReferencia)
        )
    )
"	Receita Bruta\Receita Card Mes Atual	
Receita Mes Anterior Dinamico	"

VAR DataSelecionada = 
    SELECTEDVALUE(dCalendario[Id Data], MAX(fDados[Data]))

VAR DataReferencia = 
    SWITCH(
        TRUE(),
        DataSelecionada = TODAY(), EOMONTH(TODAY(), -1),
        EOMONTH(DataSelecionada, -1)
    )

RETURN
    CALCULATE(
        [Receita Bruta],
        FILTER(
            ALLSELECTED(dCalendario[Id Data]),
            YEAR(dCalendario[Id Data]) = YEAR(DataReferencia) &&
            MONTH(dCalendario[Id Data]) = MONTH(DataReferencia)
        )
    )
"	Receita Bruta\Receita Card Mes Atual	
Eixo Y Semana Receita	"
VAR vAtual = 
    MAXX(
    ALLSELECTED(dCalendario[Dia da Semana Abreviado],dCalendario[Dia da Semana]),
    [Receita Semana Atual Por Dia])
VAR vAnterior = 
    MAXX(
    ALLSELECTED(dCalendario[Dia da Semana Abreviado],dCalendario[Dia da Semana]),
    [Receita Semana Passada Por Dia])
VAR vResults = MAX(vAtual,vAnterior)
RETURN
    vResults*1.4"	Eixo Y	
Lucro Semana Passada Por Dia	"
VAR vSemana = WEEKNUM(TODAY(), 1)-1
VAR vAno = YEAR(TODAY())
RETURN
CALCULATE(
    [Lucro Líquido],
    FILTER(
        dCalendario,
        dCalendario[Semana] = vSemana &&
        dCalendario[Ano] = vAno
    )
)
"	Lucro\Lucro Card Semana	
Lucro Semana Atual Por Dia	"
VAR vSemana = WEEKNUM(TODAY(), 1)
VAR vAno = YEAR(TODAY())
RETURN
CALCULATE(
    [Lucro Líquido],
    FILTER(
        dCalendario,
        dCalendario[Semana] = vSemana &&
        dCalendario[Ano] = vAno
    )
)
"	Lucro\Lucro Card Semana	
Receita Semana Passada Por Dia	"
VAR vSemana = WEEKNUM(TODAY(), 1)-1
VAR vAno = YEAR(TODAY())
RETURN
CALCULATE(
    [Receita Bruta],
    FILTER(
        dCalendario,
        dCalendario[Semana] = vSemana &&
        dCalendario[Ano] = vAno
    )
)
"	Receita Bruta\Receita Card Semana	
Receita Semana Atual Por Dia	"
VAR vSemana = WEEKNUM(TODAY(), 1)
VAR vAno = YEAR(TODAY())
RETURN
CALCULATE(
    [Receita Bruta],
    FILTER(
        dCalendario,
        dCalendario[Semana] = vSemana &&
        dCalendario[Ano] = vAno
    )
)
"	Receita Bruta\Receita Card Semana	
Variacao Semana Receita Formatada	"

SWITCH(
    TRUE(),
    [Variacao Semana % Receita] > 0, "" "" & FORMAT([Variacao Semana % Receita], ""0.0%""),
    [Variacao Semana % Receita] < 0, "" (-"" & FORMAT(ABS([Variacao Semana % Receita]), ""0.0%"") & "")"",
    FORMAT([Variacao Semana % Receita], ""0.0%"")  -- valor igual a zero
)
"	Receita Bruta\Receita Card Semana	
Variacao Semana % Receita	DIVIDE([Receita Semana Atual] - [Receita Semana Passada],[Receita Semana Passada])	Receita Bruta\Receita Card Semana	
Performance_Icon_Semana_Receita	IF([Variacao Semana % Receita] < 0, [Down Arrow], [Up Arrow])	Receita Bruta\Receita Card Semana	
Receita Semana Passada	"
CALCULATE(
    [Receita Bruta],
    FILTER(
        ALL(dCalendario),
        dCalendario[Semana] = WEEKNUM(TODAY(), 1) - 1 &&
        dCalendario[Ano] = YEAR(TODAY())
            || (
                WEEKNUM(TODAY(), 1) = 1 && 
                dCalendario[Semana] = MAXX(FILTER(ALL(dCalendario), dCalendario[Ano] = YEAR(TODAY()) - 1), dCalendario[Semana]) &&
                dCalendario[Ano] = YEAR(TODAY()) - 1
            )
    )
)
"	Receita Bruta\Receita Card Semana	
Receita Semana Atual	"
CALCULATE(
    [Receita Bruta],
    FILTER(
        ALL(dCalendario),
        dCalendario[Semana] = WEEKNUM(TODAY(), 1) &&
        dCalendario[Ano] = YEAR(TODAY())
    )
)
"	Receita Bruta\Receita Card Semana	
Eixo Y Ano	"
VAR vAtual = 
    MAXX(
    ALLSELECTED(dCalendario[Mes Abreviado],dCalendario[Mês]),
    [Lucro Líquido])
VAR vAnterior = 
    MAXX(
    ALLSELECTED(dCalendario[Mes Abreviado],dCalendario[Mês]),
    [Lucro Ano Anterior])
VAR vResults = MAX(vAtual,vAnterior)
RETURN
    vResults*1.4"	Eixo Y	
Eixo Y Semana Lucro	"
VAR vAtual = 
    MAXX(
    ALLSELECTED(dCalendario[Dia da Semana Abreviado],dCalendario[Dia da Semana]),
    [Lucro Semana Atual Por Dia])
VAR vAnterior = 
    MAXX(
    ALLSELECTED(dCalendario[Dia da Semana Abreviado],dCalendario[Dia da Semana]),
    [Lucro Semana Passada Por Dia])
VAR vResults = MAX(vAtual,vAnterior)
RETURN
    vResults*1.4"	Eixo Y	
Eixo Y -	"
MAXX(
    ALL(dServico),
    [Lucro Líquido]
)*0.5"	Eixo Y	
Eixo Y +	"
MAXX(
    ALL(dServico),
    [Lucro Líquido]
)*1.4"	Eixo Y	
Ticket Médio	"
DIVIDE(
    [Lucro Líquido], 
    COUNT(fDados[ID_Dados]),
    0
)
"	Lucro\Medidas	
Performance_Icon_Semana	IF([Variacao Semana %] < 0, [Down Arrow], [Up Arrow])	Lucro\Lucro Card Semana	
Performance_Icon_Ano	IF([Variacao Ano Anterior %] < 0, [Down Arrow], [Up Arrow])	Lucro\Lucro Card Ano	
Performance_Icon_Mes	IF([Variacao Lucro Dinamica % Mes] < 0, [Down Arrow], [Up Arrow])	Lucro\Lucro Card Mes Atual	
Up Arrow	"""data:image/png;base64,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T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoFCACau0/tCCCAAAJqBQgAaltP4QgggAACmgUIAJq7T+0IIIAAAmoFCABqW0/hCCCAAAKaBQgAmrtP7QgggAACagUIAGpbT+EIIIAAApoF/h9thfgg+LPJrgAAAABJRU5ErkJggg=="""	Setas	
Down Arrow	"""data:image/png;base64,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"""	Setas	
Dif Margem	1-[% Margem Liquida]	Lucro\Medidas	
zero	0	Lucro\Medidas	
Variacao Ano Formatada	"

SWITCH(
    TRUE(),
    [Variacao Ano Anterior %] > 0, ""🡵 "" & FORMAT([Variacao Ano Anterior %], ""0.0%""),
    [Variacao Ano Anterior %] < 0, ""🡶 (-"" & FORMAT(ABS([Variacao Ano Anterior %]), ""0.0%"") & "")"",
    FORMAT([Variacao Ano Anterior %], ""0.0%"")  -- valor igual a zero
)
"	Lucro\Lucro Card Ano	
Variacao Semana Formatada	"

SWITCH(
    TRUE(),
    [Variacao Semana %] > 0, "" "" & FORMAT([Variacao Semana %], ""0.0%""),
    [Variacao Semana %] < 0, "" (-"" & FORMAT(ABS([Variacao Semana %]), ""0.0%"") & "")"",
    FORMAT([Variacao Semana %], ""0.0%"")  -- valor igual a zero
)
"	Lucro\Lucro Card Semana	
Variacao Ano Anterior %	"
DIVIDE(
    [Lucro Líquido] - [Lucro Ano Anterior],[Lucro Ano Anterior],0
)"	Lucro\Lucro Card Ano	
Lucro Ano Anterior	"
CALCULATE(
    [Lucro Líquido],
    SAMEPERIODLASTYEAR(dCalendario[Id Data])
)"	Lucro\Lucro Card Ano	
Variacao Semana %	DIVIDE([Lucro Semana Atual] - [Lucro Semana Passada],[Lucro Semana Passada])	Lucro\Lucro Card Semana	
Semana Passada - Intervalo	"
VAR Hoje = TODAY()
VAR SemanaAtual = WEEKNUM(Hoje, 1) -- 
VAR AnoAtual = YEAR(Hoje)

-- Filtra a semana passada
VAR DatasSemanaPassada =
    FILTER(
        ALL(dCalendario),
        dCalendario[Semana] = SemanaAtual - 1 &&
        dCalendario[Ano] = AnoAtual
    )

-- Captura menor e maior data da semana passada
VAR DataInicial = MINX(DatasSemanaPassada, dCalendario[Id Data])
VAR DataFinal = MAXX(DatasSemanaPassada, dCalendario[Id Data])

-- Retorna o texto formatado
RETURN
""de "" &
FORMAT(DataInicial, ""dd/MM"") & 
"" a "" &
FORMAT(DataFinal, ""dd/MM"")
"	Lucro\Lucro Card Semana	
Lucro Semana Passada	"
CALCULATE(
    [Lucro Líquido],
    FILTER(
        ALL(dCalendario),
        dCalendario[Semana] = WEEKNUM(TODAY(), 1) - 1 &&
        dCalendario[Ano] = YEAR(TODAY())
            || (
                WEEKNUM(TODAY(), 1) = 1 && 
                dCalendario[Semana] = MAXX(FILTER(ALL(dCalendario), dCalendario[Ano] = YEAR(TODAY()) - 1), dCalendario[Semana]) &&
                dCalendario[Ano] = YEAR(TODAY()) - 1
            )
    )
)
"	Lucro\Lucro Card Semana	
Lucro Semana Atual	"
CALCULATE(
    [Lucro Líquido],
    FILTER(
        ALL(dCalendario),
        dCalendario[Semana] = WEEKNUM(TODAY(), 1) &&
        dCalendario[Ano] = YEAR(TODAY())
    )
)
"	Lucro\Lucro Card Semana	
Variação Lucro Líquido QMS	"
VAR vAtual = [Lucro Líquido por Periodo QMS]
VAR vAnterior = [Lucro Líquido por Periodo Anterior QMS]

RETURN
    DIVIDE(vAtual - vAnterior, vAnterior, 0)
"	Lucro\Lucro Líquido QMS	
Lucro Líquido por Periodo QMS Formatado	"
VAR vTotal = [Lucro Líquido por Periodo QMS]
VAR vTotalForm = 
    SWITCH(
        TRUE(),
        vTotal >= 1000000000, FORMAT(vTotal, ""R$ #,0,,,.00 Bi""),  -- Receita/Lucro em bilhões
        vTotal >= 1000000, FORMAT(vTotal, ""R$ #,0,,.00 Mi""),       -- em milhões
        vTotal >= 1000, FORMAT(vTotal, ""R$ #,0,.00 K""),            -- em mil
        FORMAT(vTotal, ""R$ #,0"")                                -- padrão
    )
RETURN
    vTotalForm"	Lucro\Lucro Líquido QMS	
Lucro Líquido por Periodo QMS Anterior Formatado	"
VAR vTotal = [Lucro Líquido por Periodo Anterior QMS]
VAR vTotalForm = 
    SWITCH(
        TRUE(),
        vTotal >= 1000000000, FORMAT(vTotal, ""R$ #,0,,,.00 Bi""),  -- Receita/Lucro em bilhões
        vTotal >= 1000000, FORMAT(vTotal, ""R$ #,0,,.00 Mi""),       -- em milhões
        vTotal >= 1000, FORMAT(vTotal, ""R$ #,0,.00 K""),            -- em mil
        FORMAT(vTotal, ""R$ #,0"")                                -- padrão
    )
RETURN
    vTotalForm"	Lucro\Lucro Líquido QMS	
Lucro Líquido por Periodo QMS	"
VAR vPeriodo = SELECTEDVALUE(Period[Period Pedido])

VAR vLucroMes =
    CALCULATE(
        [Lucro Líquido],
        REMOVEFILTERS(Period)
    )

VAR vLucroTrimestre =
    CALCULATE(
        [Lucro Líquido],
        REMOVEFILTERS(Period)
    )

VAR SemanaAtual = WEEKNUM(TODAY(), 2)
VAR vLucroSemana =
    CALCULATE(
        [Lucro Líquido],
        REMOVEFILTERS(Period),
        KEEPFILTERS(
            dCalendario[Semana] = SemanaAtual &&
            dCalendario[Ano] = YEAR(TODAY())
        )
    )

VAR vResultado =
    SWITCH(
        vPeriodo,
        0, vLucroTrimestre,
        1, vLucroMes,
        2, vLucroSemana,
        BLANK()
    )

RETURN
    vResultado
"	Lucro\Lucro Líquido QMS	
Lucro Líquido por Periodo Anterior QMS	"
VAR vPeriodo = SELECTEDVALUE(Period[Period Pedido])

-- Semana anterior (baseada em semana do ano)
VAR SemanaAnterior = WEEKNUM(TODAY(), 2) - 1
VAR AnoAtual = YEAR(TODAY())

-- Medidas por período
VAR vMesAnterior =
    CALCULATE(
        [Lucro Líquido],
        DATEADD(dCalendario[Id Data], -1, MONTH),
        REMOVEFILTERS(Period)
    )

VAR vTrimestreAnterior =
    CALCULATE(
        [Lucro Líquido],
        DATEADD(dCalendario[Id Data], -1, QUARTER),
        REMOVEFILTERS(Period)
    )

VAR vSemanaAnterior =
    CALCULATE(
        [Lucro Líquido],
        REMOVEFILTERS(Period),
        FILTER(
            dCalendario,
            dCalendario[Semana] = SemanaAnterior &&
            dCalendario[Ano] = AnoAtual
        )
    )

RETURN
    SWITCH(
        vPeriodo,
        0, vTrimestreAnterior,
        1, vMesAnterior,
        2, vSemanaAnterior,
        BLANK()
    )
"	Lucro\Lucro Líquido QMS	
Variacao Lucro Formatada Mes	"

SWITCH(
    TRUE(),
    [Variacao Lucro Dinamica % Mes] > 0, "" "" & FORMAT([Variacao Lucro Dinamica % Mes], ""0.0%""),
    [Variacao Lucro Dinamica % Mes] < 0, "" (-"" & FORMAT(ABS([Variacao Lucro Dinamica % Mes]), ""0.0%"") & "")"",
    FORMAT([Variacao Lucro Dinamica % Mes], ""0.0%"")  -- valor igual a zero
)
"	Lucro\Lucro Card Mes Atual	
Variacao Lucro Dinamica % Mes	DIVIDE([Lucro Líquido Mes Atual Dinamico]-[Lucro Líquido Mes Anterior Dinamico],[Lucro Líquido Mes Anterior Dinamico])	Lucro\Lucro Card Mes Atual	
Quinzena Lucro	"
VAR Hoje = TODAY()
VAR DiaHoje = DAY(Hoje)
VAR MesHoje = MONTH(Hoje)
VAR AnoHoje = YEAR(Hoje)

VAR DataInicial = DATE(AnoHoje, MesHoje, IF(DiaHoje <= 15, 1, 16))
VAR DataFinal = IF(DiaHoje <= 15,DATE(AnoHoje, MesHoje, 15),EOMONTH(Hoje, 0))

RETURN
CALCULATE(
    [Lucro Líquido],
    FILTER(
        dCalendario,
        dCalendario[Id Data] >= DataInicial &&
        dCalendario[Id Data] <= DataFinal
    )
)
"	Lucro\Lucro Card Mes Atual	
Lucro Líquido Mes Atual Dinamico	"

VAR DataSelecionada = 
    SELECTEDVALUE(dCalendario[Id Data], MAX(fDados[Data]))

VAR DataReferencia = 
    SWITCH(
        TRUE(),
        DataSelecionada = TODAY(), EOMONTH(TODAY(), -1)+1,
        EOMONTH(DataSelecionada, -1)+1
    )

RETURN
    CALCULATE(
        [Lucro Líquido],
        FILTER(
            ALLSELECTED(dCalendario[Id Data]),
            YEAR(dCalendario[Id Data]) = YEAR(DataReferencia) &&
            MONTH(dCalendario[Id Data]) = MONTH(DataReferencia)
        )
    )
"	Lucro\Lucro Card Mes Atual	
Lucro Líquido Mes Anterior Dinamico	"

VAR DataSelecionada = 
    SELECTEDVALUE(dCalendario[Id Data], MAX(fDados[Data]))

VAR DataReferencia = 
    SWITCH(
        TRUE(),
        DataSelecionada = TODAY(), EOMONTH(TODAY(), -1),
        EOMONTH(DataSelecionada, -1)
    )

RETURN
    CALCULATE(
        [Lucro Líquido],
        FILTER(
            ALLSELECTED(dCalendario[Id Data]),
            YEAR(dCalendario[Id Data]) = YEAR(DataReferencia) &&
            MONTH(dCalendario[Id Data]) = MONTH(DataReferencia)
        )
    )
"	Lucro\Lucro Card Mes Atual	
Card Mês Atual - Intervalo	"
VAR DataAtual = TODAY()
VAR DataInicial = DATE(YEAR(DataAtual), MONTH(DataAtual), 1)
VAR DataFinal = EOMONTH(DataAtual, 0)
RETURN ""de "" & FORMAT(DataInicial, ""dd/MM"") & "" a "" & FORMAT(DataFinal, ""dd/MM"")"	Lucro\Lucro Card Mes Atual	
Lucro Líquido Variacao	"
DIVIDE(
    [Lucro Líquido] - [Lucro Líquido Mes Anterior],[Lucro Líquido Mes Anterior]
)"	Lucro\Medidas	
Mes Lucro Formatado	"
VAR vTotal = [Lucro Líquido]
VAR vTotalForm = 
    SWITCH(
        TRUE(),
        vTotal >= 1000000000, FORMAT(vTotal, ""R$ #,0,,,.00 Bi""),  -- Receita/Lucro em bilhões
        vTotal >= 1000000, FORMAT(vTotal, ""R$ #,0,,.00 Mi""),       -- em milhões
        vTotal >= 1000, FORMAT(vTotal, ""R$ #,0,.00 K""),            -- em mil
        FORMAT(vTotal, ""R$ #,0"")                                -- padrão
    )
RETURN
    vTotalForm"	Lucro\Medidas	
Mes Anterior  Formatado	"
VAR vTotal = [Lucro Líquido Mes Anterior]
VAR vTotalForm = 
    SWITCH(
        TRUE(),
        vTotal >= 1000000000, FORMAT(vTotal, ""R$ #,0,,,.00 Bi""),  -- Receita/Lucro em bilhões
        vTotal >= 1000000, FORMAT(vTotal, ""R$ #,0,,.00 Mi""),       -- em milhões
        vTotal >= 1000, FORMAT(vTotal, ""R$ #,0,.00 K""),            -- em mil
        FORMAT(vTotal, ""R$ #,0"")                                -- padrão
    )
RETURN
    vTotalForm"	Lucro\Medidas	
Lucro Líquido Mes Anterior	"
CALCULATE(
    [Lucro Líquido],
    DATEADD(dCalendario[Id Data],-1,MONTH
    )
)"	Lucro\Medidas	
Lucro Líquido	"[Receita Líquida] - [Despesas]

"	Lucro\Medidas	
% Margem Liquida	"
    DIVIDE(
        [Lucro Líquido],[Receita Bruta]
    )"	Lucro\Medidas	
TitleOvertime	""" Lucro Líquido"" & "" por "" & MAX('Period'[Selected Period])"	Titles	
Eixo Y Parametro (Max Atual ou Anterior)	"
VAR vParametro = SELECTEDVALUE(Metrics[Metrics Pedido])

VAR vMetricaAtual =
    SWITCH(
        vParametro,
        0, [Receita Bruta],
        1, [Quantidade de Atendimento],
        2, [Lucro Líquido],
        BLANK()
    )

VAR vMetricaAnterior =
    CALCULATE(
        vMetricaAtual,
        DATEADD(dCalendario[Id Data], -1, MONTH)
    )

RETURN
    MAX(vMetricaAtual, vMetricaAnterior)*1.2
"	Eixo Y	
Quantidade de Atendimento Mes Anterior	"
CALCULATE(
    [Quantidade de Atendimento],
    DATEADD(dCalendario[Id Data],-1,MONTH))"	Qtd	
Receita Bruta Mes Anterior	"
CALCULATE(
    [Receita Bruta],
    DATEADD(dCalendario[Id Data],-1,MONTH))"	Receita Bruta\Medidas	
Taxa_Maquininha	SUM(dPagamento[Taxa])	Taxa	
Receita Líquida	"
//SUMX(
//    fDados,
//    VAR Receita = fDados[Valores]
//    VAR Taxa =
//        SWITCH(
//            fDados[TipoPagamento],
//            ""VE"", 0.02,
//            ""VC"", 0.04,
//            0
//        )
//    RETURN Receita * (1 - Taxa)
//)
SUMX(
    fDados,
    VAR Receita = fDados[Valores]
    VAR Atendimento = fDados[Tipo_Atendimento]
    VAR Pagamento = fDados[TipoPagamento]
    VAR Taxa = 
        SWITCH(
            TRUE(),
            Atendimento = ""Particular"", 0,
            Pagamento = ""VE"", 0.02,
            Pagamento = ""VC"", 0.04,
            0
        )
    RETURN
        Receita * (1 - Taxa)
)
"	Receita Líquida	
Receita Bruta	"SUM(fDados[Valores])

"	Receita Bruta\Medidas	
Quantidade de Atendimento	DISTINCTCOUNT(fDados[ID_Dados])	Qtd	
Despesas	"//[Receita Líquida] * 0.4

SUMX(
    fDados,
    VAR Atendimento = fDados[Tipo_Atendimento]
    VAR Receita = fDados[Valores]
    VAR Pagamento = fDados[TipoPagamento]
    VAR Taxa =
        SWITCH(
            TRUE(),
            Atendimento = ""Particular"", 0,
            Pagamento = ""VE"", 0.02,
            Pagamento = ""VC"", 0.04,
            0
        )
    VAR ReceitaLiquida = Receita * (1 - Taxa)
    RETURN
        IF(Atendimento = ""Salão"", ReceitaLiquida * 0.4, 0)
)