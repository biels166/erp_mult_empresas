--@TIPO_MOV, COD_MAT,@LOTE, QTD_MOV
--EXEC PROC_GERA_ESTOQUE 
--CRIACAO PROC_INTEGR_NF_ESTOQUE
--EXECUTE PROC_INTEGR_NF_ESTOQUE 10,'2017-01-30'
--SELECT * FROM NOTA_FISCAL
--SELECT * FROM NOTA_FISCAL_ITENS
--UPDATE NOTA_FISCAL SET INTEGRADA_SUP='N' WHERE NUM_NF='2'
--SELECT * FROM ESTOQUE
--SELECT * FROM ESTOQUE_LOTE
--SELECT * FROM ESTOQUE_MOV
CREATE OR REPLACE PROCEDURE PROC_INTEGR_NF_ESTOQUE 
                            (
                             p_emp in number,
                             p_num_nf number,
                             p_data_movto date
                            )
                            is

v_exc_saldo_insuficiente exception;
v_exc_doct_nao_existe exception;
v_exc_integrado exception;

v_qtd_aux number(10,2);
v_qtd_tot number(10,2);
v_tip_oper varchar2(1);
v_situa varchar2(1);
v_cont int;
v_num_nf number;
v_mat_aux number;
v_saldo_aux number(10,2);

