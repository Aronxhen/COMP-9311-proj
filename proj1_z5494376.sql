-- comp9311 23T3 Project 1

-- Q1:
CREATE OR REPLACE VIEW Q1(COURSE_CODE) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT SE.CODE AS COURSE_CODE
FROM SUBJECTS SE
WHERE SE.CODE like 'HIST3%';

-- Q2:
CREATE OR REPLACE VIEW Q2(COURSE_ID) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT CO.ID AS COURSE_ID
FROM COURSES CO
JOIN COURSE_ENROLMENTS CE ON CO.ID = CE.COURSE
JOIN STUDENTS S ON S.ID = CE.STUDENT
WHERE S.STYPE = 'local'
GROUP BY CO.ID
HAVING COUNT(CE.STUDENT) > 400;

-- Q3:
CREATE OR REPLACE VIEW Q3(COURSE_ID) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT CO.ID AS COURSE_ID
FROM COURSES CO
JOIN CLASSES CL ON CL.COURSE = CO.ID
JOIN CLASS_TYPES CLT ON CLT.ID = CL.CTYPE
JOIN ROOMS RMS ON RMS.ID = CL.ROOM
WHERE CLT.NAME = 'Lecture'
GROUP BY CO.ID
HAVING COUNT(CL.ID) = 4
AND COUNT(DISTINCT RMS.BUILDING) = 4;

-- Q4:
CREATE OR REPLACE VIEW Q4(UNSW_ID) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT DISTINCT PE.UNSWID AS UNSW_ID
FROM PEOPLE PE
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = PE.ID
JOIN COURSES CO ON CO.ID = CE.COURSE
JOIN SEMESTERS SE ON SE.ID = CO.SEMESTER
WHERE SE.YEAR = '2011'
	AND SE.TERM = 'X1'
	AND CE.GRADE = 'FL'
	AND PE.UNSWID NOT IN
		(SELECT DISTINCT PE2.UNSWID
			FROM PEOPLE PE2
			JOIN COURSE_ENROLMENTS CE2 ON CE2.STUDENT = PE2.ID
			JOIN COURSES CO2 ON CO2.ID = CE2.COURSE
			JOIN SEMESTERS SE2 ON SE2.ID = CO2.SEMESTER
			WHERE (SE2.YEAR != '2011' OR SE2.TERM != 'X1')
			AND CE2.GRADE = 'FL' );

-- Q5:
CREATE OR REPLACE VIEW Q5(COURSE_CODE) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT SE.CODE AS COURSE_CODE
FROM SUBJECTS SE
JOIN ORGUNITS OG ON OG.ID = SE.OFFEREDBY
JOIN ORGUNIT_TYPES OT ON OT.ID = OG.UTYPE
JOIN COURSES CO ON CO.SUBJECT = SE.ID
JOIN SEMESTERS ST ON ST.ID = CO.SEMESTER
JOIN COURSE_ENROLMENTS CE ON CE.COURSE = CO.ID
WHERE OT.NAME = 'Faculty'
	AND ST.YEAR = '2010'
	AND CE.GRADE = 'FL'
GROUP BY SE.CODE,
	CO.ID,
	SE.OFFEREDBY
HAVING COUNT(CE.STUDENT) =
	(SELECT MAX(FAIL_NUMBER)
	 FROM
		(SELECT COUNT(CE2.STUDENT) AS FAIL_NUMBER
			FROM SUBJECTS SE2
			JOIN COURSES CO2 ON CO2.SUBJECT = SE2.ID
			JOIN SEMESTERS ST2 ON ST2.ID = CO2.SEMESTER
			JOIN COURSE_ENROLMENTS CE2 ON CE2.COURSE = CO2.ID
			WHERE SE2.OFFEREDBY = SE.OFFEREDBY
				AND ST2.YEAR = '2010'
				AND CE2.GRADE = 'FL'
			GROUP BY SE2.CODE,
				CO2.ID,
				SE2.OFFEREDBY) AS TOTAL_FAIL);
				
