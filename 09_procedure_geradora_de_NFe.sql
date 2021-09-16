--PROC_GERA_NF
--TABELAS ORIGEM PED_VENDAS, PED_VENDAS_ITENS, PED_COMPRAS, PED_COMPRAS_ITENS
--TABELAS DESTINO NOTA_FISCAL, NOTA_FISCAL_ITENS
--PARAMETROS TIP_NF,DOCTO,CFOP,DATA_EMIS,DATA_ENTREGA
--EXEC PROC_GERA_NF 'S',4,'5.101','2017-01-30','2017-01-30'
--DROP  PROCEDURE PROC_GERA_NF 
CREATE OR REPLACE PROCEDURE PROC_GERA_NF 
                            (
                             p_emp in number,
                             tip_nf in varchar2,--E = ENTRADA S= SAIDA
                             docto in number, --NUMERO DO PEDIDO QUE SERA GERADO NFE
                             cfop varchar2,
                             data_emis date,
                             data_entrega date
                             )
                             is

exc_lanc_futuro  exception;
exc_tip_nf       exception;
exc_ped_n_existe exception;
exc_qtd_ped_vend exception;
exc_qtd_ped_comp exception;

v_seq_mat int;
v_total_nfe number(10,2):=0;
qtd_ped_v int;
qtd_ped_c int;
v_num_nf  number;
v_data date := trunc(SYSDATE);
		 
