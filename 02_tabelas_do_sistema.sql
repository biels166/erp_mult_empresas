-- CRIANDO A TABELA EMPRESA
CREATE TABLE EMPRESA 
             (
              cod_empresa int not null PRIMARY KEY,
              nome_empresa varchar2(50),
              fantasia varchar2(15)
             );
             --criando sequencia para o codigo empresa
             CREATE SEQUENCE SEQ_EMP 
             start with 1 increment by 1 nomaxvalue;

-- CADASTRO DE UNIDADE FEDERAL, UTLIZADO POR TODAS EMPRESAS
CREATE TABLE UF
             (
              cod_uf varchar2(2) not null PRIMARY KEY,
              sigla_uf varchar2(2) not null,
              nome_uf varchar2(30) not null
             );

-- CADASTRO DE CIDADES, UTLIZADO POR TODAS EMPRESAS
CREATE TABLE CIDADES
             (
              cod_cidade varchar2(7) not null PRIMARY KEY,
              cod_uf varchar2(2) not null,
              nome_cidade varchar2(50) not null,
              constraint fk_cid1 FOREIGN KEY (cod_uf) REFERENCES UF(cod_uf)
             );

--CRIANDO TABELAS CLIENTES
CREATE TABLE CLIENTES	
             (
              cod_empresa int not null,
              id_cliente int not null PRIMARY KEY,
              razao_cliente varchar2(100)not null,
              fantasia varchar2(15) not null,
              endereco varchar2(50) not null,
              nro varchar2(10) not null,
              bairro varchar2(20) not null,
              cod_cidade varchar2(7) not null,
              cep varchar2(8),
              cnpj_cpf varchar2(15),
              tipo_cliente char(1) constraint ck_tc1 check (tipo_cliente in ('F', 'J')),
              data_cadastro date not null,
              cod_pagto int ,
              constraint fk_cod_emp1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint fk_cli1 FOREIGN KEY (cod_cidade) REFERENCES CIDADES(cod_cidade)
             );
             -- criando sequencia para clientes;  
             CREATE SEQUENCE SEQ_CLI 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO TABELA FORNECEDORES
CREATE TABLE FORNECEDORES
             (
              cod_empresa int not null,
              id_for int  not null primary key,
              razao_fornec varchar2(100)not null,
	          fantasia varchar2(15) not null,
	          endereco varchar2(50) not null,
              nro varchar2(10) not null,
              bairro varchar2(20) not null,
              cod_cidade varchar2(7) not null,
              cep varchar2(8),
              cnpj_cpf varchar2(15),
              tipo_fornec char(1) constraint ck_tf1 check (tipo_fornec in ('F', 'J')),
              data_cadastro date not null,
              cod_pagto int ,
              constraint fk_cod_emp2 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint fk_for1 FOREIGN KEY (cod_cidade) REFERENCES CIDADES(cod_cidade)
             );
             -- criando sequencia para fornecedores;  
             CREATE SEQUENCE SEQ_FOR 
             start with 1 increment by 1 nomaxvalue;

--TABELAS TIPO DE MATERIAL
CREATE TABLE TIPO_MAT
             (
              cod_tip_mat int  not null PRIMARY KEY,
              desc_tip_mat varchar2(20) not null
             );
             -- criando sequencia tipo material
             CREATE SEQUENCE SEQ_TIP_MAT 
             start with 1 increment by 1 nomaxvalue;
 
--CRIANDO TABELAS MATERIAL
CREATE TABLE MATERIAL
             (
              cod_empresa int not null,
              cod_mat int not null,
              descricao varchar2(50) not null,
              preco_unit decimal(10,2) not null,
              cod_tip_mat int not null,
              constraint fk_cod_emp3 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint fk_mat1 FOREIGN KEY (cod_tip_mat) REFERENCES TIPO_MAT(cod_tip_mat),
              constraint pk_emp_mat PRIMARY KEY (cod_empresa,cod_mat) -- PK Composta, para que não haja informação duplicada.
             );

