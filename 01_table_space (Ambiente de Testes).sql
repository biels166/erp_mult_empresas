-- CRIANDO TABLESPACE PARA O PROJETO BD ERP MULTI EMPRESA TESTE / PODERÁ SERVIR COMO BACKUP
 create tablespace erp_amb_tst
        datafile 'C:\app\gabri\product\18.0.0\oradata\XE\erp_amb_tst.dbf'  
		size 100m autoextend on next 50m maxsize 500m
        online
        permanent
        extent management local autoallocate
        segment space management auto;

-- criando usuario
create user user_tst
       identified by 123456 -- senha do usuário.
       default tablespace erp_amb_tst
       temporary tablespace TEMP;
-- concendendo permissoes para o usuario
grant ALL PRIVILEGES to user_tst;
-- alterando limite de cota para o usuario
alter user user_tst quota unlimited on erp_amb_tst;
--------------------------------------------------------------------------------
-- CRIANDO TABLESPACE PARA O PROJETO BD ERP MULTI EMPRESA PRODUCAO / SERÁ A TABLE SPACE FINAL DO PROJETO.
 create tablespace erp_amb_prd
        datafile 'C:\app\gabri\product\18.0.0\oradata\XE\erp_amb_prd.dbf'  
		size 100m autoextend on next 50m maxsize 500m
        online
        permanent
        extent management local autoallocate
        segment space management auto;

-- criando usuario
create user user_prd
       identified by 123456
       default tablespace erp_amb_prd
       temporary tablespace TEMP;
-- concendendo permissoes para o usuario
grant ALL PRIVILEGES to user_prd;
-- alterando limite de cota para o usuario
alter user user_prd quota unlimited on erp_amb_prd;

--------------------------------------------------------------------------------
-- Caso haja problemas na criação de usuarios, usar:
alter session set "_ORACLE_SCRIPT"=true;  

-- drop objetos
/*
drop user user_prd CASCADE;
drop user user_tst CASCADE;

drop tablespace erp_amb_prd INCLUDING CONTENTS AND DATAFILES;
drop tablespace erp_amb_tst INCLUDING CONTENTS AND DATAFILES;
*/