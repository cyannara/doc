## 실행계획(execution plan)

sql 파싱 -> sql 최적화 -> sql 실행

### sql 파싱
- SQL 구문 오류 검사
- 대상객체가 존재 여부와 제약조건 권한 등을 체크
- sql 실행 비용(cost) 계산
- 어떤 방식으로 실행할지 판단하여 실행계획을 결정

  CREATE TABLE "BOARD" 
   (	"BNO" NUMBER(10,0), 
	"TITLE" VARCHAR2(1000), 
	"CONTENTS" VARCHAR2(4000) DEFAULT 'No Content', 
	"WRITER" VARCHAR2(1000) DEFAULT 'Any', 
	"REGDATE" DATE, 
	"UPDATEDATE" DATE DEFAULT sysdate, 
	"IMAGE" VARCHAR2(2000)
   ) ;
--------------------------------------------------------
--  DDL for Index SYS_C007133
--------------------------------------------------------

  CREATE UNIQUE INDEX "SYS_C007133" ON "BOARD" ("BNO") 
  ;
--------------------------------------------------------
--  Constraints for Table BOARD
--------------------------------------------------------

  ALTER TABLE "BOARD" ADD PRIMARY KEY ("BNO") ENABLE;
  ALTER TABLE "BOARD" MODIFY ("REGDATE" NOT NULL ENABLE);
  ALTER TABLE "BOARD" MODIFY ("WRITER" NOT NULL ENABLE);
  ALTER TABLE "BOARD" MODIFY ("TITLE" NOT NULL ENABLE);

101	First	No Content	Any	24/10/29 10:44:46	24/10/29 10:44:46	cat.jpg
102	Second	No Content	Any	24/10/29 10:45:05	24/10/29 10:45:05	cat.jpg
103	테스트	없음	베타 테스터	24/10/29 00:00:00	24/10/29 12:01:26	cat.jpg
104	오늘은...		익명	24/10/29 00:00:00	24/10/29 12:35:32	cat.jpg
105	이미지		테스터	24/10/29 00:00:00	24/10/29 12:54:22	cat.jpg
106	강아지		강아지	24/10/29 00:00:00	24/10/29 14:22:20	dog.jpg
107	테스트	없음	베타 테스터	24/10/30 00:00:00	24/10/30 12:01:26	cat.jpg
108	오늘은...		익명	24/10/30 00:00:00	24/10/30 12:35:32	cat.jpg
109	이미지		테스터	24/10/30 00:00:00	24/10/30 12:54:22	cat.jpg
110	강아지		강아지	24/10/30 00:00:00	24/10/30 14:22:20	dog.jpg

create sequence board_Seq start with 107;
insert into board ( BNO,TITLE,CONTENTS,WRITER,REGDATE,UPDATEDATE,IMAGE)
select board_seq.nextval, TITLE,CONTENTS,WRITER,
REGDATE+1,
UPDATEDATE+1,
IMAGE from board;

select count(*) from board;

select * from dba_data_files;
ALTER DATABASE DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF' RESIZE 1000M;
