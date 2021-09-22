--V_FATURAMENTO
--NOTA_FISCAL, NOTA_FISCAL_ITENS,MATERIAL,CLIENTES, CIDADES,
--SELECT * FROM MATERIAL
--SELECT * FROM CLIENTES
--SELECT * FROM CIDADES

CREATE OR REPLACE VIEW V_FATURAMENTO as
    SELECT A.cod_empresa, A.num_nf, A.id_clifor, A.data_emissao, B.cod_mat, C.descricao, D.razao_cliente, E.nome_cidade, B.qtd, B.val_unit, B.qtd*B.val_unit as  TOTAL
    FROM NOTA_FISCAL A 
    INNER JOIN NOTA_FISCAL_ITENS B
    ON A.num_nf=B.num_nf AND A.cod_empresa=B.cod_empresa
    
    INNER JOIN MATERIAL C
    ON B.cod_mat=C.Cod_Mat AND A.cod_empresa=C.cod_empresa
    
    INNER JOIN CLIENTES D
    ON A.id_clifor=D.id_cliente AND A.cod_empresa=D.Cod_Empresa
    
    INNER JOIN CIDADES E
    ON D.cod_cidade=E.cod_cidade WHERE A.tip_nf='S';
    
--TESTANDO A VIEW
SELECT * FROM V_FATURAMENTO
WHERE cod_empresa=1
ORDER BY num_nf;


--CRIAMOS INDICE PARA MELHORAR PERFORMANCE
--CREATE INDEX IX_FAT1 ON NOTA_FISCAL(TIP_NF)




