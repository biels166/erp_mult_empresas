/*
Essa procedure tem como onjetivo criar pedidos de compra em função das ordens de 
produção.
*/

--ADICIONANDO INFOS INFOS NA TABELA DE FORNECEDORES DE MATERIAL
INSERT INTO MAT_FORNEC values(1,3,1);
INSERT INTO MAT_FORNEC values(1,4,1);
INSERT INTO MAT_FORNEC values(1,5,1);
INSERT INTO MAT_FORNEC values(1,6,1);
INSERT INTO MAT_FORNEC values(1,7,1);
INSERT INTO MAT_FORNEC values(1,8,1);
INSERT INTO MAT_FORNEC values(1,9,1);
INSERT INTO MAT_FORNEC values(1,10,1);
INSERT INTO MAT_FORNEC values(1,11,2);
INSERT INTO MAT_FORNEC values(1,12,2);
INSERT INTO MAT_FORNEC values(1,13,2);
INSERT INTO MAT_FORNEC values(1,14,2);
INSERT INTO MAT_FORNEC values(1,15,2);
INSERT INTO MAT_FORNEC values(1,16,2);
        --TESTE DE INSERÇÃO
        INSERT INTO MAT_FORNEC VALUES (1,17,2);
        DELETE FROM MAT_FORNEC WHERE COD_MAT='17';
        --VERIFICANDO CARGA
        SELECT * FROM MAT_FORNEC
        
-- Alterando para um FK compsta para evitar duplicidade e erros.
--Caso não seja feita essa alteração seria oissuvel inserir um material para compra, mesmo que ele não exista
ALTER TABLE MAT_FORNEC ADD FOREIGN KEY (cod_empresa,cod_mat) REFERENCES MATERIAL(cod_empresa,cod_mat);
ALTER TABLE PED_COMPRAS_ITENS MODIFY QTD decimal(10,2);


--CRIANDO PROCEDURE GERADORA DE PEDIDO DE COMPRAS
CREATE OR REPLACE PROCEDURE PROC_GER_PED_COMPRAS
                            (
                             p_emp number,
                             p_mes varchar2, 
                             p_ano varchar2
                            ) 
                            is
  
v_existe_ordem EXCEPTION;

--DECLARANDO VARIAVEIS
  /*
  TYPE PED     IS TABLE OF PED_COMPRAS%ROWTYPE;
  TYPE PED_IT  IS TABLE OF PED_COMPRAS_ITENS%ROWTYPE;
  TYPE OP      IS TABLE OF ORDEM_PRODUCAO%ROWTYPE;
  TYPE FT      IS TABLE OF FICHA_TECNICA%ROWTYPE;
  TYPE MAT     IS TABLE OF MATERIAL%ROWTYPE;
  TYPE MAT_FOR IS TABLE OF MAT_FORNEC%ROWTYPE;
  TYPE FORNEC IS TABLE OF FORNECEDORES%ROWTYPE; 
  */
  
--REFERENCIANDO
  /*
  T_PED PED;
  T_PED_IT PED_IT;
  T_OP OP;
  T_FT FT;
  T_MAT MAT;
  T_FOR_MAT MAT_FOR;
  T_FOR FORNEC;
  */
  
num_pedido_aux number;
v_num_pedido  number;

--DECLARANDO VARIAVEIS AUXILIARES
v_cont_ord number;
p_mes_aux varchar2(2);
p_ano_aux varchar2(4);
cont_seq number;
v_total_ped number(10,2);
 
