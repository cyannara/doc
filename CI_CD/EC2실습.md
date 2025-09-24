
## 실습1 : EC2 인스턴스 배포

### 1. 리전 변경  
아시아 태평양(서울)

### 2. 키페어 생성
  - 사이드메뉴  => 네트워크 및 보안  =>  키페어
  - 이름 : **awskey**
  - 프라이빗 키 파일 형식 : **.pem** 선택
  - 태그 : **myserver**
  - 키파일 다운로드
  - c:\aws 폴더 생성하고 다운받은 pem 키파일 이동  
    **파일 분실 시 재발급 안 되고 서버 접속 할 수 없음**

### 3. 보안그룹 생성
  - 사이드메뉴  => 네트워크 및 보안  =>  보안그룹
  - myserver_sg
  - 보안그룹 => myserver_sg 체크 => 인바운드 규칙 탭 => 인바운드 규칙 편집 버튼
             => 규칙 추가 버튼 => 포트 범위에 80 => 소스 에 "anywhere-IPv4" => 규칙 저장 버튼
 
### 4. 인스턴스 시작
  - 서비스  =>  컴퓨팅  =>  EC2 선택
  - 이름 및 태그 : **myserver**
  - AMI : **Amazon Linux**
  - 인스턴스 유형 : **t2.micro** (프리티어 기본값 )
  - 키페어 : **awskey** 선택
  - 네트워크 설정 : **myserver_sg** 보안그룹 선택
  - 스토리지 구성 :  **30** 
  - 인스턴스 시작 버튼
  - 모든 인스턴스 보기 버튼
  - myserver 인스턴스 선택
  - public IP 주소 따로 메모해둘 것


## 실습2 : EC2 인스턴스 접속

#### MobaXterm 다운로드하고 설치
#### MobaXterm session 설정
  - 메인 메뉴 => session
  - SSH 탭
  - Remote host에 인스턴스의 퍼블릭 IP 입력
  - specify username 체크 하고 ec2-user 입력
  - Advanced SSH settings 탭
  - SSH-browswer type 은 None 선택
    파일 전송하려면 SFTP protocol 선택
  - use private key 체크하고 다운받은 pem 키파일을 지정
  - OK 버튼

  - 서버 정보 확인
```bash
    $ ifconfig                     # 퍼블릭 IP 확인
    $ curl ipinfo.io/ip
    $ cat /etc/os-release          # 리눅스 버전
    $ lsblk                        # 스토리지 확인
    $ df –h                        # 디스크 사용량 확인
    $ free –h                      # 메모리 용량 확인
```
    
  - 호스트 이름 변경
```bash
    $ hostname                                     # 호스트 이름 확인
    $ sudo hostnamectl set-hostname webserver      # 호스트 이름 변경
    $ sudo reboot                                  # 재부팅 
```

## 실습3 : http 웹서버 구축

#### 1. 웹서버 구축
```bash
    $ sudo su -                                       # 슈퍼 유저로 변경
    # yum install httpd –y                            # http 데몬 설치
    # systemctl start httpd                           # http 데몬 실행
    # cd /var/www/html                                
    # echo “AWS web server start~~~” > index.html   <= index 파일 생성
```

#### 서버 연결 테스트
   브라우저에서 http://ip주소


## 실습4 : 실습에서 생성된 자원 삭제하기

1. 인스턴스 삭제  
  인스턴스 상태 => 인스턴스 종료(삭제)
2. 보안그룹 삭제


## 추가사항
#### Putty 사용하여 클라우드 접속하기
1. Puttygen 실행 
2. load >> 모든 파일로 변경 후 pemkey 찾아 열기  
3. save private key 클릭 >> yes (pem키와 같은 경로 사용 권장) >> puttygen 종료 
4. aws 콘솔에서 EC2 인스턴스 이름 클릭 : 퍼블릭 IP 복사해 두기  
5.  putty 실행  
    - Host Name (or IP address) : 붙여넣기 
    - saved session : 적당한 값 입력(예 my-web2) 
6. 왼쪽창 >> SSH >> AUTH >> Browser클릭 후 ppk file 연결 
7. SESSION >> Save 저장하기  
8. Open → 터미널 접속 
