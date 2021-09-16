/*
Objetivo dessa Procedure é realizar o controle e gestão de estoque
VERIFICAR SE A OPERACAO E PERMITIDA (-E ENTRADA E S SAIDA
VERIFICAR SE O MATERIAL EXISTE

-- VERIFICOES DE SAIDA
1 VERIFICAR SE MATERIAL TEM SALDO ESTOQUE E E QTD SAIDA E MENOR QUE SALDO
2 VERIFICAR SE MATERIAL TEM SALDO ESTOQUE_LOTE E E QTD SAIDA E MENOR QUE SALDO DO LOTE

-- VERIFICACOES ENTRADA
1 SE MATERIAL EXISTE UPDATE
2 SENAO EXISTE INSERT

TABELAS ENVOLVIDAS
ESTOQUE
ESTOQUE_LOTE
ESTQUE_MOV
*/

--CRIANDO PROCEDURE DE MOVIMENTAÇÃO DE MATERIAIS
CREATE OR REPLACE PROCEDURE PRC_MOV_ESTOQUE 
                            (
                             p_oper in varchar2,
                             p_emp in number,
                             p_cod_mat in int,
                             p_lote in varchar2,
                             p_qtd in int,
                             p_data_mov date
                            )
                            is

--VARIAVEIS DE EXCEÇÃO
exc_mat_n_existe exception;
exc_operacao_nao_permitida exception;
exc_estoque_negativo exception;
exc_estoque_negativo_lote exception;
--VARIAVEIS AUXILIARES
v_saldo_estoque int;
v_saldo_estoque_lote int;
v_mat_existe int ;
v_reg_estoque int;
v_reg_estoque_lote int;