BEGIN 

        V_TOTAL_PED:=0;
        -- P_MES='01'       
        -- P_ANO='2017'
        --VERIFICACAO SE MES JANEIRO MES=12 E ANO-1
        --SENAO MES-1

        IF (p_mes='01') THEN
            p_mes_aux:=12;
            p_ano_aux:=p_ano-1;
        ELSE  
            p_mes_aux:=p_mes_aux-1;
        END IF;
        
        --VERIFICANDO SE EXISTEM ORDEM PARA PLANEJ
        SELECT COUNT(*) INTO v_cont_ord FROM ORDEM_PROD A
        WHERE TO_CHAR(A.data_ini,'MM')=p_mes
              AND TO_CHAR(A.data_ini,'YYYY')=P_Ano
              AND A.cod_empresa=p_emp
              AND A.situacao='A';
        --SE NAO EXISTEM ORDEM RAISE  V_EXISTE_ORDEM
        IF v_cont_ord =0 THEN
            RAISE v_existe_ordem;
        ELSE 
             p_mes_aux:=p_mes;
             p_ano_aux:=p_ano;
             cont_seq:=1;
             v_num_pedido:=0;
             num_pedido_aux:=0;
     END IF;
    
    --CURSOR PARA GRAVAR CABECALHO PEDIDO DE COMPRAS
    --SELECT PARA GERAR NECESSIDADES DE COMPRAS CONFORME ORDEM DE PRODUCAO
    --CONFORME FICHA TENICA  E PRODUTO COM SEU FORNECEDOR
    --CURSOR IMPLICITO PRIMEIRO CURSOR

    FOR C_FORNEC IN (SELECT distinct A.cod_empresa, D.id_for, E.cod_pagto, '15/'||P_Mes_Aux||'/'||p_ano_aux AS DATA_PEDIDO,
                    '15/'||p_mes||'/'||p_ano  AS DATA_ENTREGA, 'A' SITUACAO
	FROM ORDEM_PROD A
	INNER JOIN FICHA_TECNICA B
	ON A.cod_mat_prod=B.cod_mat_prod
    AND A.cod_empresa=B.cod_empresa
    
	INNER JOIN MATERIAL C
	ON B.cod_mat_neces=C.cod_mat
    AND A.Cod_Empresa=C.cod_empresa
    
	INNER JOIN MAT_FORNEC D
	ON C.cod_mat=D.cod_mat
    AND A.cod_empresa=D.cod_empresa
    
    INNER JOIN FORNECEDORES E
    ON A.cod_empresa=E.cod_empresa
    AND D.id_for=E.id_for
    
	WHERE TO_CHAR(A.data_ini,'MM')=p_mes  --PARAM MES
          AND TO_CHAR(A.data_ini,'YYYY')=p_ano  --PARAM ANO
          AND A.cod_empresa=p_emp               --PARAM EMPRESA
          AND A.situacao='A')  
          
    LOOP
    --INSERT NA TABELA COMPRAS CABEBECALHO
	INSERT INTO PED_COMPRAS (cod_empresa,id_for,cod_pagto,data_pedido,data_entrega,situacao)
    values(C_FORNEC.cod_empresa,C_FORNEC.id_for,C_FORNEC.cod_pagto,C_FORNEC.Data_Pedido,C_FORNEC.data_entrega,C_FORNEC.situacao)
    RETURNING num_pedido INTO num_pedido_aux; --PEGANDO VALOR DO PEDIDO INSERIDO E ATRIBUINDO VALOR
    
    --APRESENTANDO VALORES
	 dbms_output.put_line('NUM Ped: '||NUM_PEDIDO_AUX||' Fornec: '||C_FORNEC.ID_FOR||' Cod Pagto: '||
     C_FORNEC.COD_PAGTO||' DATA PED: '||C_FORNEC.DATA_PEDIDO||' DATA ENTR: '||C_FORNEC.DATA_ENTREGA||' SITUA: '||
     C_FORNEC.SITUACAO);
    
    --CURSOR DETALHE PED IT INICIO
	--SELECT COM PARAMETROS SEGUNFO CURSOR E LOOP
    FOR  ped_it IN (SELECT A.cod_empresa,B.cod_mat_neces COD_MAT,D.id_for,
    SUM(B.qtd_neces*A.qtd_plan) QTD,C.Preco_Unit
	FROM ORDEM_PROD A
	INNER JOIN FICHA_TECNICA B
    ON A.cod_mat_prod=B.cod_mat_prod
    AND A.cod_empresa=B.cod_empresa
        
	INNER JOIN MATERIAL C
	ON B.cod_mat_neces=C.cod_mat
    AND A.cod_empresa=C.cod_empresa
        
    INNER JOIN MAT_FORNEC D
    ON D.cod_mat=B.cod_mat_neces
    AND A.cod_empresa=D.cod_empresa
        
	INNER JOIN FORNECEDORES E
	ON D.id_for=E.id_for
    AND A.cod_empresa=E.cod_empresa
        
	WHERE TO_CHAR(A.data_ini,'MM')=p_mes --PAPRAM MES
	      AND TO_CHAR(A.data_ini,'YYYY')=p_ano --PARAM ANO
          AND A.cod_empresa=p_emp --PARAM EMPRESA
		  AND A.Situacao='A' --ABERTA
		  AND D.id_for=C_FORNEC.id_for --PARAM PARA FORNECEDOR DO CURSOR 1
    GROUP BY A.cod_empresa,B.cod_mat_neces,D.id_for,C.Preco_Unit ORDER BY B.cod_mat_neces) 
    
    LOOP
    --VERIFICACOES PARA CONTADOR DE SEQ MATERIAL E TOTAL_PED
        IF (v_num_pedido<>num_pedido_aux) THEN
            cont_seq:=1;
            v_total_ped:=0;  
	    END IF;
      
	    --INSERINDO REGISTRO NA PED_COMPRAS_ITENS
		INSERT INTO PED_COMPRAS_ITENS values(PED_IT.cod_empresa,num_pedido_aux,cont_seq,ped_it.cod_mat,ped_it.qtd,ped_it.preco_unit);
		--APRESENTANDO VALORES
		dbms_output.put_line('Cod Mat: '||PED_IT.COD_MAT||' Seq: '||CONT_SEQ||' COD MAT: '||PED_IT.COD_MAT||' QTD: '||PED_IT.QTD||' PRECO_UNIT: '||PED_IT.PRECO_UNIT);
		
        --ATRIBUINDO VALORES
		v_num_pedido:=num_pedido_aux;
		cont_seq:=cont_seq+1;
		v_total_ped:=v_total_ped+(ped_it.qtd*ped_it.preco_unit);
        dbms_output.put_line('Pedido '||V_NUM_PEDIDO||' Total Pedido: '||V_TOTAL_PED);
    END LOOP; --FIM CURSOR C_FORNEC SEGUNDO CURSOR CURSO 
        
    --ATUALIZANDO TOTAL PEDIDO
    UPDATE PED_COMPRAS SET TOTAL_PED=V_TOTAL_PED WHERE NUM_PEDIDO=V_NUM_PEDIDO AND COD_EMPRESA=P_EMP;
    dbms_output.put_line('Pedido '||V_NUM_PEDIDO||' Total Pedido: '||V_TOTAL_PED);
    --ATRIBUINDO VARIAVEIS
    v_num_pedido:=num_pedido_aux;
    
    END LOOP ; --FIM CURSOR C_FORNEC PRIMEIRO CURSO
	
    --ATUALIZA ORDENS
	UPDATE  ORDEM_PROD SET situacao='P'
    WHERE TO_CHAR(data_ini,'MM')=p_mes
	      AND TO_CHAR(data_ini,'YYYY')=p_ano
		  AND situacao='A'
          AND cod_empresa=p_emp;
		     	
		 dbms_output.put_line('OPERACAO FINALIZADA COM SUCESSO');
		 COMMIT;

    EXCEPTION
        WHEN v_existe_ordem THEN
            dbms_output.put_line('ATENÇÃO! NÃO EXISTEM OP PARA ESTA OPERACAO!');
        WHEN OTHERS THEN
            Dbms_Output.Put_Line('OCORREU UM ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--EXECUTANDO 
--PARAMENTRE EMPRESA, MES,ANO

SET SERVEROUTPUT ON
EXECUTE PROC_GER_PED_COMPRAS (1,'02','2021');


--VERIFICANDO
SELECT * FROM ORDEM_PROD;
SELECT * FROM PED_COMPRAS;
SELECT * FROM PED_COMPRAS_ITENS;
SELECT * FROM FICHA_TECNICA;

--VERIFICANDO SOMA
SELECT cod_empresa, num_pedido, SUM(CAST(QTD*val_unit as decimal(10,2))) TOTAL
FROM PED_COMPRAS_ITENS
WHERE cod_empresa=1
GROUP BY cod_empresa, num_pedido;

DELETE FROM PED_COMPRAS_ITENS;
DELETE FROM PED_COMPRAS;
UPDATE  ORDEM_PROD SET situacao='A' WHERE situacao='P' AND cod_empresa=1;
