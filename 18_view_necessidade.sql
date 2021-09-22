--V_NECCESSIDADES
--ORDEM_PROD,FICHA_TECNICA, ESTOQUE,MATERIAL

CREATE OR REPLACE VIEW V_NECCESSIDADES as
	SELECT A.cod_empresa,A.id_ordem,A.cod_mat_prod,A.qtd_plan,A.qtd_prod,A.qtd_plan-A.qtd_prod SALDO,B.cod_mat_neces,D.descricao,B.qtd_neces,
	       (A.qtd_plan-A.qtd_prod)*B.qtd_neces as QTD_REAL_NEC,nvl(C.qtd_saldo,0) AS QTD_SALDO,
           CASE WHEN (A.Qtd_Plan-A.qtd_prod)*B.qtd_neces>nvl(C.qtd_saldo,0) THEN 'FALTA ESTOQUE' 
                ELSE 'OK' END MSG
            
             FROM ORDEM_PROD A
             INNER JOIN FICHA_TECNICA B
             ON A.cod_mat_prod=B.cod_mat_prod AND A.cod_empresa=B.cod_empresa
             
             LEFT JOIN ESTOQUE C
             ON B.cod_mat_neces=C.cod_mat AND A.cod_empresa=C.cod_empresa
             
             INNER JOIN MATERIAL D
             ON B.cod_mat_neces=D.Cod_Mat AND A.cod_empresa=D.cod_empresa
             WHERE (A.qtd_plan-A.qtd_prod)<>0;
	 
--TESTE
SELECT * FROM V_NECCESSIDADES
WHERE cod_empresa=1 AND id_ordem=3;

SELECT * FROM FICHA_TECNICA
WHERE cod_mat_prod='1';
	 









