## 일반적인 네이밍룰

### 네이밍룰
- DB: snake_case
- html : kebab-case
- 클래스 : PascalCase
- 메서드,변수 : camelCase

### 컨트롤러 URI(restful) 
- 목록: GET /posts
- 상세: GET /posts/1
- 작성처리: POST /posts
- 수정처리: PUT /posts/1
- 삭제처리: DELETE /posts/1
- 작성폼: GET /posts/new
- 수정폼: GET /posts/1/edit

## 공공 SI (egovFramework) 
### 네이밍룰
- DB: snake_case
- 클래스 : PascalCase
- html, url, 메서드, 변수 : camelCase

### 컨트롤러 URI 
- 목록: GET /postsList
- 상세: GET /postsView
- 작성처리: POST /postsRegist
- 수정처리: POST /postsUpdate
- 삭제처리: GET /postsDelete
- 작성폼: GET /postsRegistView
- 수정폼: GET /postsUpdateView

### 네이핑 매핑(컨트롤러->서비스->매퍼)
|계층|이름(조회)|등록|등록폼|
|:--|:--|:--|:--|
|URI|/user/userList.do|/user/userInsert.do|/user/userRegistView.do|
|Controller|userList()|userInsert()||
|Service|selectUserList()|insertUser()||
|Mapper|selectUserList()|insertUser()||
|JSP|userList.jsp||userRegist.jsp|

