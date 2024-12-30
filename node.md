### Node.js 백엔드 프레임워크

1. [Express](https://expressjs.com/) : 미니멀/속도 ↑, 보안 ↓
8. Meteor.js
3. Koa.js
7. Sails.js
6. Nest.js
5. Hapi.js
7. LoopBack
8. Adonis.js
9. Derby.js

[Express 미들웨어](https://lakelouise.tistory.com/211)

### vue reference
(Example)[https://ko.vuejs.org/examples/#todomvc]
(toturial)[https://ko.vuejs.org/tutorial/#step-1]

watch VS watchEffect
watch와 watchEffect 둘 다 관련 작업(api call, push route 등)을 반응적으로 수행할 수 있게 해준다. 하지만 주요한 차이점은 관련된 반응형 데이터를 추적하는 방식이다.

watch
명시적으로 관찰된 소스(첫번째 매개변수)만 추적한다. 콜백 내에서 액세스한 항목은 추적하지 않는다. 또한, 콜백은 소스가 실제로 변경된 경우에만 트리거된다. 콜백이 실행되어야 하는 시기를 보다 정확하게 제어할 수 있다.
watchEffect
콜백 내에 담긴 모든 반응 속성을 자동으로 추적한다. 이것은 더 편리하고 일반적으로 더 간결한 코드를 생성하지만 반응성 종속성을 덜 명시적으로 만든다.