-- Q6:
CREATE OR REPLACE VIEW Q6(COURSE_CODE,LECTURER_NAME) AS 
--... SQL statements, possibly using other views/functions defined by you ...
SELECT SJ.CODE AS COURSE_CODE,
	PEO.NAME AS LECTURER_NAME
FROM COURSE_ENROLMENTS CE
JOIN COURSES CO ON CO.ID = CE.COURSE
JOIN SUBJECTS SJ ON SJ.ID = CO.SUBJECT
JOIN COURSE_STAFF CSFF ON CSFF.COURSE = CO.ID
JOIN PEOPLE PEO ON PEO.ID = CSFF.STAFF
JOIN STAFF_ROLES SFFR ON SFFR.ID = CSFF.ROLE
WHERE SJ.CODE like 'COMP%'
	AND SFFR.NAME = 'Course Lecturer'
GROUP BY CO.ID,
	SJ.CODE,
	CSFF.STAFF,
	SFFR.NAME,
	PEO.NAME
HAVING AVG(CE.MARK) =
	(SELECT MAX(AVG_MARK)
		FROM
			(SELECT AVG(CE2.MARK) AS AVG_MARK
				FROM COURSE_ENROLMENTS CE2
				JOIN COURSES CO2 ON CO2.ID = CE2.COURSE
				JOIN SUBJECTS SJ2 ON SJ2.ID = CO2.SUBJECT
				JOIN COURSE_STAFF CSFF2 ON CSFF2.COURSE = CO2.ID
				JOIN PEOPLE PEO2 ON PEO2.ID = CSFF2.STAFF
				JOIN STAFF_ROLES SFFR2 ON SFFR2.ID = CSFF2.ROLE
				WHERE SJ2.CODE = SJ.CODE
					AND SFFR2.NAME = 'Course Lecturer'
				GROUP BY CO2.ID,
					CSFF2.STAFF,
					PEO2.NAME) AS TOTAL_AVG);
					
-- Q7:
--... SQL statements, possibly using other views/functions defined by you ...
CREATE OR REPLACE VIEW E10(STUDENT, SEMESTER) AS 
SELECT ER.STUDENT AS STUDENT, CR.SEMESTER AS SEMESTER
FROM COURSE_ENROLMENTS ER
JOIN COURSES CR ON CR.ID = ER.COURSE
GROUP BY ER.STUDENT, CR.SEMESTER
HAVING COUNT(ER.COURSE) >= 4
ORDER BY CR.SEMESTER;


CREATE OR REPLACE VIEW E14(STUDENT1, SEMESTER) AS 
SELECT PE.STUDENT AS STUDENT1, PE.SEMESTER AS SEMESTER
FROM PROGRAM_ENROLMENTS PE
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN ORGUNITS OG ON OG.ID = PO.OFFEREDBY
JOIN E10 ON PE.STUDENT = E10.STUDENT
AND PE.SEMESTER = E10.SEMESTER
WHERE OG.LONGNAME = 'Faculty of Engineering'
GROUP BY PE.STUDENT, 
  		PE.SEMESTER
ORDER BY PE.SEMESTER;

CREATE OR REPLACE VIEW E15(STUDENT2,SEMESTER) AS 
SELECT PE.STUDENT AS STUDENT1, PE.SEMESTER AS SEMESTER
FROM PROGRAM_ENROLMENTS PE
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN ORGUNITS OG ON OG.ID = PO.OFFEREDBY
JOIN E10 ON PE.STUDENT = E10.STUDENT
AND PE.SEMESTER = E10.SEMESTER
WHERE OG.LONGNAME = 'School of Mechanical and Manufacturing Engineering'
GROUP BY PE.STUDENT,
		PE.SEMESTER
ORDER BY PE.SEMESTER;

CREATE OR REPLACE VIEW E8(STUDENT1, SEMESTER) AS 
SELECT COUNT(E14.STUDENT1) AS STUDENT1,E14.SEMESTER AS SEMESTER
FROM E14
GROUP BY E14.SEMESTER;

CREATE OR REPLACE VIEW E9(STUDENT2, SEMESTER) AS 
SELECT COUNT(E15.STUDENT2) AS STUDENT2, E15.SEMESTER AS SEMESTER
FROM E15
GROUP BY E15.SEMESTER;