-- CRIANDO TABELA DE MATERIAL POR FORNECEDOR 
CREATE TABLE MAT_FORNEC
             (
              cod_empresa int not null,
              cod_mat int not null,
              id_for int not null,
              constraint fk_mat_for1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint fk_mar_for2 FOREIGN KEY (id_for) REFERENCES FORNECEDORES(id_for),
              constraint pk_mat_for PRIMARY KEY (cod_empresa,cod_mat,id_for) -- PK Composta, para que não haja informação duplicada.
             );

--CRIANDO INDEX
--CREATE INDEX IX_MAT1 on MATERIAL(cod_empresa,cod_mat); (Por ser chave primária, o indice é criado automaticamente)
--CRIANDO INDEX TIPO MAT
CREATE INDEX IX_MAT2 on MATERIAL(cod_tip_mat);

--CRIANDO TABEL DE ORDEM DE PRODUCAO
CREATE TABLE ORDEM_PROD
             (
              cod_empresa int not null,
              id_ordem int not null PRIMARY KEY,
              cod_mat_prod int not null,
              qtd_plan decimal(10,2) not null,
              qtd_prod decimal(10,2) not null,
              data_ini date,
              data_fim date,
              situacao char(1) constraint ck_op1 check (situacao in ('A','P','F')),--A-ABERTA, P-PLANEJADA -F-FECHADA
              constraint fk_op1 FOREIGN KEY (cod_mat_prod,cod_empresa) REFERENCES MATERIAL(cod_mat,cod_empresa), -- Se é uma PK Composta, deve ser referenciada como FK Composta.
              constraint fk_cod_emp4 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa) 
             );
             --CRIANDO SEQUENCIA ORDEM DE PRODUCAO
             CREATE SEQUENCE SEQ_OP 
             start with 1 increment by 1 nomaxvalue;
    
--CRIACAO DE TABELAS APONTAMENTOS DE PRODUCAO / controle de produção por exemplo
CREATE TABLE APONTAMENTOS
             (
              cod_empresa int not null,
              id_apon int not null PRIMARY KEY,
              id_ordem int not null,
              cod_mat_prod int,
              qtd_apon decimal(10,2),
              data_apon date not null,
              constraint fk_ap1 FOREIGN KEY (cod_mat_prod,cod_empresa) REFERENCES MATERIAL(cod_mat,cod_empresa),
              constraint fk_apon1 FOREIGN KEY (id_ordem) references ORDEM_PROD(id_ordem)
             );
             -- CRIANDO SEQUENCIA PARA TABELA APONTAMENTOS
             CREATE SEQUENCE SEQ_APON 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO DA TABELA FICHA TECNICA
CREATE TABLE FICHA_TECNICA
             (
              cod_empresa int not null,
              cod_mat_prod int not null,
              cod_mat_neces int not null,
              qtd_neces decimal(10,2) not null,
              constraint fk_fic1 FOREIGN KEY (cod_empresa,cod_mat_prod) REFERENCES MATERIAL(cod_empresa,cod_mat),
              constraint fk_fic2 FOREIGN KEY (cod_empresa,cod_mat_neces) references MATERIAL(cod_empresa,cod_mat)
             );
             -- CRIANDO SEQUENCIA PARA TABELA FICHA_TECNICA
             CREATE SEQUENCE SEQ_FT 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO DA TABELA CONSUMO
CREATE TABLE CONSUMO -- Consumo de Materiais
             (
              id_apon int not null,
              cod_empresa int not null,
              cod_mat_neces int not null,
              qtd_consumida decimal(10,2) not null,
              lote varchar2(20) not null,
              constraint fk_cons1 FOREIGN KEY (cod_empresa,cod_mat_neces) REFERENCES MATERIAL(cod_empresa,cod_mat), 
              constraint fk_cons2 FOREIGN KEY (id_apon ) REFERENCES APONTAMENTOS( id_apon )
             );

--CRIANDO TABELAS DE SUPRIMENTOS
CREATE TABLE ESTOQUE
             (
              cod_empresa int not null,
              cod_mat int not null,
              qtd_saldo decimal(10,2) not null,
              constraint fk_est1 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat),
              constraint pk_estoque1 PRIMARY KEY (cod_empresa,cod_mat) -- PK Composta, para que não haja informação duplicada.
             );
    
