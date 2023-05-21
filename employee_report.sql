DECLARE
    /* Хранение информации про сотрудников, индекс - номер сотрудника */
    TYPE i_emps IS TABLE OF 
		employees%ROWTYPE
	INDEX BY PLS_INTEGER;
    v_emps i_emps;
    
    /* Курсор для хранения информации о сотрудниках */
    CURSOR c_emps IS
		SELECT *
		FROM employees;
    
    /* Курсор для хранения информации о переводах на другую должность */
	CURSOR c_jobs(emp_id IN employees.employee_id%TYPE) IS
		SELECT *
		FROM job_history
		WHERE employee_id = emp_id;
    
    /* Информация о названии должности по её id */
    TYPE i_jobs_name IS TABLE OF 
		jobs.job_title%TYPE
	INDEX BY jobs.job_title%TYPE;
    v_jobs_name i_jobs_name;
    
    /* Курсор для хранения информации о должностях */
    CURSOR c_jobs_name IS
        SELECT job_id, job_title
        FROM jobs;
    
    /* Курсор для хранения количеста переводов */    
    CURSOR c_count_job(emp_id IN employees.employee_id%TYPE) IS
        SELECT COUNT(job_id) 
        FROM job_history 
        WHERE employee_id = emp_id
        GROUP BY employee_id;
    
    v_num NUMBER(10) := 1; /* нумерация сотрудников */
    v_count NUMBER(10); /* номер для записи номера переводов */
    v_count_max NUMBER(10); /* общее количество переводов */
    v_end_date job_history.end_date%TYPE; /* дата окончания работы предыдущей должности */
BEGIN
    /* записываем информацию о сотрудниках */
    FOR emp IN c_emps LOOP
        v_emps(emp.employee_id) := emp;
    END LOOP;
    
    /* записываем информацию о названиях должностей */
    FOR jobs IN c_jobs_name LOOP
        v_jobs_name(jobs.job_id) := jobs.job_title;
    END LOOP;
    
    /* для всех сотрудников начинаем выводить информацию */
    FOR emp IN v_emps.FIRST .. v_emps.LAST LOOP
        v_count := NULL;
        v_count_max := NULL;
        v_end_date := NULL;
        
        /* если нет сотрудника с таким номером, то идем к следующей итерации */
        IF NOT v_emps.EXISTS(emp) THEN
            CONTINUE;
        ELSE
            IF NOT c_count_job%ISOPEN THEN
                OPEN c_count_job(emp);
            END IF;

            FETCH c_count_job INTO v_count_max; /* записываем количество переводов */
            v_count := v_count_max; 
            IF c_count_job%ISOPEN THEN
                CLOSE c_count_job;
            END IF;
            
            IF v_count IS NULL THEN
                /* если нет переводов выводим информацию о текущей должности */
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
                /* выводим информацию о каждом переводе */
                FOR jobs IN c_jobs(emp) LOOP
                    IF v_count = v_count_max THEN 
                        DBMS_OUTPUT.PUT_LINE(v_num || '. Сотрудник ' || v_emps(emp).first_name || ' ' || v_emps(emp).last_name);
                        DBMS_OUTPUT.PUT_LINE('    принят на работу ' || jobs.start_date || ',');
                    END IF;
                    
                    /* если был перерыв в работе, выводим соответствующую запись */
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
                    v_end_date := jobs.end_date; /* записываем дату окончания работы */
                END LOOP;
                
                /* если был перерыв в работе, выводим соответствующую запись */
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
