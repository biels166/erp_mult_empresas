/*
Objetivo gerar ordens de producao de acordo com demanda de vendas por empresa
*/

--PROCEDURE ORDEM_PROD
CREATE OR REPLACE PROCEDURE PROC_PLAN_ORDEM 
                            (
                             p_emp number,
                             p_mes  varchar2, 
                             p_ano  varchar2
                            ) 
                            is
                            
v_except_existe_pedido exception;
v_conta_ped NUMBER;

BEGIN 
        --VERIFICANDO SE EXISTE PEDIDOS ABERTO PARA MES E ANO SELECIONADO
            SELECT COUNT(*) QTD INTO v_conta_ped
            FROM PED_VENDAS A
            INNER JOIN PED_VENDAS_ITENS B
            ON A.num_pedido=B.num_pedido AND A.cod_empresa=B.cod_empresa --Restringe para que a seleção não seja de empreasa misturada
            WHERE A.situacao='A' --ABERTO
                  AND A.cod_empresa=p_emp
                  AND TO_CHAR(A.data_entrega,'MM')=p_mes
                  AND TO_CHAR(A.data_entrega,'YYYY')=p_ano;
        --SE NÃO EXISTIR
        IF v_conta_ped=0 THEN 
            RAISE v_except_existe_pedido;
        END IF;
        --SELECIONANDO PEDIDOS PARA GERAR ORDENS DE PRODUÇÃO DE ACORDO COM A DEMANDA.
		INSERT INTO ORDEM_PROD 
		SELECT A.cod_empresa, NULL, B.cod_mat, SUM(B.QTD) as QTD_PLAN, 0 QTD_PROD, 
               '01/'||p_mes||'/'||p_ano as DATA_INI, LAST_DAY('01/'||p_mes||'/'||p_ano) AS DATA_FIM,'A'
        FROM PED_VENDAS A
		INNER JOIN PED_VENDAS_ITENS B
		ON A.num_pedido=B.num_pedido
        AND  A.cod_empresa=B.cod_empresa
		WHERE A.cod_empresa=p_emp 
		      AND TO_CHAR(A.data_entrega,'MM')=p_mes
              AND TO_CHAR(A.data_entrega,'YYYY')=P_Ano
              AND A.situacao='A' --APENAS PEDIDO EM ABERTO
        GROUP BY A.cod_empresa, B.cod_mat, NULL, 0, '01/'||p_mes||'/'||p_ano, LAST_DAY('01/'||p_mes||'/'||p_ano), 'A';
		dbms_output.put_line('INSERT ORDEM PROD REALIZADO');
        --ATUALIZA STATUS PEDIDO DE A PARA P
        UPDATE PED_VENDAS SET situacao='P'
        WHERE cod_empresa=p_emp
              AND TO_CHAR(data_entrega,'MM')=p_mes
              AND TO_CHAR(data_entrega,'YYYY')=p_ano
              AND situacao='A';
        dbms_output.put_line('STATUS ATUALIZADO DE ABERTO PARA PLANEJADO');
    
    EXCEPTION
    WHEN v_except_existe_pedido THEN
        dbms_output.put_line('ATENÇÃO! NAO EXISTE PEDIDOS ABERTO PARA PLANEJAMENTO!');
    WHEN OTHERS THEN
        dbms_output.put_line('OCORREU UM ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--PARAMENTRO EMPRESA, MES, ANO
EXECUTE PROC_PLAN_ORDEM (1,'01','2021');
EXECUTE PROC_PLAN_ORDEM (1,'02','2021');
EXECUTE PROC_PLAN_ORDEM (2,'03','2021');
EXECUTE PROC_PLAN_ORDEM (1,'04','2021');
        --VERIFICANDO AS ORDENS DE ACORDO COM AS DEMANDAS DOS PEDIDOS POR EMPRESA
        SELECT * FROM PED_VENDAS
        SELECT * FROM PED_VENDAS_ITENS
        SELECT * FROM ORDEM_PROD 