--CRIACAO TABELAS ESTOQUE_LOTE
CREATE TABLE ESTOQUE_LOTE
             (
              cod_empresa int not null,
              cod_mat int not null,
              lote varchar2(20) not null,
              qtd_lote decimal(10,2) not null,
              constraint pk_estl1 PRIMARY KEY (cod_empresa,cod_mat,lote), 
              constraint fk_estl1 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat)
             );
             
--CRIACAO TABELA MOV ESTOQUE
CREATE TABLE ESTOQUE_MOV
             (
              id_mov int  not null PRIMARY KEY,
              cod_empresa int not null,
              tip_mov varchar2(1),constraint ck_mov check (tip_mov in ('S','E')), --S=SAIDA ,E=ENTRADA
              cod_mat int not null,
              lote  varchar2(20) not null,
              qtd decimal(10,2) not null,
              data_mov date not null,
              data_hora date not null,
              constraint fk_estm1 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat)
             );
             -- CRIANDO SEQUENCIA PARA TABELA ESTOQUE_MOV
             CREATE SEQUENCE SEQ_MOVEST 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO TABELAS PED_COMPRAS
CREATE TABLE PED_COMPRAS
             (
              cod_empresa int not null,
              num_pedido int  not null,
              id_for int not null,
              cod_pagto int not null, --ALTERAR  COD_PAGTO TAB PED_COMPRAS PARA FOREIGN KEY APOS TABELA COND_PAGTO  	
              data_pedido date not null,
              data_entrega date not null,
              situacao nchar(1) not null, --A-ABERTO P-PLANEJADO -F FINALIZADO
              total_ped decimal(10,2),
              constraint fk_pedc1 FOREIGN KEY (id_for) REFERENCES FORNECEDORES(id_for),
              constraint pk_pedc1 PRIMARY KEY (cod_empresa,num_pedido)
             );
    
-- CRIACAO DE TABELA DE PARAMETROS DE NUMEROS DE PEDIDO POR EMPRESA
CREATE TABLE PARAM_PED_COMPRAS
             (
              cod_empresa int not null PRIMARY KEY,
              num_ped int not null,
              constraint fk_ppc FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
     
--CRIACAO DA TABELA PEDIDO COMPRAS
CREATE TABLE PED_COMPRAS_ITENS
             (
              cod_empresa int not null,
              num_pedido int not null,
              seq_mat int not null,
              cod_mat int not null,
              qtd int not null,
              val_unit decimal(10,2) not null,
              constraint fk_pedit1 FOREIGN KEY (cod_empresa,num_pedido) REFERENCES PED_COMPRAS(cod_empresa,num_pedido),
              constraint fk_pedit2 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat),
              constraint pk_ped_c_it PRIMARY KEY (cod_empresa,num_pedido,seq_mat)
             );
	
--CRIACAO TABELAS CENTRO DE CUSTO
CREATE TABLE CENTRO_CUSTO
             (
              cod_empresa int not null,
              cod_cc varchar2(4) not null,
              nome_cc varchar2(20) not null,
              constraint fk_cc1  FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint pk_cc1 PRIMARY KEY (cod_empresa,cod_cc)
             );

--CRIACAO TABELAS CARGOS
CREATE TABLE CARGOS 
             (
              cod_empresa int not null,
              cod_cargo int  not null,
              nome_cargo varchar2(50),
              constraint fk_carg1  FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint pk_carg1 PRIMARY KEY (cod_empresa,cod_cargo)
             );
             
--CRIACAO TABELA FUNCIONARIO
CREATE TABLE FUNCIONARIO 
             (
              cod_empresa int not null,
              matricula int not null ,
              cod_cc varchar2(4) not null,
              nome varchar2(50) not null,
              rg varchar2(15) not null,
              cpf varchar2(15) not null,
              endereco  varchar2(50)not null,
              numero varchar2(10) not null,
              bairro varchar2(50) not null,
              cod_cidade varchar2(7) not null,
              data_admiss date not null,
              date_demiss date,
              data_nasc date not null,
              telefone varchar2(15) not null,
              cod_cargo int not null,
              constraint fk_func1 FOREIGN KEY (cod_empresa,cod_cc) REFERENCES CENTRO_CUSTO(cod_empresa,cod_cc),
              constraint fk_func2 FOREIGN KEY (cod_cidade) REFERENCES CIDADES(cod_cidade),
              constraint fk_func3 FOREIGN KEY (cod_empresa,cod_cargo) REFERENCES CARGOS(cod_empresa,cod_cargo),
              constraint pk_func1 PRIMARY KEY(cod_empresa,matricula)
            );

