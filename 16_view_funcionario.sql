--V_FUNCIONARIO
--TABELAS FUNCIONARIO,CARGOS,CENTRO_CUSTO
--SELECT * FROM V_FUNCIONARIO
CREATE OR REPLACE VIEW V_FUNCIONARIO as
	SELECT A.cod_empresa, A.matricula, A.cod_cc, C.nome_cc, A.nome, A.cod_cargo, B.nome_cargo, A.data_admiss, A.date_demiss,
	CASE WHEN A.date_demiss is null THEN 'ATIVO'
         ELSE 'DESLIGADO' END SITUACAO
		 FROM FUNCIONARIO A
		 INNER JOIN CARGOS B
		 ON A.cod_cargo=B.cod_cargo AND A.Cod_Empresa=B.cod_empresa
         
		 INNER JOIN CENTRO_CUSTO C
		 ON A.cod_cc=C.cod_cc AND A.cod_empresa=C.cod_empresa;
         
--TESTANDO VIEW  
SELECT * FROM V_FUNCIONARIO






