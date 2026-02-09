## 일반적인 네이밍룰(REST 스타일)

### 네이밍룰
- DB: snake_case
- html : kebab-case
- 클래스 : PascalCase
- 메서드,변수 : camelCase

### 컨트롤러 URI
- 목록: GET /posts
- 상세: GET /posts/1
- 작성처리: POST /posts
- 수정처리: PUT /posts/1
- 삭제처리: DELETE /posts/1
- 작성폼: GET /posts/new
- 수정폼: GET /posts/1/edit

### 네이핑 매핑(컨트롤러->서비스->매퍼)
|계층      |조회            |등록         |등록폼          |수정          |  수정폼      |
|:--       |:--             |:--          |:--             |:--           |:--           |
|URI       |/user           |/user        |/user/new       |/user         | /user/edit   |
|Controller|UserList()      |create()     |createForm()    |modify()      |modifyForm()  |
|Service   |selectUserList()|createUser() |                |modifyUser()  |              |
|Mapper    |selectUserList()|insertUser() |                |updateUser()  |              |
|html      |user-list       |             |user-form       |              |user-edit     |

## 공공 SI (egovFramework) 
- Controller: 업무 + 기능
- Service: 동사(select/insert/update/delete) + 업무
  
### 네이밍룰
- DB: snake_case
- 클래스 : PascalCase
- html, url, 메서드, 변수 : camelCase

### 컨트롤러 URI  : /{업무}/{업무}{기능}.do
- 목록: GET /postsList
- 상세: GET /postsView
- 작성처리: POST /postsRegist
- 수정처리: POST /postsUpdate
- 삭제처리: GET /postsDelete
- 작성폼: GET /postsRegistView
- 수정폼: GET /postsUpdateView

### 네이핑 매핑(컨트롤러->서비스->매퍼)
|계층         |전체조회          | 단건조회        |등록               |등록폼                 |수정               |  수정폼               |
|:--          |:--               |:--              |:--                |:--                    |:--                |:--                    |
|URI          |/user/userList.do |/user/userView.do|/user/userInsert.do|/user/userRegistView.do|/user/userUpdate.do|/user/userUpdateView.do|
|Controller   |userList()        |userView()       |userInsert()       |                       |updateUser()       |                       |
|Service      |selectUserList()  |selectUser()     |insertUser()       |                       |userUpdate()       |                       |
|Mapper       |selectUserList()  |selectUser()     |insertUser()       |                       |userUpdate()       |                       |
|JSP          |userList.jsp      |userView.jsp     |                   |userRegist.jsp         |                   |userUpdate.jsp         |