BEGIN 
        --VERIFICA DATA DA EMISSAO MAIOR QUE  ATUAL
		IF (data_emis>v_data) THEN
            RAISE exc_lanc_futuro;
        END IF;
        
        --VERIFICA TIPO MOVIMENTO
		IF (tip_nf NOT IN ('S','E')) THEN
            RAISE exc_tip_nf;
       	END IF;
        
        --VERIFICA SE PEDIDO DE VENDA EXISTE
        SELECT COUNT(*) QTD INTO qtd_ped_v FROM PED_VENDAS A
		WHERE A.num_pedido=docto AND A.cod_empresa=p_emp AND A.situacao<>'F';
        IF (tip_nf='S' AND qtd_ped_v=0) THEN
            RAISE exc_qtd_ped_vend;
        END IF;
       
        --VERIFICA SE PEDIDO DE COMPRA EXISTE
        SELECT COUNT(*) QTD INTO qtd_ped_c FROM PED_COMPRAS A
        WHERE A.num_pedido=docto AND A.cod_empresa=p_emp AND A.situacao<>'F';
        IF (tip_nf='E' AND qtd_ped_c=0) THEN
            RAISE exc_qtd_ped_comp;
        END IF;
        
        -- VERIFICANDO NOTA FISCAL DE SAIDA OU ENTRADA
        IF tip_nf='S' THEN
            --CURSOR FOR PARA LER PEDIDO DE SAIDA
            FOR c_nf in (SELECT A.cod_empresa,A.num_pedido,A.id_cliente ID_CLIFOR,A.cod_pagto FROM  PED_VENDAS A
            WHERE A.num_pedido=docto AND A.cod_empresa=p_emp AND A.situacao<>'F') 
            
            LOOP  
                --INSERINDO DADOS DO CURSOR FOR C_NF
                INSERT INTO NOTA_FISCAL (cod_empresa,num_nf,tip_nf,cod_cfop,id_clifor,cod_pagto,data_emissao,data_entrega,total_nf,integrada_fin,integrada_sup)
                values(p_emp,null,tip_nf,cfop,c_nf.id_clifor,c_nf.cod_pagto,data_emis,data_entrega,0,'N','N')
                RETURNING num_nf INTO v_num_nf; --PEGANDO VALOR DO NFE INSERIDO E ATRIBUINDO VALOR
				
                --APRESENTANDO VALORES CABECALHO
                dbms_output.put_line('NUM_NF: '||V_NUM_NF||' Tip NFE: '||TIP_NF||' CFOP: '||CFOP||' COD CLIFOR: '||C_NF.ID_CLIFOR||' COD PAGTO: '||C_NF.COD_PAGTO||' DATA_EMIS: '||DATA_EMIS||'DATA_ENTREGA: '||DATA_ENTREGA);

                --CURSOR DETALHE PED INICIO
                FOR C_NF_IT IN (SELECT A.seq_mat,A.cod_mat,A.qtd,A.val_unit FROM PED_VENDAS_ITENS A 
                WHERE A.num_pedido=docto AND cod_empresa=p_emp ORDER BY A.seq_mat) 
                LOOP
                    --INSERINDO DADOS DO CURSOR FOR C_NF_IT
                    INSERT INTO NOTA_FISCAL_ITENS (cod_empresa,num_nf,seq_mat,cod_mat,qtd,val_unit,ped_orig)
                    Values(p_emp,v_num_nf,c_nf_it.seq_mat,c_nf_it.Cod_Mat,c_nf_it.qtd,c_nf_it.val_unit,docto);
                    dbms_output.put_line ('SEQ: '||C_NF_IT.SEQ_MAT||' COD MAT: '||C_NF_IT.COD_MAT||' QTD:'||C_NF_IT.QTD||' VAL_UNIT: '||C_NF_IT.VAL_UNIT);
			
                    --ATRIBUINDO VALORES
                    v_total_nfe:=v_total_nfe+(c_nf_it.qtd*c_nf_it.val_unit);
                END LOOP; 
  
                --ATUALIZANDO TOTAL NFE
                UPDATE NOTA_FISCAL SET total_nf=v_total_nfe WHERE num_nf=v_num_nf AND cod_empresa=p_emp;
                --ATUALIZADO STATUS PARA FECHADO NFE
                UPDATE PED_VENDAS SET situacao='F' WHERE num_pedido=docto AND cod_empresa=p_emp;
                
            END LOOP; -- CURSOR NFE CABEÇALHO
            
        --ELSEIF PARA ENTRADA
        ELSIF tip_nf='E' THEN
            FOR C_NF IN (SELECT A.cod_empresa,A.num_pedido,A.id_for as ID_CLIFOR,A.cod_pagto FROM  PED_COMPRAS A 
            WHERE A.num_pedido=docto AND A.cod_empresa=p_emp AND A.situacao<>'F') 
            LOOP
                --INSERINDO DADOS DO CURSOR FOR
                INSERT INTO NOTA_FISCAL (cod_empresa,num_nf,tip_nf,cod_cfop,id_clifor,Cod_Pagto,data_emissao,data_entrega,total_nf,integrada_fin,integrada_sup)
                values(p_emp,null,tip_nf,cfop,c_nf.id_clifor,c_nf.cod_pagto,data_emis,data_entrega,0,'N','N')
                RETURNING num_nf INTO v_num_nf; --PEGANDO VALOR DO NFE INSERIDO E ATRIBUINDO VALOR
				dbms_output.put_line('NUM_NF: '||V_NUM_NF||'Tip NFE: '||TIP_NF||' CFOP: '||CFOP||' COD CLIFOR: '||C_NF.ID_CLIFOR||'COD PAGTO: '||C_NF.COD_PAGTO||' DATA_EMIS: '|| DATA_EMIS||'DATA_ENTREGA: '||DATA_ENTREGA);

                --CURSOR DETALHE PED INICIO
                FOR C_NF_IT IN (SELECT A.seq_mat,A.cod_mat,A.qtd,A.val_unit FROM PED_COMPRAS_ITENS A
                WHERE A.num_pedido=docto AND cod_empresa=p_emp ORDER BY A.seq_mat) 
                LOOP
                    INSERT INTO NOTA_FISCAL_ITENS (cod_empresa,num_nf,seq_mat,cod_mat,qtd,val_unit,ped_orig)
                    values(p_emp,v_num_nf,c_nf_it.seq_mat,c_nf_it.cod_mat,c_nf_it.qtd,c_nf_it.val_unit,docto);
                    dbms_output.put_line('SEQ: '||C_NF_IT.SEQ_MAT||'COD MAT: '||C_NF_IT.COD_MAT||'QTD: '||C_NF_IT.QTD||' VAL_UNIT: '||C_NF_IT.VAL_UNIT);
			
                    --ATRIBUINDO VALORES
                    v_total_nfe:=v_total_nfe+(c_nf_it.qtd*c_nf_it.val_unit);
                END LOOP; 
  
                --ATUALIZANDO TOTAL NFE
                UPDATE NOTA_FISCAL SET total_nf=v_total_nfe WHERE num_nf=v_num_nf AND cod_empresa=p_emp;
                --ATUALIZADO STATUS PARA FECHADO NFE
                UPDATE PED_COMPRAS  SET situacao='F' WHERE num_pedido=docto AND cod_empresa=p_emp;
            END LOOP; -- CURSOR NFE CABEÇALHO
        END IF;
        COMMIT;
        dbms_output.put_line('FINALIZADA COM SUCESSO!');
  
        --VALIDACOES 
        EXCEPTION
        WHEN exc_lanc_futuro THEN
            dbms_output.put_line('NAO PERMITIDO LANCAMENTOS FUTUROS!');
        ROLLBACK;
    
        WHEN exc_tip_nf THEN
            dbms_output.put_line('OPERACAO NAO PERMITIDA!');
        ROLLBACK;
        
        WHEN  exc_qtd_ped_vend THEN
            dbms_output.put_line('NAO A PEDIDO DE VENDAS DISPONIVEL PARA SAIDA!');     
        ROLLBACK;
        
        WHEN  exc_qtd_ped_comp THEN
            dbms_output.put_line('NAO A PEDIDO DE COMPRAS DISPONIVEL PARA ENTRADA');
        
        WHEN  no_data_found  THEN
            dbms_output.put_line('NAO EXISTE DADOS!');
        
        WHEN OTHERS THEN
            dbms_output.put_line('OUTROS CODIGO DO ERRO '||SQLCODE||' MSG '||SQLERRM);
            dbms_output.put_line('Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        ROLLBACK;

END;
   
/*
SELECT * FROM NOTA_FISCAL_ITENS
--PARAMENTROS                  P_EMP IN NUMBER,
                               TIP_NF IN CHAR(1),--E = ENTRADA S= SAIDA
                               DOCTO IN NUMBER, --NUMERO DO PEDIDO QUE SERA GERADO NFE
							   CFOP VARCHAR2,
							   DATA_EMIS DATE,
							   DATA_ENTREGA
*/                               

SET SERVEROUTPUT ON    
EXECUTE PROC_GERA_NF (1,'S',1,'5.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'S',2,'5.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'S',3,'5.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'S',4,'5.101','21/01/2018','22/01/2018');

EXECUTE PROC_GERA_NF (1,'E',7,'1.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'E',8,'1.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'E',9,'1.101','21/01/2018','22/01/2018');
EXECUTE PROC_GERA_NF (1,'E',10,'1.101','21/01/2018','22/01/2018');



/*
SELECT COD_EMPRESA,NUM_PEDIDO,SITUACAO FROM PED_VENDAS;
SELECT  COD_EMPRESA,NUM_PEDIDO,SITUACAO FROM PED_COMPRAS;

SELECT * FROM NOTA_FISCAL
ORDER BY NUM_NF;
WHERE NUM_NF=7
AND COD_EMPRESA=1;

SELECT  * FROM NOTA_FISCAL_ITENS
WHERE NUM_NF=7
AND COD_EMPRESA=1

SELECT  * FROM PED_VENDAS_ITENS;
SELECT  * FROM PED_COMPRAS_ITENS
WHERE COD_EMPRESA=1
AND NUM_PEDIDO=9
*/

--DELETE FROM NOTA_FISCAL_ITENS;
--DELETE FROM NOTA_FISCAL;
/*
UPDATE  PED_VENDAS SET SITUACAO='P' WHERE SITUACAO='F' ;
UPDATE  PED_COMPRAS SET SITUACAO='P' WHERE SITUACAO='F' ;
*/