create or replace package job_frmwrk.pkg_job_api as 

/*********************************************************************************
  Object name  : job_frmwrk.pkg_job_api
  Description  : This package contains proecedure and fuctions that would be used 
                 to run batch jobs in framework. 
  Date           Change
  ----           ------
  02/28/2016     Initial code

**********************************************************************************/

procedure g_sp_insrt_trckg_id(i_job_dfntn_id number);

end pkg_job_api;
/
show errors;


create or replace package body job_frmwrk.pkg_job_api as
/*********************************************************************************
  Object name  : job_frmwrk.pkg_job_api
  Description  : This package contains proecedure and fuctions that would be used 
                 to run batch jobs in framework. 
  Date           Change
  ----           ------
  02/28/2016     Initial code

**********************************************************************************/


    procedure g_sp_insrt_trckg_id(i_job_dfntn_id in number,
                                  o_job_trckng_id out number) is 
    /*********************************************************************************
      Object name  : job_frmwrk.pkg_job_api.g_sp_insrt_trckg_id
      Description  : This procedure will insert a tracking id for a job to be executed
                     This takes job defition id as input paramenter and return tracking id. 
                     
      Date           Change
      ----           ------
      02/28/2016     Initial code
    
    **********************************************************************************/
    begin
      
      insert into JOB_FRMWRK.TB_JOB_TRCKNG
      (
        JOB_TRCKNG_ID,
        JOB_DFNTN_ID,
        JOB_TRCKNG_STRT_TME,
        JOB_TRCKNG_END_TME,
        JOB_EXEC_STTS_ID,
        JOB_TRCKNG_DRTN,
        JOB_TRCKNG_INSRT_DT
      )values
      (
        JOB_FRMWRK.sq_job_trckng_id.nextval,
        i_job_dfntn_id,
        sysdate,
        null,
        1,
        null,
        sysdate
      ) returning JOB_TRCKNG_ID 
        into o_job_trckng_id;
      
        commit;
    
    end;

end;
/
show errors;
