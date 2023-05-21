DECLARE
    /* Storing information about employees, index - employee number */
    TYPE i_emps IS TABLE OF 
		employees%ROWTYPE
	INDEX BY PLS_INTEGER;
    v_emps i_emps;
    
    /* Cursor for storing information about employees */
    CURSOR c_emps IS
		SELECT *
		FROM employees;
    
    /* Cursor for storing information about transfers to another position */
	CURSOR c_jobs(emp_id IN employees.employee_id%TYPE) IS
		SELECT *
		FROM job_history
		WHERE employee_id = emp_id;
    
    /* Information about the title of the position by its id */
    TYPE i_jobs_name IS TABLE OF 
		jobs.job_title%TYPE
	INDEX BY jobs.job_title%TYPE;
    v_jobs_name i_jobs_name;
    
    /* Cursor for storing information about positions */
    CURSOR c_jobs_name IS
        SELECT job_id, job_title
        FROM jobs;
    
    /* Cursor for storing the number of transfers */    
    CURSOR c_count_job(emp_id IN employees.employee_id%TYPE) IS
        SELECT COUNT(job_id) 
        FROM job_history 
        WHERE employee_id = emp_id
        GROUP BY employee_id;
    
    v_num NUMBER(10) := 1; /* numbering of employees */
    v_count NUMBER(10); /* number for recording transfer numbers */
    v_count_max NUMBER(10); /* total number of transfers */
    v_end_date job_history.end_date%TYPE; /* end date of the previous position */