-- TABELAS DE PARAMETROS DE MATRICULA POR EMPRESA
 CREATE TABLE PARAM_MATRICULA
              (
               cod_empresa int not null primary key,
               matricula int not null,
               constraint fk_pmat1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
              );

--CRIACAO TABELA SALARIO
CREATE TABLE SALARIO
             (
              cod_empresa int not null,
              matricula int not null,
              salario decimal(10,2)not null,
              constraint fk_sal1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula),
              constraint pk_sal1 PRIMARY KEY (cod_empresa,matricula) 
             );
             
--CRIACAO TABLE FOLHA DE PAGTO
CREATE TABLE FOLHA_PAGTO
             (
              cod_empresa int not null,
              matricula int not null,
              tipo_pgto char(1) not null, -- (M-FOLHA,A-ADTO,F-FERIAS,D-13º,R-RESC),
              tipo char(1) not null, -- (P=PROVENTOS D=DESCONTO)
              evento varchar2(30) not null, 
              mes_ref varchar2(2)not null,
              ano_ref varchar2(4)not null,
              data_pagto date not null,
              valor decimal(10,2) not null,
              constraint fk_fp1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula)
             );
    
-- CRIANDO INDEX PARA OTIMARIZAR CONSULTAS
CREATE INDEX IX1_FPAG on FOLHA_PAGTO(cod_empresa,mes_ref,ano_ref);

--CRIACAO TA TABELAS USARIOS 
CREATE TABLE USUARIOS
             (
              cod_empresa int not null,
              login varchar2(30) not null ,
              matricula int not null,
              senha varchar2(32) not null,
              situacao char(1) not null, -- A=ATIVO B=BLOQUEADO
              constraint fk_us1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula),
              constraint pk_user PRIMARY KEY (cod_empresa,matricula)
             );
    
-- CRIANDO INDEX UNIQUE PARA LOGIN
CREATE UNIQUE INDEX IX1_USER on USUARIOS(login);

-- CRIACAO TABELA CONTAS A RECEBER
CREATE TABLE CONTAS_RECEBER
	         (
              cod_empresa int not null,
              id_doc int  not null PRIMARY KEY,
              id_cliente int not null,
              id_doc_orig int not null, -- ALTER CAMPO ID_DOC_ORIG PARA FK TABELA NOTA_FISCAL
              parc int not null,
              data_venc date not null,
              data_pagto date,
              valor decimal(10,2),
              constraint fk_cr1 FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente),
              constraint fk_cr2 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
             -- CRIANDO SEQUENCIA PARA TABELA CONTAS_RECEBER
             CREATE SEQUENCE SEQ_CRE 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO TABELA CONTAS A PAGAR