CREATE OR REPLACE VIEW Q7(SEMESTER_ID) AS 
SELECT E8.SEMESTER AS SEMESTER_ID
FROM E8
JOIN E9 ON E9.SEMESTER = E8.SEMESTER
WHERE E8.STUDENT1 > E9.STUDENT2;


-- Q8:
--... SQL statements, possibly using other views/functions defined by you ...
CREATE OR REPLACE VIEW MA1(STUDENT,PROGRAM_ID,STREAM,DEGREE_NAME) AS 
SELECT DISTINCT PE.STUDENT,
	PE.PROGRAM,
	SE.STREAM,
	PD.NAME
FROM PROGRAM_ENROLMENTS PE
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN PROGRAM_DEGREES PD ON PD.PROGRAM = PO.ID
JOIN STREAM_ENROLMENTS SE ON SE.PARTOF = PE.ID
WHERE LOWER(PD.NAME) like '%master%'
AND SE.STREAM IS NOT NULL;

CREATE OR REPLACE VIEW BA1(STUDENT,PROGRAM_ID,STREAM,DEGREE_NAME) AS 
SELECT DISTINCT 
	PE.STUDENT,
	PE.PROGRAM,
	SE.STREAM,
	PD.NAME
FROM PROGRAM_ENROLMENTS PE
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN PROGRAM_DEGREES PD ON PD.PROGRAM = PO.ID
JOIN STREAM_ENROLMENTS SE ON SE.PARTOF = PE.ID 
WHERE LOWER(PD.NAME) like '%bachelor%'
AND SE.STREAM IS NOT NULL;

CREATE OR REPLACE VIEW MA1_MARK(STUDENT,PROGRAMID,MARK,DEGREE_NAME) AS 
SELECT MA1.STUDENT,
	MA1.PROGRAM_ID,
	AVG(CE.MARK) AS MARK,
	MA1.DEGREE_NAME
FROM MA1
JOIN PROGRAM_ENROLMENTS PE ON PE.STUDENT = MA1.STUDENT
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = MA1.STUDENT
JOIN COURSES CO ON CO.ID = CE.COURSE 
WHERE CE.MARK IS NOT NULL
AND PE.PROGRAM = MA1.PROGRAM_ID
AND CO.SEMESTER = PE.SEMESTER
GROUP BY MA1.STUDENT,
	MA1.PROGRAM_ID,
	MA1.DEGREE_NAME;

CREATE OR REPLACE VIEW BA1_MARK(STUDENT,PROGRAMID,MARK,DEGREE_NAME) AS 
SELECT BA1.STUDENT,
	BA1.PROGRAM_ID,
	AVG(CE.MARK) AS MARK,
	BA1.DEGREE_NAME
FROM BA1
JOIN PROGRAM_ENROLMENTS PE ON PE.STUDENT = BA1.STUDENT
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = BA1.STUDENT
JOIN COURSES CO ON CO.ID = CE.COURSE
WHERE CE.MARK IS NOT NULL
AND PE.PROGRAM = BA1.PROGRAM_ID
AND CO.SEMESTER = PE.SEMESTER
GROUP BY BA1.STUDENT,
	BA1.PROGRAM_ID,
	BA1.DEGREE_NAME;
	
CREATE OR REPLACE VIEW STUDENT_LIST1(STUDENT,MA_PROGRAM,BA_PROGRAM,STREAM,DEGREE_NAME1,DEGREE_NAME2) AS 
SELECT DISTINCT 
		MA1.STUDENT,
		MA1.PROGRAM_ID,
		BA1.PROGRAM_ID,
		MA1.STREAM,
		MA1.DEGREE_NAME,
		BA1.DEGREE_NAME
FROM MA1
JOIN BA1 ON BA1.STUDENT = MA1.STUDENT
AND BA1.STREAM = MA1.STREAM;
	