BEGIN 
        -- VERIFICANDO SE OPERACAO É PERMITIDA;
        IF p_oper NOT IN ('E','S') THEN
            RAISE exc_operacao_nao_permitida;
        ELSE 
            dbms_output.put_line('OPERACAO OK! CONTINUA!');
        END IF;
        
        -- VERIFICANDO SE MATERIAL EXISTE
        SELECT COUNT(*) INTO v_mat_existe FROM MATERIAL WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp;
        IF v_mat_existe=0 THEN
            RAISE exc_mat_n_existe;
        ELSE
            dbms_output.put_line('MATERIAL EXISTE! CONTINUA');
        END IF;
  
        -- VERIFICANDO SE EXISTE REGISTRO EM ESTOQUE
        SELECT COUNT(*) INTO v_reg_estoque FROM ESTOQUE WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp;
        dbms_output.put_line('QTD REG ESTOQUE '||v_reg_estoque);
        
        -- VERIFICANDO OPERACAO DE SAIDA SE MATERIAL EXISTE NAO ESTOQUE
        IF p_oper='S' AND v_reg_estoque=0 THEN
            RAISE exc_estoque_negativo;
        ELSIF p_oper='S' AND v_reg_estoque>0  THEN
            -- ATRIBUINDO SALDO DE ESTOQUE E QTD REGISTRO
            SELECT qtd_saldo,COUNT(*) INTO v_saldo_estoque,v_reg_estoque FROM ESTOQUE 
            WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp
            GROUP BY qtd_saldo;
            dbms_output.put_line('TEM ESTOQUE');
        END IF;
  
        -- VERIFICANDO SE EXISTE REGISTRO EM ESTOQUE LOTE
        SELECT COUNT(*) INTO v_reg_estoque_lote FROM ESTOQUE_LOTE WHERE cod_mat=p_cod_mat AND lote=p_lote AND cod_empresa=p_emp;
        dbms_output.put_line('QTD REG ESTOQUE LOTE '||v_reg_estoque_lote);
        
        -- VERIFICANDO OPERACAO DE SAIDA SE MATERIAL EXISTE OU NAO EM LOTE NO ESTOQUE
        IF p_oper='S' AND v_reg_estoque_lote=0 THEN
            RAISE Exc_Estoque_Negativo_Lote;
        ELSIF p_oper='S' AND v_reg_estoque_lote>0 THEN
            -- ATRIBUINDO SALDO DE ESTOQUE_LOTE E QTD REGISTRO
            SELECT SUM(QTD_LOTE),COUNT(*) INTO v_saldo_estoque_lote,v_reg_estoque_lote FROM ESTOQUE_LOTE 
            WHERE cod_mat=p_cod_mat AND lote=p_lote AND cod_empresa=p_emp;
            dbms_output.put_line('TEM ESTOQUE LOTE');
        END IF;

        -- VERIFICANDO OPERAÇÃO DE SAIDA  
        -- VERIFICANDO SE AS OPERAÇÕES EM LOTE SÃO POSSIVEIS, CASO SEJAM, PODEMOS EXECUTAR E ATUALIZAR AS TABELAS
        IF p_oper='S' AND  (v_saldo_estoque_lote-p_qtd<0 OR v_saldo_estoque-p_qtd<0) THEN
            RAISE exc_estoque_negativo_lote;
        ELSIF p_oper='S' AND  v_saldo_estoque_lote-p_qtd>=0 AND v_saldo_estoque-p_qtd>=0 THEN
            -- ATUALIZA ESTOQUE
            UPDATE ESTOQUE SET qtd_saldo=qtd_saldo-p_qtd WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp;
            -- ATUALIZA ESTOQUE LOTE
            UPDATE ESTOQUE_LOTE SET qtd_lote=qtd_lote-p_qtd WHERE cod_mat=p_cod_mat AND lote=p_lote AND cod_empresa=p_emp;
            -- INSERE ESTOQUE TIP_MOV
            INSERT INTO ESTOQUE_MOV (id_mov,cod_empresa,tip_mov,cod_mat,lote,qtd,login,data_hora,data_mov) 
            values(null,p_emp,p_oper,p_cod_mat,p_lote,p_qtd,USER,SYSDATE,p_data_mov);
            COMMIT;
            dbms_output.put_line('OPERACAO FINALIZADA');
        END IF;
    
        -- VERIFICANDO OPERACAO DE ENTRADA
        -- VERIFICANDO SE AS OPERAÇÕES EM LOTE SÃO POSSIVEIS, CASO SEJAM, PODEMOS EXECUTAR E ATUALIZAR AS TABELAS
        IF p_oper='E' AND v_reg_estoque_lote>0 AND v_reg_estoque>0 THEN
            -- ATUALIZANDO ESTOQUE
            UPDATE ESTOQUE SET qtd_saldo=qtd_saldo+p_qtd WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp;
            -- ATUALIZANDO ESTOQUE_LOTE
            UPDATE ESTOQUE_LOTE SET qtd_lote=qtd_lote+p_qtd WHERE cod_mat=p_cod_mat AND lote=p_lote AND cod_empresa=p_emp;
            -- INSERE ESTOQUE TIP_MOV
            INSERT INTO ESTOQUE_MOV (id_mov,cod_empresa,tip_mov,cod_mat,lote,qtd,login,data_hora,data_mov) 
            values(null,p_emp,p_oper,p_cod_mat,p_lote,p_qtd,USER,SYSDATE,p_data_mov);
            COMMIT;
            dbms_output.put_line('OPERACAO FINALIZADA');
            
        -- VERIFICA QUE EXISTE ESTOQUE MAS NAO EXISTE ESTOQUE LOTE PARA INSERT ESTOQUE LOTE E UPDATE ESTOQUE
        ELSIF p_oper='E' AND v_reg_estoque_lote=0 AND v_reg_estoque>0 THEN
            -- ATUALIZANDO ESTOQUE
            UPDATE ESTOQUE SET qtd_saldo=qtd_saldo+p_qtd WHERE cod_mat=p_cod_mat AND cod_empresa=p_emp;
            -- INSERINDO REGISTRO NA ESTOQUE LOTE
            INSERT INTO ESTOQUE_LOTE (cod_empresa,cod_mat,Qtd_Lote,lote) values(p_emp,p_cod_mat,p_qtd,p_lote); -- criando novo lote
            -- INSERE ESTOQUE TIP_MOV
            INSERT INTO ESTOQUE_MOV (id_mov,cod_empresa,tip_mov,cod_mat,lote,qtd,login,data_hora,data_mov) 
            values(null,p_emp,p_oper,p_cod_mat,P_Lote,p_qtd,USER,SYSDATE,p_data_mov);
            COMMIT;
            dbms_output.put_line('OPERACAO FINALIZADA');
            
        -- VERIFICANDO QUE NAO EXISTE ESTOQUE E ESTOQUE LOTE PARA INSERT
        ELSIF p_oper='E' AND v_reg_estoque_lote=0 AND V_Reg_Estoque=0 THEN
            -- INSERINDO ESTOQUE
            INSERT INTO  ESTOQUE (cod_empresa,cod_mat,qtd_saldo) values(p_emp,p_cod_mat,p_qtd);
            --INSERINDO REGISTRO NA ESTOQUE LOTE
            INSERT INTO ESTOQUE_LOTE (cod_empresa,cod_mat,qtd_lote,lote) values(p_emp,p_cod_mat,p_qtd,p_lote);
            --INSERE ESTOQUE TIP_MOV
            INSERT INTO ESTOQUE_MOV (id_mov,cod_empresa,tip_mov,cod_mat,lote,qtd,login,data_hora,data_mov) 
            values(null,p_emp,p_oper,p_cod_mat,p_lote,p_qtd,USER,SYSDATE,p_data_mov);
            COMMIT;
            dbms_output.put_line('OPERACAO FINALIZADA');
        END IF;

        --EXCESSOES
        EXCEPTION
            WHEN exc_operacao_nao_permitida THEN
                dbms_output.put_line('A OPERACAO DEVER SER E-ENTRADA OU S-SAIDA');
            ROLLBACK;
     
            WHEN exc_mat_n_existe THEN
                dbms_output.put_line('MATERIAL NAO EXISTE CADASTRO');
            ROLLBACK;
     
            WHEN exc_estoque_negativo THEN
                dbms_output.put_line('ESTOQUE NEGATIVO,OPERACAO NAO PERMITIDA!!!');
            ROLLBACK;
     
            WHEN exc_estoque_negativo_lote THEN
                dbms_output.put_line('ESTOQUE LOTE NEGATIVO,OPERACAO NAO PERMITIDA!!!');
            ROLLBACK;
    
            WHEN no_data_found THEN
                dbms_output.put_line('REGISTRO NAO ENCONTRADO!');
                dbms_output.put_line('Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            ROLLBACK;
         
            WHEN OTHERS THEN
                dbms_output.put_line('CODIGO DO ERRO '||SQLCODE||' MSG '||SQLERRM);
                dbms_output.put_line('Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
            ROLLBACK;
END;

--PARAMETROS OPERACAO,COD_EMPRESA,MATERIAL,LOTE,QTD
EXECUTE PRC_MOV_ESTOQUE ('S',1,1,'ABC',10,'01/01/2021');
        --VERIFICANDO AS OPERAÇÕES
        SELECT * FROM MATERIAL;
        SELECT * FROM ESTOQUE;
        SELECT * FROM ESTOQUE_LOTE;
        SELECT * FROM ESTOQUE_MOV;
        SELECT a.*,TO_CHAR(a.DATA_HORA,'dd/mm/yyyy hh24:mi:ss') data FROM ESTOQUE_MOV a;
        SELECT TO_CHAR(DATA_HORA,'cc dd/mm/yyyy hh24:mi:ss') data from ESTOQUE_MOV;
        SELECT TO_CHAR(sysdate,'cc dd/mm/yyyy hh24:mi:ss') data from dual;
        SELECT TO_CHAR(sysdate,'cc dd/mm/yyyy hh24:mi:ss'), TO_CHAR(current_date,'cc dd/mm/yyyy hh24:mi:ss'), SYSDATE, current_date FROM DUAL;
/*
DELETE from ESTOQUE;
DELETE FROM ESTOQUE_LOTE;
DELETE FROM ESTOQUE_MOV;
*/