BEGIN 
    
    --VERIFICANDO DE DOCTO EXISTE E JA JA ESTA INTEGRADO
    SELECT num_nf,tip_nf,integrada_sup, COUNT(*) QTD INTO v_num_nf,v_tip_oper,v_situa,v_cont FROM NOTA_FISCAL
    WHERE cod_empresa=p_emp AND num_nf=p_num_nf
    GROUP BY num_nf,tip_nf,integrada_sup;
    --VERIFICA SE EXISTE DOCTO
    IF v_cont=0 THEN
        RAISE v_exc_doct_nao_existe;
    END IF;
    
    --VERIFICA SE ESTA INTEGRADO
    IF v_cont=1 AND v_situa='S' THEN
        RAISE v_exc_integrado;
    END IF;
    
    --VERIFCANDO SE NOTA DE ENTRADA PARA DAR ENTRADA EM ESTOQUE;
    IF v_tip_oper='E' THEN
        FOR c_nf_it IN (SELECT A.cod_empresa,A.tip_nf,B.cod_mat,TO_CHAR(SYSDATE,'DD-MM')||'-'||A.num_nf LOTE,B.QTD FROM NOTA_FISCAL A
        INNER JOIN NOTA_FISCAL_ITENS B ON A.cod_empresa=B.cod_empresa AND A.num_nf=B.Num_Nf
        WHERE A.num_nf=p_num_nf AND A.cod_empresa=p_emp  AND A.tip_nf='E' AND A.Integrada_Sup='N') 
        LOOP
            --EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ENTRADA NO MATERIAL
            PRC_MOV_ESTOQUE (c_nf_it.tip_nf,p_emp,c_nf_it.cod_mat,c_nf_it.lote,c_nf_it.qtd,p_data_movto);
        END LOOP;
        UPDATE NOTA_FISCAL SET integrada_sup='S' WHERE num_nf=p_num_nf AND cod_empresa=p_emp;
        COMMIT;
        dbms_output.put_line('ENTRADA CONCLUIDA!');
    
        --OPERACAO DE SAIDA /REGRA NAO PODE SAIR MAIS QUE O SALDO
        ELSIF v_tip_oper='S' THEN
            --ABRINDO CURSOR DOS ITENS DA NF
            FOR c_nf_it IN (SELECT A.cod_empresa,A.tip_nf,B.Cod_Mat,
			--TO_CHAR(SYSDATE,'DD-MM')||'-'||A.NUM_NF LOTE,
			--COMPOSICAO CAMPO LOTE (DIA MES + NUMERO DA NF)
			B.QTD 
			FROM NOTA_FISCAL A
			INNER JOIN NOTA_FISCAL_ITENS B ON A.cod_empresa=B.cod_empresa AND A.num_nf=B.num_nf AND A.cod_empresa=p_emp --PARAMENTO
			WHERE A.num_nf=p_num_nf AND A.Tip_Nf='S'AND A.integrada_sup='N') 
            LOOP 
                --ABRINDO CURSOR DO MATERIAIS EM ESTQUE DOS ITENS DA NF
                FOR C_ESTOQUE IN (SELECT A.cod_empresa,A.cod_mat,A.qtd_saldo FROM ESTOQUE A WHERE A.cod_empresa=p_emp AND A.cod_mat=c_nf_it.cod_mat) 
                LOOP
                    --VERIFICA SE SALDO DISPONIVEL PARA SAIDA                
                    IF (c_nf_it.qtd>c_estoque.qtd_saldo) THEN
                        RAISE v_exc_saldo_insuficiente;
                    END IF;
                END LOOP; --LOOP C_ESTOQUE
            END LOOP; --LOOP C_NF_IT
    END IF;  
    
    --GERANDO MOVIMENTAÇÃO DE SAIDA
    IF v_tip_oper='S' THEN
    FOR c_nf_it IN (SELECT A.cod_empresa,A.tip_nf,B.cod_mat,
			--TO_CHAR(SYSDATE,'DD-MM')||'-'||A.NUM_NF LOTE,
			--COMPOSICAO CAMPO LOTE (DIA MES + NUMERO DA NF)
			B.QTD 
			FROM NOTA_FISCAL A INNER JOIN NOTA_FISCAL_ITENS B ON A.cod_empresa=B.cod_empresa AND A.num_nf=B.num_nf AND A.cod_empresa=p_emp
			WHERE A.num_nf=p_num_nf AND A.tip_nf='S' AND A.integrada_sup='N') 
            LOOP
                --ATRIBUINDO A QUANTIDADE NECESSARIA PARA BAIXA EM ESTOQUE
                V_SALDO_AUX:=C_NF_IT.QTD;
                FOR c_est_lote IN (SELECT A.cod_empresa,A.cod_mat,A.lote,A.qtd_lote FROM ESTOQUE_LOTE A WHERE A.cod_empresa=p_emp AND A.Cod_Mat=c_nf_it.COD_MAT 
                ORDER BY A.cod_mat,A.lote ) 
                LOOP
                --SE SALDO IGUAL A ZERO LER PROXIMO MATERIAL
                IF v_saldo_aux=0 THEN
                    EXIT;
                END IF;
        
    IF (v_saldo_aux<=c_est_lote.qtd_lote) THEN
        --EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ENTRADA NO MATERIAL
        PRC_MOV_ESTOQUE (c_nf_it.tip_nf,p_emp,c_est_lote.cod_mat,c_est_lote.Lote,v_saldo_aux,p_data_movto);
        --SUBSTRAINDO QTD BAIXADA
        v_saldo_aux:=v_saldo_aux-v_saldo_aux;
    ELSIF (v_saldo_aux>c_est_lote.qtd_lote) THEN
        --EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ENTRADA NO MATERIAL
        PRC_MOV_ESTOQUE (c_nf_it.tip_nf,p_emp,c_est_lote.cod_mat,c_est_lote.lote,c_est_lote.qtd_lote,P_Data_Movto);
        v_saldo_aux:=v_saldo_aux-c_est_lote.qtd_lote;
    END IF;
    END LOOP; --C_EST_LOTE
    END LOOP; --C_NF_IT
    
    UPDATE NOTA_FISCAL SET integrada_sup='S'  WHERE num_nf=p_num_nf AND cod_empresa=P_Emp;
    COMMIT;
	dbms_output.put_line('SAIDA CONCLUIDA!');
    END IF;
    

 --VALIDACOES FINAIS
    EXCEPTION
    WHEN v_exc_saldo_insuficiente THEN
        dbms_output.put_line('SALDO INSUFICIENTE!'); 
    ROLLBACK;
    
    WHEN v_exc_doct_nao_existe THEN
        dbms_output.put_line('DOCUMENTO NAO EXISTE!');
    ROLLBACK;
   
    WHEN  v_exc_integrado THEN
        dbms_output.put_line('DOCTO JA INTEGRADO!');     
    ROLLBACK;
        
    WHEN  no_data_found  THEN
        dbms_output.put_line('NAO EXISTE DADOS!');
    ROLLBACK;
        
     WHEN OTHERS THEN
        dbms_output.put_line('OUTROS CODIGO DO ERRO '||SQLCODE||' MSG '||SQLERRM);
        dbms_output.put_line('Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
     ROLLBACK;

END; --END PROCEDURE      
        
        

--SELECT * FROM NOTA_FISCAL
--UPDATE NOTA_FISCAL SET INTEGRADA_SUP='N'
/*
SELECT * FROM ESTOQUE
SELECT * FROM ESTOQUE_MOV
SELECT * FROM ESTOQUE_LOTE
*/

/*
DELETE FROM ESTOQUE;
DELETE FROM ESTOQUE_MOV;
DELETE FROM ESTOQUE_LOTE;
*/
--SELECT * FROM PED_VENDAS_ITENS
--SELECT * FROM PED_VENDAS
--SELECT * FROM PED_COMPRAS
--SELECT * FROM NOTA_FISCAL ORDER BY NUM_NF;
--SELECT * FROM NOTA_FISCAL_ITENS WHERE COD_EMPRESA=1 AND NUM_NF='12' ORDER BY NUM_NF;

--PARAMENTROS (P_EMP IN NUMBER, P_NUM_NF NUMBER, P_DATA_MOVT
--SIMULANDO ENTRADA
EXECUTE PROC_INTEGR_NF_ESTOQUE (1,15,'15/01/2021');

--ALIMENTANDO ESTOQUE PARA NOTA DE SAIDA]
--SAIDA
EXECUTE PRC_MOV_ESTOQUE ('E',1,1,'AB',20,SYSDATE);
EXECUTE PRC_MOV_ESTOQUE ('E',1,1,'CD',30,SYSDATE);
EXECUTE PRC_MOV_ESTOQUE ('E',1,2,'EF',20,SYSDATE);
EXECUTE PRC_MOV_ESTOQUE ('E',1,2,'GH',15,SYSDATE);

--PARAMENTROS (P_EMP IN NUMBER, P_NUM_NF NUMBER, P_DATA_MOVT
SET SERVEROUTPUT ON
EXECUTE PROC_INTEGR_NF_ESTOQUE (1,12,'15/01/2021');

--SELECT * FROM ESTOQUE WHERE COD_MAT IN (1,2) AND COD_EMPRESA=1;
--SELECT * FROM ESTOQUE_LOTE WHERE COD_MAT IN (1,2) AND COD_EMPRESA=1;
--SELECT * FROM ESTOQUE_MOV ORDER BY ID_MOV