CREATE TABLE CONTAS_PAGAR
             (
              cod_empresa int not null,
              id_doc int  not null PRIMARY KEY,
              id_for int not null,
              id_doc_orig int not null, -- ALTER CAMPO ID_DOC_ORIG PARA FK TABELA NOTA_FISCAL
              parc int not null,
              data_venc date not null,
              data_pagto date ,
              valor decimal(10,2),
              constraint fk_cp1 FOREIGN KEY (id_for) REFERENCES FORNECEDORES(id_for),
              constraint fk_cp2 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
             -- CRIANDO SEQUENCIA PARA TABELA CONTAS_PAGAR
             CREATE SEQUENCE SEQ_CAP 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO TABELA CONDIÇÕES DE PAGTO
CREATE TABLE COND_PAGTO
             (
              cod_pagto int  not null PRIMARY KEY,
              nome_cp varchar2(50) not null 
             );
             -- CRIANDO SEQUENCIA PARA TABELA COND_PAGTO
             CREATE SEQUENCE SEQ_PAGTO 
             start with 1 increment by 1 nomaxvalue;

--CRIACAO DA TABELAS DETALHES DE CONDICAO DE PAGTO COM PARCELA
CREATE TABLE COND_PAGTO_DET
             (
              cod_pagto int not null,
              parc int not null,
              dias int not null,
              pct decimal(10,2)not null, -- PERCENTUAL DA PARCELA
              constraint fk_condp1 FOREIGN KEY (cod_pagto) REFERENCES COND_PAGTO(cod_pagto)
             );

--CRIACAO TABELA PEDIDO DE VENDAS
CREATE TABLE PED_VENDAS
	         (
              cod_empresa int not null,
              num_pedido int  not null,
              id_cliente int not null,
              cod_pagto int not null, 
              data_pedido date not null,
              data_entrega date not null,
              situacao nchar(1) not null, -- A-ABERTO P-PLANEJADO F-FINALIZADO
              total_ped decimal(10,2),
              constraint fk_pv1 FOREIGN KEY (id_cliente)REFERENCES CLIENTES(id_cliente),
              constraint fk_pv2 FOREIGN KEY (cod_pagto) REFERENCES COND_PAGTO(cod_pagto),
              constraint fk_pv3 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa),
              constraint pk_pv1 PRIMARY KEY (cod_empresa,num_pedido)
             );
    
-- CRIACAO DE TABELA DE PARAMETROS DE NUMEROS DE PEDIDO DE VENDAS POR EMPRESA
CREATE TABLE PARAM_PED_VENDAS
             (
              cod_empresa int not null PRIMARY KEY,
              num_ped int not null,
              constraint fk_pv FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
    
--CRIACAO DA TABELA PEDIDO VENDAS ITENS
CREATE TABLE PED_VENDAS_ITENS
             (
              cod_empresa int not null,
              num_pedido int not null,
              seq_mat int not null,
              cod_mat int not null,
              qtd int not null,
              val_unit decimal(10,2) not null,
              constraint fk_pvit1 FOREIGN KEY (cod_empresa,num_pedido) REFERENCES PED_VENDAS(cod_empresa,num_pedido),
              constraint fk_pvit2 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat)
             );

--CRIACAO TABELAS VENDEDORES
CREATE TABLE VENDEDORES
             (
              cod_empresa int not null,
              id_vend int not null,
              matricula int not null,
              constraint fk_vend1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula),
              constraint pk_vend1 PRIMARY KEY (cod_empresa,matricula)
             );
             -- CRIANDO SEQUENCIA PARA COD DO VENDEDOR
             CREATE SEQUENCE SEQ_VENDEDORES 
             start with 1 increment by 1 nomaxvalue;
    
--CRIACAO DE TAB GERENTES DE VENDAS
CREATE TABLE GERENTES
             ( 
              cod_empresa int not null,
              id_ger int  not null,
              matricula int not null,
              constraint fk_ger1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula),
              constraint pk_ger1 PRIMARY KEY (cod_empresa,matricula)
             );
             -- CRIANDO SEQUENCIA PARA COD DO VENDEDOR
             CREATE SEQUENCE SEQ_GERENTES 
             start with 1 increment by 1 nomaxvalue;

--CANAL DE VENDAS RELACIONA GERENTE COM VENDEDOR
CREATE TABLE CANAL_VENDAS_G_V
             (
              cod_empresa int not null,
              id_ger int not null,
              id_vend int not null,
              constraint fk_cgv3 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
    

--CANAL DE VENDAS RELACIONA VENDEDOR COM CLIENTE
CREATE TABLE CANAL_VENDAS_V_C
             (
              cod_empresa int not null,
              id_vend int not null,
              id_cliente int not null,
              constraint fk_cvc2 FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente),
              constraint fk_ccv1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa) 
             );
             
--CRIACAO DE TABELA PARA REGISTRA META DE VENDAS MES A MES/ANO
CREATE TABLE META_VENDAS
             (
              cod_empresa int not null,
              id_vend int not null,
              ano varchar2(4) not null,
              mes varchar2(2) not null,
              valor decimal(10,2),
              constraint fk_mv1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );

--CRIACAO DA TABELA DOS CODIGO DE OPERACOES FISCAIS
CREATE TABLE CFOP
             (
              cod_cfop varchar2(5) not null PRIMARY KEY,
              desc_cfop varchar2(255) not null
             );
             
