### 실행계획(execution plan)

sql 파싱 -> sql 최적화 -> sql 실행

sql 파싱

- SQL 구문 오류 검사
- 대상객체가 존재 여부와 제약조건 권한 등을 체크
- sql 실행 비용(cost) 계산
- 어떤 방식으로 실행할지 판단하여 실행계획을 결정

### 스캔방식의 구조

- DW 업무 전용서버에서는 Multi Block Read Count를 크게 지정하고 OLTP 업무 위주의 서버라면 작게 지정.
- 데이터가 저장되어 있는 블록의 수로 판단하여 풀 테이블 스캔을 할지 인덱스 스캔을 할지 결정해야 함.
- Index range scan이 table full scan 보다 느려지는 조회 건수 지점을 인덱스 손익분기점 이라 하는데, 테이블 전체 데이터양의 10 ~ 15% 이상을 출력하게 되면 오히려 table full scan이 효율적일 수 있다.
- 테이블의 데이터가 저장되어 있는 전체 블록 수가 Multi Block Read Count보다 작다면 한번의 I/O만으로 해당 데이터를 추출할 수 있으므로 인덱스를 생성할 필요가 없음

- Full Table Scan
  순차적으로 블록을 액세스하고 멀티블록 I/O와 병렬 액세스 가능

- Index Scan
  인덱스 블록을 액세스 후 해당 rowid로 데이터 블록 액세스하고 싱글 블록 I/O 가능

### 인덱스 활용시 주의사항

조건절에 기술되는 컬럼의 인덱스를 생성한 후 사용자의 실수나 의도적인 사용 제한으로 인해 인덱스 사용이 제한되는 경우입니다.

1. 인덱스 컬럼을 가공을 하면 안됨.

   ```sql
   where substr(product_code, 1, 3) = 'PRD'    -- full table scan (좌변을 연산하게 되면 풀테이블 스캔 방식 적용)
   where product_code like 'PRD%'              -- index scan ( 와일드카드(%) 는 끝에 작성하게 되면 인덱스 스캔 방식을 적용 )
   ```

   ```sql
   where trunc(regdate) = to_date('20240101', 'yyyymmdd')                          -- full table scan
   where regdate between to_date('20240101' || '000000', 'yyyymmddhhmiss')         -- index range scan
                     and to_date('20240101' || '235959', 'yyyymmddhhmiss')
   ```

1. 인덱스와 상수로 제공되는 값의 데이터 형식 차이로 인해 발생하는 문제(묵시적 형변환이 발생)

   ```sql
   where cnt = '10'    ==>   where to_char(cnt) = '10'    -- 타입이 맞지 않아 인덱스 컬럼에 형변환이 발생
   ```

1. not 연산자는 인덱스를 사용하지 않으므로 not exists, minus 등을 이용하여 인덱스 사용을 유도해야 함.

   ```sql
   where empno <> '1234'
       ==>  where not exists (select '1' from employees where employee_id = '1234')
       ==>  select * from employees
            minus
            select * from employees where where employee_id = '1234'
   ```

1. is not null은 인덱스 사용에 제한을 받음
   좁은 분포도의 경우에는 인덱스를 이용하고 넓은 분포도의 경우에는 인덱스를 변형하여 full table scan을 수행하도록 하는 경우에 데이터의 분포도 균형이 깨지고 저장 공강의 낭비만 발생한다면 null 값을 사용하는게 효율적임

   ```sql
   where status = 'A'
   where status = 'E'  --> 분포도가 80%를 넘어간다면 null을 사용 -->  status = to_char(null)
   ```

1. OR 대신 Union을 사용

   ```sql
   WHERE department = 'Marketing' OR department = 'IT';         -- full table scan
     ==> SELECT * FROM employees                                -- index scan
          WHERE department = 'Marketing'
          union all
         SELECT * FROM employees
          WHERE department = 'IT'
   ```

### sql 쿼리 속도를 올리려면

1. 필요한 Row, Column만 가져와라.

   ```sql
   SELECT e.name, e.department, e.sales
   FROM employees e
   JOIN (
   SELECT department, MAX(sales) AS max_sales
   FROM employees
   GROUP BY department
   ) d ON e.department = d.department AND e.sales = d.max_sales;
   ```

1. 분석 함수를 최대한 활용

- 전통적인 집계 함수와 달리 사전에 데이터를 그룹화할 필요가 없어요. 이는 불필요한 자원 소모를 줄이고 쿼리 성능을 높임
- 복잡한 데이터 분석 과정에서 발생할 수 있는 중간 결과물의 저장과 재처리를 최소화할 수 있어요. 이는 쿼리 실행 시간을 크게 단축
- 순위 결정 함수: ROW_NUMBER(), RANK(), DENSE_RANK()
- 데이터 변화를 추적하는 분석 함수: LEAD(), LAG() 등의 함수

  ```sql
  -- 급여가 높은 상위 3명의 직원 정보만 추출
  WITH ranked_employees AS (
  SELECT  name,
          department,
          salary,
          ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
    FROM employees
  )
  SELECT *
    FROM ranked_employees
   WHERE rank <= 3;
  ```