CREATE OR REPLACE VIEW Q8(UNSW_ID) AS 
SELECT DISTINCT PE.UNSWID AS UNSW_ID
FROM STUDENT_LIST1 SL
JOIN MA1_MARK MM ON SL.STUDENT = MM.STUDENT
AND SL.MA_PROGRAM = MM.PROGRAMID
JOIN BA1_MARK BM ON BM.STUDENT = SL.STUDENT
AND SL.BA_PROGRAM = BM.PROGRAMID
JOIN PEOPLE PE ON PE.ID = SL.STUDENT
WHERE MM.MARK > BM.MARK;

-- Q9:
--... SQL statements, possibly using other views/functions defined by you ...
CREATE OR REPLACE VIEW FIND_ROOM(ROOM) AS 
SELECT CL.ROOM
FROM CLASSES CL
JOIN ROOM_FACILITIES RC ON RC.ROOM = CL.ROOM
JOIN FACILITIES FC ON FC.ID = RC.FACILITY
WHERE FC.DESCRIPTION ilike '%laptop connection facilities%'
UNION
SELECT CL.ROOM
FROM CLASSES CL
JOIN ROOM_FACILITIES RC ON RC.ROOM = CL.ROOM
JOIN FACILITIES FC ON FC.ID = RC.FACILITY
WHERE FC.DESCRIPTION ilike '%slide projector%';

CREATE OR REPLACE VIEW Q9(LAB_ID,ROOM_ID) AS 
SELECT CL.ID AS LAB_ID,
	CL.ROOM AS ROOM_ID
FROM CLASS_TYPES CLT
JOIN CLASSES CL ON CL.CTYPE = CLT.ID
JOIN COURSES CO ON CO.ID = CL.COURSE
JOIN SUBJECTS SJ ON SJ.ID = CO.SUBJECT
JOIN SEMESTERS SE ON SE.ID = CO.SEMESTER
LEFT JOIN FIND_ROOM FR ON CL.ROOM = FR.ROOM
WHERE CLT.UNSWID = 'LAB'
	AND SE.YEAR = 2007
	AND SJ.CODE like 'GEOS%'
	AND FR.ROOM IS NULL;

-- Q10:
--... SQL statements, possibly using other views/functions defined by you ...
CREATE OR REPLACE VIEW FIND_HDRATE(COURSE,HD_RATE) AS 
SELECT CO.ID AS COURSE,
	(MARK_85::numeric / TOTAL::numeric)::NUMERIC(5,4) AS HD_RATE
FROM COURSES CO
JOIN COURSE_ENROLMENTS CE ON CE.COURSE = CO.ID
JOIN(
		SELECT CO.ID AS COURSE_ID,
			COUNT(CE.MARK) FILTER (WHERE CE.MARK >= 85) AS MARK_85,
			COUNT(CE.MARK) AS TOTAL
		FROM COURSES CO
		JOIN COURSE_ENROLMENTS CE ON CE.COURSE = CO.ID
		WHERE CE.MARK IS NOT NULL
		GROUP BY CO.ID
		HAVING COUNT(CE.MARK) FILTER (WHERE CE.MARK >= 85) > 0
																) AS COUNTS ON CO.ID = COUNTS.COURSE_ID;
																
CREATE OR REPLACE VIEW Q10(COURSE_ID,HD_RATE) AS 
SELECT DISTINCT 
	CS.COURSE AS COURSE_ID,
	FH.HD_RATE AS HD_RATE
FROM COURSE_STAFF CS
JOIN STAFF_ROLES TECH ON TECH.ID = CS.ROLE
JOIN STAFF SAFF ON SAFF.ID = CS.STAFF
JOIN AFFILIATIONS AL ON AL.STAFF = SAFF.ID
JOIN STAFF_ROLES IDEN ON IDEN.ID = AL.ROLE
JOIN ORGUNITS OG ON OG.ID = AL.ORGUNIT
JOIN FIND_HDRATE FH ON FH.COURSE = CS.COURSE
WHERE OG.LONGNAME = 'School of Chemical Engineering'
	AND IDEN.NAME = 'Research Fellow'
	AND TECH.NAME = 'Course Convenor';

-- Q11:
--... SQL statements, possibly using other views/functions defined by you ...
CREATE OR REPLACE VIEW SCHO_STUDENTS(UNSW_ID,PROGRAME) AS 
SELECT PP.UNSWID,
	PE.PROGRAM
