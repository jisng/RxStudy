import RxSwift

/*:
 # Create Operators
 
 ## just
 - 파라마티로 하나의 항목을 그대로 방출하는 Observable을 생성
 */
print("----------------Just------------------")

let disposeBag = DisposeBag()
let element = "hi"

Observable.just(element)
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)


/*:
 ## of
 - 두 개 이상의 요소를 방출하는 Observable
 */

print("-----------------Of------------------")

let a = "apple"
let b = "banana"
let c = "coffee"

Observable.of(a, b, c)
  .subscribe { ele in print(ele) }
  .disposed(by: disposeBag)

Observable.of([1, 2], [3, 4], [5, 6])
  .subscribe { el in print(el) }
  .disposed(by: disposeBag)

/*:
 ## from
 - 파라미터로 배열을 받고, 배열에 있는 요소를 하나씩 순서대로 방출
 */

print("-----------------From------------------")

Observable.from(["가", "나", "다"])
  .subscribe { el in print(el) }
  .disposed(by: disposeBag)


/*:
 ## repeatElement
 - 동일한 요소를 반복적(무한적)으로 방출하는 Observable을 생성할 때 사용
 */

print("-----------------repeatElement------------------")

Observable.repeatElement(":)")
.take(7) // 무한정 방출을 제한해줘야 함
  .subscribe{ print($0) }
 .disposed(by: disposeBag)


/*:
 ## deferred
 
 - 특정 조건에 따라 Observable을 생성할 수 있음
 - Observable을 리턴하는 클로저를 파라미터로 받음
 */

print("-----------------deferred------------------")

let happy = ["h", "a", "p", "p", "y"]
let smile = ["s", "m", "i", "l", "e"]
var flage = true

let factory: Observable<String> = Observable.deferred {
  flage.toggle()
  
  if flage {
    return Observable.from(happy)
  } else {
    return Observable.from(smile)
  }
  
}

factory
  .subscribe { print($0) }
  .disposed(by: disposeBag)

/*:
 ## create
 
 - 다른 연산자들은 파라미터로 전달된 요소를 방출하는 Observable 생성 -> 모든 요소 방출 뒤 Complted event 전달 하고 종료
 - 이러한 Observable이 동작하는 방식 자체를 조작하고 싶다면 create 연산자 사용
 - Observable 을 파라미터로 받아서 Disposable을 리턴하는 클로저 전달
 
 - 주의사항
    - 방출할 때는 보통 onNext() 메소드를 사용하고, 그 파라미터로 방출할 요소를 전달해야 한다
    - onNext() 이후 Observable을 종료하기 위해서 onError(), onCompleted() 메소드를 반드시 호출해야 한다
 */

enum MyError: Error {
  case err
}

print("-----------------create------------------")

Observable<String>.create { (observer) -> Disposable in
  guard let url = URL(string: "https://www.apple.com")
    else {
    observer.onError(MyError.err)
    return Disposables.create()
  }
  
  guard let html = try? String(contentsOf: url, encoding: .utf8)
    else {
      observer.onError(MyError.err)
      return Disposables.create()
  }
  
  observer.onNext(html) // html을 next event로 구독자에게 전달
  observer.onCompleted()
  
  return Disposables.create()
}
  .subscribe { print($0) }
  .disposed(by: disposeBag)

/*:
 ### empty, error
 
 - next event를 전달하지 않는다
 - empty 연산자는 completed 이벤트를 전달하는 Observable을 생성한다
 */

Observable<Void>.empty()
  .subscribe { print($0) }
  .disposed(by: disposeBag)