1. 계산값을 미리 저장해두고, 나중에 사용하라.

- 쿼리가 실행될 때마다 방대한 양의 주문 및 고객 데이터를 모두 읽어서 복잡한 계산을 수행해야하고 특히 재구매율 계산을 위해 서브쿼리까지 사용되고 있어 쿼리 속도는 더욱 느려짐
- 계산 결과를 별도의 테이블에 저장하여 사용하며 주기적으로 계산 결과 업데이트

1. hint 사용

- 힌트란 SQL 튜닝의 핵심 부분으로 일종의 지시 구문이다.
- 오라클 옵티마이저(Optimizer)에게 SQL문 실행을 위한 데이터를 스캐닝하는 경로, 조인하는 방법 등을 알려주기 위해 SQL사용자가 SQL 구문에 작성하는 것을 뜻한다.
- 오라클이 항상 최적의 실행 경로를 만들어 내기는 불가능하기 때문에 직접 최적의 실행 경로를 작성해 주는 것
- 힌트, 인덱스, 조인의 개념을 정확히 알고 사용하지 않은 무분별한 힌트의 사용은 성능의 저하를 초래하기 때문에 잘 알고 최적의 실행 경로를 알고 있을 경우 적절하게 사용하여야 한다.

  ```sql
  SELECT /*+ index_asc(e idx_employees_name)  */
         EMPNO, NAME, SAL FROM employees e
   WHERE ENAME >= '가'
  ```

### 인덱스 설정 시 유의사항

- 인덱스를 생성해야 하는 경우
  인덱스를 많이 생성한다고 반드시 좋은 것(쿼리속도 향상)은 아니다. DML 작업이 커밋되면 변경사항을 인덱스에도 반영해야하는데, 테이블과 연관된 인덱스가 많을 수록 관련 인덱스를 모두 갱신해야 함으로 서버의 부담이 증가한다. 따라서 다음과 같은 경우에만 인덱스를 생성해야한다.

1. 열(Column)에 많은 NULL 값이 포함된 경우  
   NULL 값을 제외하고 검색해야하는 경우 인덱스를 사용하면 검색 속도를 향상시킬 수 있다.

2. 열(Column)에 광범위한 값이 포함된 경우  
   인덱스 컬럼에 다양한 값이 있는 경우 인덱스를 사용하면 검색 속도를 향상시킬 수 있다.

3. WHERE절 혹은 JOIN 조건에 자주 사용되는 경우

4. 테이블이 크고 대부분의 쿼리가 테이블에서 2~4% 미만의 행을 검색할 것으로 예상되는경우

5. ORDER BY 절에 자주 사용되는 경우  
   인덱스는 기본적으로 정렬되어있어서 order by를 수행할 필요가 없다.

- 인덱스 생성을 안해야 하는 경우

1. 데이터 변경이 자주 발생
2. 검색할 데이터가 전체 데이터의 20% 이상인 경우(데이터 중복도가 높은 경우)

### [요약정리](https://community.heartcount.io/ko/query-optimization-tips/)

- 데이터를 변형하는 연산은 가급적 피하고, 원본 데이터를 직접 비교하는 조건을 사용하세요. 이는 인덱스 활용도를 높여 쿼리 속도를 향상시킵니다.
- OR 연산자 대신 UNION을 활용하면 각 조건을 독립적으로 최적화하고 인덱스를 효과적으로 사용할 수 있습니다.
- 불필요한 Row와 Column을 제외하고 꼭 필요한 데이터만 조회하세요. 이는 데이터 처리량을 최소화하여 쿼리 성능을 높입니다.
- ROW_NUMBER(), RANK(), LEAD(), LAG() 등의 분석 함수를 적극 활용하면 복잡한 데이터 분석을 유연하고 효율적으로 수행할 수 있습니다.
- LIKE 연산자와 와일드카드(%)를 사용할 때는 문자열 끝에 와일드카드를 두는 것이 인덱스 활용에 유리합니다.
- 복잡한 계산은 실시간으로 처리하기보다는 미리 계산해서 저장해두고 주기적으로 업데이트하는 것이 효율적입니다.

  ```sql
  CREATE TABLE BOARD
  ( BNO NUMBER(10,0) primary key,
  TITLE VARCHAR2(1000),
  CONTENTS VARCHAR2(4000),
  WRITER VARCHAR2(1000),
  REGDATE DATE,
  UPDATEDATE DATE DEFAULT sysdate,
  IMAGE VARCHAR2(2000)
  ) ;

  create sequence SEQ_BOARD start with 107;
  INSERT INTO BOARD( BNO,TITLE,CONTENTS,WRITER,REGDATE,UPDATEDATE,IMAGE)
  SELECT SEQ_BOARD.NEXTVAL, TITLE,CONTENTS,WRITER,REGDATE+1,UPDATEDATE+1, IMAGE from board;

  select count(*) from board;

  select * from dba_data_files;
  ALTER DATABASE DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\UNDOTBS1.DBF' RESIZE 1000M;
  ```