--CRIACAO DA TABELA NOTA_FISCAL
CREATE TABLE NOTA_FISCAL
             (
              cod_empresa int not null,
              num_nf int not null,
              tip_nf char(1) not null, -- E-ENTRADA, S-SAIDA
              cod_cfop varchar2(5) not null,
              id_clifor int not null,
              cod_pagto int not null, 
              data_emissao date not null,
              data_entrega date not null,
              total_nf decimal(10,2),
              integrada_fin char(1) default('N'),
              integrada_sup char(1) default('N'),
              constraint fk_nf1 FOREIGN KEY (cod_cfop) REFERENCES CFOP(cod_cfop),
              constraint fk_nf2 FOREIGN KEY (cod_pagto) REFERENCES COND_PAGTO(cod_pagto),
              constraint pk_nf1 PRIMARY KEY (cod_empresa,num_nf)
             );
             
--CRIACAO DA TABELA NOTA_FISCAL_ITENS
CREATE TABLE NOTA_FISCAL_ITENS
             (
              cod_empresa int not null,
              num_nf int not null,
              seq_mat int not null,
              cod_mat int not null,
              qtd int not null,
              val_unit decimal(10,2) not null,
              ped_orig  int not null,
              constraint fk_nfit1 FOREIGN KEY (cod_empresa,num_nf) REFERENCES NOTA_FISCAL(cod_empresa,num_nf),
              constraint fk_nfit2 FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat)
             );
    
--CRIACAO TABELAS PARAMETRO NUMERACAO NFE
CREATE TABLE PARAM_NFE
             (
              cod_empresa int not null primary key,
              num_nfe int not null,
              constraint fk_nfe1 FOREIGN KEY (cod_empresa) REFERENCES EMPRESA(cod_empresa)
             );
   
--CRIACAO TABELAS PARAMETRO DE INSS
CREATE TABLE PARAM_INSS
             (
              vigencia_ini date,
              vigencia_fim date,
              valor_de decimal(10,2) not null,
              valor_ate decimal(10,2) not null,
              pct decimal(10,2) not null
             );

--CRIACAO DE TABELAS DE PARAMETRO DO IRRF
CREATE TABLE PARAM_IRRF
             (
              vigencia_ini date,
              vigencia_fim date,
              valor_de decimal(10,2) not null,
              valor_ate decimal(10,2) not null,
              pct decimal(10,2) not null,
              val_isent decimal(10,2)
             );

 --CRIACAO TABELAS AUDIT SALARIO
 CREATE TABLE AUDITORIA_SALARIO
              (  
               cod_empresa int not null,
               matricula int not null,
               sal_antes decimal(10, 2) not null,
               sal_depois decimal(10, 2) not null,
               usuario varchar2(20) not null,
               data_atualizacao date not null,
               constraint fk_audit1 FOREIGN KEY (cod_empresa,matricula) REFERENCES FUNCIONARIO(cod_empresa,matricula)
              );

-----OS CAMPOS A SEGUIR SÓ PODERIAM SER ADICIONADOS APÓS A CRIAÇÃO DAS RESPECTIVAS TABELAS
--ADD CAMPO LOGIN TABELA APONTAMENTOS CRIACAO APOS TABELA USUARIOS E FK
ALTER TABLE APONTAMENTOS ADD login varchar2(30)not null;
ALTER TABLE APONTAMENTOS ADD lote varchar2(20) not null;
   
--REMOVENDO CONSTRAINT PARA TESTE
ALTER TABLE CONSUMO DROP CONSTRAINT  fk_cons2;

--ADD CAMPO LOGIN TABELA ESTOQUE_MOV  CRIACAO APOS TABELA USUARIO
  ALTER TABLE ESTOQUE_MOV ADD login varchar2(30)not null;
  
--ALTERAR  COD_PAGTO TAB PED_COMPRAS PARA FOREIGN KEY APOS TABELA COND_PAGTO
  ALTER TABLE PED_COMPRAS ADD 
  FOREIGN KEY (cod_pagto) REFERENCES COND_PAGTO(cod_pagto);

  
 