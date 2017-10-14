BEGIN
  DBMS_SCHEDULER.DROP_JOB (job_name        => 'TEST_DBMSJOB_SCH');

  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'TEST_DBMSJOB_SCH',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN JOB_FRMWRK.EMP_DETAILS.EMP_TABLE; END; ',
    start_date      => '27-feb-2016 04:00:00 pm',
    repeat_interval => 'freq=MINUTELY; BYSECOND=0',
    end_date        => '28-FEB-2016 04:35:00 PM',
    comments        => 'Job defined entirely by the CREATE JOB procedure.',
    ENABLED         => TRUE);
END;
/