BEGIN
    FOR emp IN c_emps LOOP
        v_emps(emp.employee_id) := emp;
    END LOOP;
    
    FOR jobs IN c_jobs_name LOOP
        v_jobs_name(jobs.job_id) := jobs.job_title;
    END LOOP;
    
    FOR emp IN v_emps.FIRST .. v_emps.LAST LOOP
        v_count := NULL;
        v_count_max := NULL;
        v_end_date := NULL;
        
        IF NOT v_emps.EXISTS(emp) THEN
            CONTINUE;
        ELSE
            IF NOT c_count_job%ISOPEN THEN
                OPEN c_count_job(emp);
            END IF;

            FETCH c_count_job INTO v_count_max; 
            v_count := v_count_max; 
            IF c_count_job%ISOPEN THEN
                CLOSE c_count_job;
            END IF;
            
            IF v_count IS NULL THEN
                DBMS_OUTPUT.PUT_LINE(v_num || '. Сотрудник ' || v_emps(emp).first_name || ' ' || v_emps(emp).last_name);
                DBMS_OUTPUT.PUT_LINE('    принят на работу ' || v_emps(emp).hire_date || ',');      
            
                DBMS_OUTPUT.PUT_LINE('    работал в должности ' || v_jobs_name(v_emps(emp).job_id) || ' с ' || v_emps(emp).hire_date || ' ' || ROUND(SYSDATE - v_emps(emp).hire_date) || 
                    CASE 
							WHEN ROUND(SYSDATE - v_emps(emp).hire_date) = 1 
                                OR MOD(ROUND(SYSDATE - v_emps(emp).hire_date), 10) = 1 
                                    THEN ' день'
							WHEN ROUND(SYSDATE - v_emps(emp).hire_date) = 1 
                                OR MOD(ROUND(SYSDATE - v_emps(emp).hire_date), 10) = 1 
                                    THEN ' дня'
							ELSE
								' дней'
                    END || ' по ' || SYSDATE);
            ELSE                
                FOR jobs IN c_jobs(emp) LOOP
                    IF v_count = v_count_max THEN 
                        DBMS_OUTPUT.PUT_LINE(v_num || '. Сотрудник ' || v_emps(emp).first_name || ' ' || v_emps(emp).last_name);
                        DBMS_OUTPUT.PUT_LINE('    принят на работу ' || jobs.start_date || ',');
                    END IF;
                    
                    IF ROUND(jobs.start_date - v_end_date) != 1 THEN
                        DBMS_OUTPUT.PUT_LINE('    затем ' || ROUND(jobs.start_date - v_end_date) || 
                            CASE 
                                    WHEN ROUND(jobs.start_date - v_end_date) = 1 
                                        OR MOD(ROUND(jobs.start_date - v_end_date), 10) = 1 
                                            THEN ' день'
                                    WHEN ROUND(jobs.start_date - v_end_date) = 1 
                                        OR MOD(ROUND(jobs.start_date - v_end_date), 10) = 1 
                                            THEN ' дня'
                                    ELSE
                                        ' дней'
                            END || ' на должностях не числился,');
                    END IF;
                    
                    IF v_count = v_count_max THEN
                        DBMS_OUTPUT.PUT_LINE('    работал в должности ' || v_jobs_name(jobs.job_id) || ' с ' || jobs.start_date || ' ' || ROUND(jobs.end_date - jobs.start_date) || 
                        CASE 
                                WHEN ROUND(jobs.end_date - jobs.start_date) = 1 
                                    OR MOD(ROUND(jobs.end_date - jobs.start_date), 10) = 1 
                                        THEN ' день'
                                WHEN ROUND(jobs.end_date - jobs.start_date) = 1 
                                    OR MOD(ROUND(jobs.end_date - jobs.start_date), 10) = 1 
                                        THEN ' дня'
                                ELSE
                                    ' дней'
                        END || ' по ' || jobs.end_date || ',');
                    ELSE                      
                        DBMS_OUTPUT.PUT_LINE('    затем ' || jobs.start_date || ' перешёл на должность ' || v_jobs_name(jobs.job_id) || ' и работал в должности ' || ROUND(jobs.end_date - jobs.start_date) || 
                            CASE 
                                    WHEN ROUND(jobs.end_date - jobs.start_date) = 1 
                                        OR MOD(ROUND(jobs.end_date - jobs.start_date), 10) = 1 
                                            THEN ' день'
                                    WHEN ROUND(jobs.end_date - jobs.start_date) = 1 
                                        OR MOD(ROUND(jobs.end_date - jobs.start_date), 10) = 1 
                                            THEN ' дня'
                                    ELSE
                                        ' дней'
                            END || ' по ' || jobs.end_date || ',');
                    END IF;
                    v_count := v_count - 1;
                    v_end_date := jobs.end_date; 
                END LOOP;
                
                IF ROUND(v_emps(emp).hire_date - v_end_date) != 1 THEN
                    DBMS_OUTPUT.PUT_LINE('    затем ' || ROUND(v_emps(emp).hire_date - v_end_date) || 
                            CASE 
                                    WHEN ROUND(v_emps(emp).hire_date - v_end_date) = 1 
                                        OR MOD(ROUND(v_emps(emp).hire_date - v_end_date), 10) = 1 
                                            THEN ' день'
                                    WHEN ROUND(v_emps(emp).hire_date - v_end_date) = 1 
                                        OR MOD(ROUND(v_emps(emp).hire_date - v_end_date), 10) = 1 
                                            THEN ' дня'
                                    ELSE
                                        ' дней'
                            END || ' на должностях не числился,');
                END IF;
                DBMS_OUTPUT.PUT_LINE('    затем ' || v_emps(emp).hire_date || ' перешёл на должность ' || v_jobs_name(v_emps(emp).job_id) || ' и работал в должности ' || ROUND(SYSDATE - v_emps(emp).hire_date) || 
                    CASE 
							WHEN ROUND(SYSDATE - v_emps(emp).hire_date) = 1 
                                OR MOD(ROUND(SYSDATE - v_emps(emp).hire_date), 10) = 1 
                                    THEN ' день'
							WHEN ROUND(SYSDATE - v_emps(emp).hire_date) = 1 
                                OR MOD(ROUND(SYSDATE - v_emps(emp).hire_date), 10) = 1 
                                    THEN ' дня'
							ELSE
								' дней'
                    END || ' по ' || SYSDATE);
            END IF;
        END IF;
        v_num := v_num + 1;
    END LOOP;
END;
