--SELECT * FROM CONTAS_PAGAR
--SELECT * FROM CONTAS_RECEBER
--PROCEDURE INTEGRA CAP E CRE
--ORIGEM NOTA_FISCAL ENTRADA SAIDA
--SE SAIDA DESTINO CONTAS A RECEBER
--SE ENTRADA DESTINO CONTAS A PAGAR
--SEM PARAMETROS EXTERNOS, APENAS INTERNOS
--EXEC PROC_INTEGR_FIN
CREATE OR REPLACE PROCEDURE PROC_INTEGR_FIN is 
    
v_execp_sem_docto exception;
 
BEGIN 
    FOR c_conta IN  (SELECT COUNT(*) QTD FROM NOTA_FISCAL WHERE integrada_fin='N') 
        LOOP
            IF c_conta.qtd=0 THEN
                RAISE v_execp_sem_docto;
            END IF;
        END LOOP;
    
   --SELECIONANDO REGISTROS
    FOR c_fin IN (SELECT A.cod_empresa,A.tip_nf,A.num_nf,B.parc,A.id_clifor,A.Cod_Pagto,A.data_emissao,A.data_emissao+B.dias AS vencimento, A.total_nf,
        CAST(A.Total_Nf/100*B.pct AS DECIMAL(10,2)) AS valor_parc
        FROM NOTA_FISCAL A  
        INNER JOIN COND_PAGTO_DET B ON A.cod_pagto=B.cod_pagto
        WHERE A.integrada_fin='N'
        ORDER BY A.cod_empresa,A.num_nf,B.parc) 
        LOOP
            --IF PARA INTEGRAR NOTAS DE VENDAS SAIDAS
            IF c_fin.tip_nf='S' THEN
                INSERT INTO CONTAS_RECEBER(cod_empresa,id_doc,id_cliente,id_doc_orig,parc,data_venc,valor)
                values(c_fin.Cod_Empresa,null,c_fin.id_clifor,c_fin.num_nf,c_fin.parc,c_fin.vencimento,c_fin.valor_parc);

            --IF PARA INTEGRAR NOTAS DE COMPRAS ENTRADASS
            ELSIF C_FIN.tip_nf='E' THEN
                INSERT INTO CONTAS_PAGAR(cod_empresa,id_doc,id_for,id_doc_orig,parc,data_venc,valor)
                values(c_fin.cod_empresa,null,c_fin.id_clifor,c_fin.num_nf,c_fin.parc,c_fin.vencimento,c_fin.valor_parc);
            END IF;
        
            --ATUALIZANDO STATUS DE NOTA FISCAL PARA INTEGRADA_FIN=S (S=Sim, esta integrada ao financeiro)
            UPDATE NOTA_FISCAL SET integrada_fin='S' WHERE num_nf=c_fin.num_nf AND cod_empresa=c_fin.cod_empresa AND integrada_fin='N' ;
        END LOOP;
    dbms_output.put_line('INTEGRACAO CONCLUIDA');
    COMMIT;
    
     --VALIDACOES FINAIS
    EXCEPTION
    WHEN v_execp_sem_docto THEN
        dbms_output.put_line('NÃO EXISTEM DOCUMENTOS PARA INTEGRACAO!');
    ROLLBACK;
    
    WHEN no_data_found THEN
        dbms_output.put_line('NAO EXISTE DADOS!');
    ROLLBACK;
        
    WHEN OTHERS THEN
        dbms_output.put_line('OUTROS CODIGO DO ERRO '||SQLCODE||' MSG '||SQLERRM);
        dbms_output.put_line('Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    ROLLBACK;

END; --END PROCEDURE 

--EXECUTANDO PROC
SET SERVEROUTPUT ON
EXECUTE PROC_INTEGR_FIN;

SELECT * FROM CONTAS_PAGAR;
SELECT * FROM CONTAS_RECEBER;
--DELETE FROM CONTAS_RECEBER
	