FROM STUDENTS ST
JOIN PEOPLE PP ON PP.ID = ST.ID
JOIN PROGRAM_ENROLMENTS PE ON PE.STUDENT = ST.ID
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = ST.ID 
JOIN COURSES CO ON CO.ID = CE.COURSE AND CO.SEMESTER = PE.SEMESTER
JOIN SUBJECTS SJ ON SJ.ID = CO.SUBJECT
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN ORGUNITS OG ON OG.ID = PO.OFFEREDBY
WHERE SJ.CODE like 'COMP%'
	AND SJ.CODE not like ALL(array['COMP4%','COMP6%','COMP8%','COMP9%'])
	AND CE.MARK > 50
	AND OG.LONGNAME = 'School of Computer Science and Engineering'
GROUP BY PP.UNSWID,
	PE.PROGRAM
HAVING SUM(SJ.UOC) > 60 
INTERSECT
SELECT PP.UNSWID,
	PE.PROGRAM
FROM STUDENTS ST
JOIN PEOPLE PP ON PP.ID = ST.ID
JOIN PROGRAM_ENROLMENTS PE ON PE.STUDENT = ST.ID
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = ST.ID
JOIN COURSES CO ON CO.ID = CE.COURSE AND CO.SEMESTER = PE.SEMESTER
JOIN SUBJECTS SJ ON SJ.ID = CO.SUBJECT
JOIN STREAM_ENROLMENTS SE ON SE.PARTOF = PE.ID
JOIN PROGRAMS PO ON PO.ID = PE.PROGRAM
JOIN ORGUNITS OG ON OG.ID = PO.OFFEREDBY
WHERE SJ.CODE like ANY(array['COMP4%','COMP6%','COMP8%','COMP9%'])
	AND CE.MARK > 50
	AND SE.STREAM IS NOT NULL
	AND OG.LONGNAME = 'School of Computer Science and Engineering'
GROUP BY PP.UNSWID,
	PE.PROGRAM
HAVING SUM(SJ.UOC) > 24;

CREATE OR REPLACE VIEW FINAL_STUDENT(UNSW_ID) AS 
SELECT SS.UNSW_ID AS UNSW_ID,
	RANK() OVER (ORDER BY AVG(CE.MARK) DESC) AS RANK_MARK
FROM SCHO_STUDENTS SS
JOIN PEOPLE PP ON PP.UNSWID = SS.UNSW_ID
JOIN STUDENTS ST ON ST.ID = PP.ID
JOIN PROGRAM_ENROLMENTS PE ON PE.STUDENT = ST.ID
JOIN COURSE_ENROLMENTS CE ON CE.STUDENT = ST.ID
JOIN COURSES CO ON CO.ID = CE.COURSE AND CO.SEMESTER = PE.SEMESTER
JOIN SUBJECTS SJ ON SJ.ID = CO.SUBJECT
JOIN STREAM_ENROLMENTS SE ON SE.PARTOF = PE.ID
WHERE SJ.CODE like ANY(array['COMP4%','COMP6%','COMP8%','COMP9%'])
	AND SE.STREAM IS NOT NULL
GROUP BY SS.UNSW_ID, PE.PROGRAM
HAVING AVG(CE.MARK) > 80;

CREATE OR REPLACE VIEW Q11(UNSW_ID) AS 
SELECT FS.UNSW_ID as UNSW_ID
FROM FINAL_STUDENT FS;

-- Q12
CREATE OR REPLACE FUNCTION Q12(COURSE_ID Integer, I Integer) RETURNS
SETOF text AS $$
--... SQL statements, possibly using other views/functions defined by you ...
DECLARE
    student_list TEXT;
BEGIN
    FOR student_list IN (
        SELECT student :: TEXT
        FROM (
            SELECT student, RANK() OVER (ORDER BY ce.mark DESC) AS rank_mark
            FROM course_enrolments ce
            WHERE ce.course = course_id
			AND ce.mark IS NOT NULL
       		 ) AS total
        WHERE total.rank_mark = i
    )
    LOOP
        RETURN NEXT student_list;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE PLPGSQL;