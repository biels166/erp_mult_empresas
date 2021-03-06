--TRIGGER PARA SEQUENCIAS 
--PARA TABELA EMPRESA   
CREATE OR REPLACE TRIGGER TRG_EMPRESA1 
    BEFORE INSERT ON EMPRESA 
    FOR EACH ROW  
        BEGIN 
        IF :NEW.cod_empresa IS NULL THEN 
            SELECT SEQ_EMP.NEXTVAL INTO :NEW.cod_empresa FROM DUAL; 
        END IF; 
    END; 

--PARA TABELA APONTAMENTO   
CREATE OR REPLACE TRIGGER TRG_APONT 
    BEFORE INSERT ON APONTAMENTOS
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_apon IS NULL THEN 
            SELECT SEQ_APON.NEXTVAL INTO :NEW.id_apon FROM DUAL; 
        END IF; 
    END; 

--PARA TABELA CONTAS A PAGAR  
CREATE OR REPLACE TRIGGER TRG_CAP 
    BEFORE INSERT ON CONTAS_PAGAR
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_doc IS NULL THEN 
            SELECT SEQ_CAP.NEXTVAL INTO :NEW.id_doc FROM DUAL; 
        END IF; 
    END; 

--PARA TABELA CLIENTES
--SEQ_CLI        CAMPO ID_CLIENTE    
CREATE OR REPLACE TRIGGER TRG_CLIENTE 
    BEFORE INSERT ON CLIENTES
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_cliente IS NULL THEN 
            SELECT SEQ_CLI.NEXTVAL INTO :NEW.id_cliente FROM DUAL; 
        END IF; 
    END; 

--PARA TABELA CONTAS RECEBER
--SEQ_CRE        CAMPO ID_DOC  
CREATE OR REPLACE TRIGGER TRG_CRE 
    BEFORE INSERT ON CONTAS_RECEBER
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_doc IS NULL THEN 
            SELECT SEQ_CRE.NEXTVAL INTO :NEW.id_doc FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA TABELAS FORNECEDOR
--SEQ_FOR        CAMPO ID_FOR
CREATE OR REPLACE TRIGGER TRG_FOR 
    BEFORE INSERT ON FORNECEDORES
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_for IS NULL THEN 
            SELECT SEQ_FOR.NEXTVAL INTO :NEW.id_for FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA TABELA GERENTES
--SEQ_GERENTES   CAMPO ID_GER
CREATE OR REPLACE TRIGGER TRG_GER 
    BEFORE INSERT ON GERENTES
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_ger IS NULL THEN 
            SELECT SEQ_GERENTES.NEXTVAL INTO :NEW.id_ger FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA TABELA ESTOQUE MOV
--SEQ_MOVEST     CAMPO ID_MOV
CREATE OR REPLACE TRIGGER TRG_MOVEST 
    BEFORE INSERT ON ESTOQUE_MOV
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_mov IS NULL THEN 
            SELECT SEQ_MOVEST.NEXTVAL INTO :NEW.Id_Mov FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA ORDEM DE PRODUCAO
--SEQ_OP         CAMPO ID_ORDEM
CREATE OR REPLACE TRIGGER TRG_OP 
    BEFORE INSERT ON ORDEM_PROD
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_ordem IS NULL THEN 
            SELECT SEQ_OP.NEXTVAL INTO :NEW.id_ordem FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA CONDI??O DE PAGAMENTO
--SEQ_PAGTO      CAMPO COD_PAGTO
CREATE OR REPLACE TRIGGER TRG_COD_PAGTO 
    BEFORE INSERT ON COND_PAGTO
    FOR EACH ROW  
        BEGIN 
        IF :NEW.cod_pagto IS NULL THEN 
            SELECT SEQ_PAGTO.NEXTVAL INTO :NEW.cod_pagto FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA TIPO DE MATERIAL
--SEQ_TIP_MAT    CAMPO COD_TIP_MAT
CREATE OR REPLACE TRIGGER TRG_COD_TIP_MAT 
    BEFORE INSERT ON TIPO_MAT
    FOR EACH ROW  
        BEGIN 
        IF :NEW.cod_tip_mat IS NULL THEN 
            SELECT SEQ_TIP_MAT.NEXTVAL INTO :NEW.cod_tip_mat FROM DUAL; 
        END IF; 
    END; 

--SEQUENCIA PARA ID DO VENDEDOR
--SEQ_VENDEDORES CAMPO ID_VEND
CREATE OR REPLACE TRIGGER TRG_VENDEDOR 
    BEFORE INSERT ON VENDEDORES
    FOR EACH ROW  
        BEGIN 
        IF :NEW.id_vend IS NULL THEN 
            SELECT SEQ_VENDEDORES.NEXTVAL INTO :NEW.id_vend FROM DUAL; 
        END IF; 
    END; 


--CRIAR TRIGGER PARA NUMERACAO DE NFE  
CREATE OR REPLACE TRIGGER TRG_NUM_NFE 
    BEFORE INSERT ON NOTA_FISCAL 
    FOR EACH ROW 
     BEGIN 
         UPDATE PARAM_NFE SET num_nfe=num_nfe+1 WHERE cod_empresa=:NEW.cod_empresa;
         SELECT num_nfe INTO :NEW.num_nf  FROM PARAM_NFE WHERE cod_empresa=:NEW.cod_empresa; 
    END; 

--CRIAR TRIGGER PARA PARAMETROS PEDIDO DE COMPRAS
CREATE OR REPLACE TRIGGER TRG_NUM_PED_COMPRAS 
    BEFORE INSERT ON PED_COMPRAS 
    FOR EACH ROW 
     BEGIN 
         UPDATE PARAM_PED_COMPRAS SET num_ped=num_ped+1 WHERE cod_empresa=:NEW.cod_empresa;
         SELECT num_ped INTO :NEW.num_pedido  FROM PARAM_PED_COMPRAS WHERE cod_empresa=:NEW.cod_empresa; 
    END; 
    
-- CRIAR TRIGGER PARA PARAMETROS PEDIDO DE VENDAS
CREATE OR REPLACE TRIGGER TRG_NUM_PED_VENDAS 
    BEFORE INSERT ON PED_VENDAS 
    FOR EACH ROW 
     BEGIN 
         UPDATE PARAM_PED_VENDAS SET num_ped=num_ped+1 WHERE cod_empresa=:NEW.cod_empresa;
         SELECT num_ped INTO :NEW.num_pedido  FROM PARAM_PED_VENDAS WHERE cod_empresa=:NEW.cod_empresa; 
    END; 

-- CRIAR TRIGGER PARA PARAMETROS MATRICULA FUNCIONARIOS
CREATE OR REPLACE TRIGGER TRG_MAT_FUNC 
    BEFORE INSERT ON FUNCIONARIO
    FOR EACH ROW 
     BEGIN 
         UPDATE PARAM_MATRICULA SET matricula=matricula+1 WHERE cod_empresa=:NEW.cod_empresa;
         SELECT matricula INTO :NEW.matricula  FROM PARAM_MATRICULA WHERE cod_empresa=:NEW.cod_empresa; 
    END; 