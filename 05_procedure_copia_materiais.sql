/*
Essa Procesure tem comobjetivo realizar as cópias de materiais entre uma 
empresa e outra, facilitando assim, o processo de preenchimento das tabelas
*/

--PROCEDURE PARA COPIA DE MATERIAL
CREATE OR REPLACE PROCEDURE PROC_COPIA_MAT 
                            (
                             v_emp_de in number,
                             v_emp_para in number, 
                             v_mat in number
                            )
                            is
--VARIAVEI DE EXCESSOES   
v_execpt_emp_de exception;
v_execpt_emp_para exception;
v_execpt_emp_mat_de exception;
v_execpt_emp_mat_para exception;
        --VARIAVES DE APOIO CONTROLE
        v_cont_emp_de number;
        v_cont_emp_para number;
        v_cont_emp_mat_de number;
        v_cont_emp_mat_para number;
   
BEGIN
        --VERIFICA SE EMPRESA ORIGEM EXISTE (DE)
            SELECT COUNT(*) QTD INTO v_cont_emp_de FROM EMPRESA WHERE cod_empresa=v_emp_de;
            IF (v_cont_emp_de=0) THEN 
                RAISE v_execpt_emp_de;
            END IF;
    
        --VERIFICA SE EMPRESA DESTINO EXISTE (PARA)
            SELECT COUNT(*) QTD INTO v_cont_emp_para FROM EMPRESA WHERE cod_empresa=v_emp_para;
            IF (v_cont_emp_para=0) THEN
                RAISE v_execpt_emp_para;
            END IF;
    
        --VERIFICA SE MATERIAL ORIGEM EXISTE
            SELECT COUNT(*) QTD INTO v_cont_emp_mat_de FROM MATERIAL WHERE cod_empresa=v_emp_de AND cod_mat=v_mat;
            IF (v_cont_emp_mat_de=0) THEN
                RAISE v_execpt_emp_mat_de;
            END IF;
    
        --VERIFICA SE MATERIAL DESTINO EXISTE
            SELECT COUNT(*) QTD INTO v_cont_emp_mat_para FROM MATERIAL WHERE cod_empresa=v_emp_para AND cod_mat=v_mat;
            IF (v_cont_emp_mat_para=1) THEN
                RAISE v_execpt_emp_mat_para;
            END IF;
 
    INSERT INTO MATERIAL
    SELECT v_emp_para,cod_mat,descricao,preco_unit,cod_tip_mat FROM MATERIAL
    WHERE cod_mat=v_mat AND cod_empresa=v_emp_de;
    COMMIT;
    dbms_output.put_line('COPIA REALIZADA COM SUCESSO!');
 
    EXCEPTION
    WHEN v_execpt_emp_de THEN
        dbms_output.put_line('ATENÇÃO! EMPRESA ORIGEM NAO EXISTE');
    WHEN V_EXECPT_EMP_PARA THEN
        dbms_output.put_line('ATENÇÃO! EMPRESA DESTINO NAO EXISTE');
    WHEN V_EXECPT_EMP_MAT_DE THEN
        dbms_output.put_line('ATENÇÃO! MATERIAL NAO EXISTE NA EMPRESA ORIGEM');
    WHEN V_EXECPT_EMP_MAT_PARA THEN
        dbms_output.put_line('ATENÇÃO! MATERIAL JA EXISTE NA EMPRESA DESTINO');
        --RAISE_APPLICATION_ERROR(-20999,'ATENÇÃO! MATERIAL JA EXISTE NA EMPRESA DESTINO', FALSE);
    WHEN OTHERS THEN
        dbms_output.put_line('OCORREU UM ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
END;

--EXECUTANDO PREOCEDURE
--PARAMENTROS EMPRESA ORIGEM, EMPRESA DESTINO E MATERIAL A SER COPIADO
SET SERVEROUTPUT ON
--Testando as excessões
EXECUTE PROC_COPIA_MAT (9,1,1);
EXECUTE PROC_COPIA_MAT (1,9,1);
EXECUTE PROC_COPIA_MAT (1,2,99);
EXECUTE PROC_COPIA_MAT (1,2,1);
EXECUTE PROC_COPIA_MAT (1,2,2);
        --TESTANDO A CÓPIA DE MATERIAIS
        SELECT * FROM MATERIAL;

 --APOS INTEGRAÇÃO DE COPIA / Agora que existem materiais cadastrados na empresa 2 sera possivel criar pedidos de venda/compra
 INSERT INTO PED_VENDAS_ITENS values(2,1,1,1,50,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,1,2,2,35,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,2,1,1,50,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,2,2,2,35,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,3,1,1,100,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,3,2,2,100,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,4,1,1,50,2500);
 INSERT INTO PED_VENDAS_ITENS values(2,4,2,2,35,2500);
 
 --DELETE FROM PED_VENDAS_ITENS WHERE COD_EMPRESA=2;
 --DELETE FROM MATERIAL WHERE COD_EMPRESA=2;