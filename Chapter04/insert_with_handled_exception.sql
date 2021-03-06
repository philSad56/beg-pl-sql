rem insert_with_handle_exception.sql
rem by Donald J. Bales on 12/15/2006
rem An anonymous PL/SQL procedure to insert
rem values using PL/SQL literals and variables

set serveroutput on size 1000000;

declare

-- I declared these variables so I can get
-- the required ID values before I insert.
n_id                                  WORKER_T.id%TYPE;
n_worker_type_id                      WORKER_T.worker_type_id%TYPE;
v_external_id                         WORKER_T.external_id%TYPE;
n_gender_id                           WORKER_T.gender_id%TYPE;

-- I'll use this variable to hold the result
-- of the SQL insert statement.
n_count                               number;

begin

  -- First, let's get the worker_type_id for a contractor
  begin
    select worker_type_id
    into   n_worker_type_id
    from   WORKER_TYPE_T
    where  code = 'C';
  exception
    when OTHERS then
      raise_application_error(-20002, SQLERRM||
        ' on select WORKER_TYPE_T'||
        ' in filename insert.sql');
  end;
  
  -- Next, let's get the gender_id for a male
  begin
    select gender_id
    into   n_gender_id
    from   GENDER_T
    where  code = 'M';
  exception
    when OTHERS then
      raise_application_error(-20004, SQLERRM||
        ' on select GENDER_T'||
        ' in filename insert.sql');
  end;
  
  -- Now, let's get the next id sequence
  begin
    select WORKER_ID_SEQ.nextval
    into   n_id
    from   SYS.DUAL;
  exception
    when OTHERS then
      raise_application_error(-20001, SQLERRM||
        ' on select WORKER_ID_SEQ.nextval'||
        ' in filename insert.sql');
  end;

  -- And then, let's get the next external_id sequence
  begin
    select lpad(to_char(EXTERNAL_ID_SEQ.nextval), 9, '0')
    into   v_external_id
    from   SYS.DUAL;
  exception
    when OTHERS then
      raise_application_error(-20003, SQLERRM||
        ' on select EXTERNAL_ID_SEQ.nextval'||
        ' in filename insert.sql');
  end;
  
  -- Now that we have all the necessary ID values
  -- we can finally insert a row!
  begin
    insert into WORKER_T (
           id,      
           worker_type_id,
           external_id,    
           first_name,     
           middle_name,    
           last_name,      
           name,           
           birth_date,     
           gender_id )
    values (
           n_id,                     -- a variable
           n_worker_type_id,                -- a variable
           v_external_id,                   -- a variable
           'JOHN',                          -- a literal
           'J.',                            -- a literal
           'DOE',                           -- a literal
           'DOE, JOHN J.',                  -- a literal
           to_date('19800101', 'YYYYMMDD'), -- a function
           n_gender_id );                   -- a variable

    n_count := sql%rowcount;
  exception
    when DUP_VAL_ON_INDEX then
      n_count := 0;
      pl('Caught a DUP_VAL_ON_INDEX exception');
    when OTHERS then
      raise_application_error(-20005, SQLERRM||
        ' on insert WORKER_T'||
        ' in filename insert_with_handled_exception.sql');
  end;

  pl(to_char(n_count)||' row(s) inserted.');
end;
/

commit;
