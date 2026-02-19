/* listagg */ 

SELECT LISTAGG(
         '''' || region || ''' AS ' || region,
         ','
       ) WITHIN GROUP (ORDER BY region)
FROM region_table;

--결과
'SEOUL' AS SEOUL,'BUSAN' AS BUSAN,'DAEGU' AS DAEGU

mapper xml에 변수로 전달
	
	

/* 진척율 계산 */

CREATE TABLE "HOLIDAY" 
   (	"SEQ" NUMBER, 
	"DT" DATE NOT NULL ENABLE, 
	"WEEK_NM" VARCHAR2(50), 
	"HOLI_NM" VARCHAR2(100), 
	"USE_YN" VARCHAR2(1), 
	 PRIMARY KEY ("SEQ"));

CREATE TABLE PROJECT (
    PROJECT_ID      VARCHAR2(20)   PRIMARY KEY,
    PROJECT_NAME    VARCHAR2(200)  NOT NULL,
    STARTED_AT      DATE           NOT NULL,
    DUE_AT          DATE           NOT NULL,
    CREATED_AT      DATE           DEFAULT SYSDATE,
    UPDATED_AT      DATE
);

CREATE TABLE ISSUE (
    ISSUE_ID        NUMBER          PRIMARY KEY,
    PROJECT_ID      VARCHAR2(20)    NOT NULL,
    TITLE           VARCHAR2(300)   NOT NULL,
    STARTED_AT      DATE,
    DUE_AT          DATE,
    ACTUAL_PROGRESS NUMBER(5,2)     DEFAULT 0,
    STATUS          VARCHAR2(20)    DEFAULT 'OPEN',
    CREATED_AT      DATE            DEFAULT SYSDATE,
    UPDATED_AT      DATE,

    CONSTRAINT FK_ISSUE_PROJECT
        FOREIGN KEY (PROJECT_ID)
        REFERENCES PROJECT (PROJECT_ID)
);

Insert into HOLIDAY (SEQ,DT,WEEK_NM,HOLI_NM,USE_YN) values (1,to_date('2026/02/04','RRRR/MM/DD'),'수요일','대체공휴일','Y');
Insert into HOLIDAY (SEQ,DT,WEEK_NM,HOLI_NM,USE_YN) values (2,to_date('2026/02/16','RRRR/MM/DD'),'월요일','설연휴','Y');
Insert into HOLIDAY (SEQ,DT,WEEK_NM,HOLI_NM,USE_YN) values (3,to_date('2026/02/17','RRRR/MM/DD'),'월요일','설연휴','Y');
Insert into HOLIDAY (SEQ,DT,WEEK_NM,HOLI_NM,USE_YN) values (4,to_date('2026/02/18','RRRR/MM/DD'),'월요일','설연휴','Y');

INSERT INTO PROJECT (
    PROJECT_ID,
    PROJECT_NAME,
    STARTED_AT,
    DUE_AT
) VALUES (
    'P001',
    '일정관리 시스템 구축',
    DATE '2026-02-01',
    DATE '2026-02-28'
);

INSERT INTO ISSUE VALUES
(101, 'P001', '요구사항 분석',
 DATE '2026-02-01', DATE '2026-02-05', 100, 'DONE', SYSDATE, NULL);

INSERT INTO ISSUE VALUES
(102, 'P001', '화면 설계',
 DATE '2026-02-03', DATE '2026-02-10', 80, 'IN_PROGRESS', SYSDATE, NULL);

INSERT INTO ISSUE VALUES
(103, 'P001', 'DB 설계',
 DATE '2026-02-06', DATE '2026-02-15', 60, 'IN_PROGRESS', SYSDATE, NULL);

INSERT INTO ISSUE VALUES
(104, 'P001', 'API 개발',
 DATE '2026-02-10', DATE '2026-02-20', 30, 'IN_PROGRESS', SYSDATE, NULL);

INSERT INTO ISSUE VALUES
(105, 'P001', '프론트엔드 개발',
 DATE '2026-02-12', DATE '2026-02-25', 10, 'OPEN', SYSDATE, NULL);

INSERT INTO ISSUE VALUES
(106, 'P001', '통합 테스트',
 NULL, DATE '2026-02-28', 0, 'OPEN', SYSDATE, NULL);

commit;


SELECT  i.project_id                                            AS "프로젝트ID",
        p.project_name                                         AS "프로젝트명",
        round(SUM(ACTUAL_PROGRESS) / NULLIF(COUNT(*), 0))      AS "실제진행도",
        round(AVG(plan))                                       AS "예상진행도",
        COUNT(*)                                                AS "일감수",
        SUM(CASE WHEN ACTUAL_PROGRESS = 100 THEN 1 ELSE 0 END)  AS "완료일감수",
        SUM(CASE WHEN i.started_at is null THEN 1 ELSE 0 END)   AS "미착수일감"
  FROM (SELECT CASE
                        WHEN STARTED_AT IS NULL THEN NULL   -- 시작일 없으면 0%
                        WHEN SYSDATE < STARTED_AT THEN 0    -- 
                        WHEN STARTED_AT > DUE_AT THEN 100    -- 시작이 지연된 일감 → 일정상 이미 100% 초과
                        WHEN SYSDATE >= DUE_AT THEN 100
                ELSE
                    (FN_WORKDAY_CNT(started_at, SYSDATE) / FN_WORKDAY_CNT(started_at, due_at)) * 100
                END plan,  
                i.*
          FROM ISSUE  i  
       )  i
  JOIN project p ON i.project_id = p.project_id
 WHERE i.due_at IS NOT NULL
 GROUP BY i.project_id, p.project_name;



