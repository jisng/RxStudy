import RxSwift


/*:
 # Observable
 
 Observable -> Observer 3가지 Event 전달 : 구독한다고 표현
 1. Next event = 새로운 이벤트 : Emission, 방출 또는 배출이라고 표현
 2. error : Notification 이라고 표현
 3. completed : Notification 이라고 표현
 2,3번은 observable 라이프 사이클의 가장 마지막에 전달
 
 ## Observer가 구독하는 방법
 - Observable의 subscribe method 호출
 */

let o1 = Observable<Int>.create { (observer) -> Disposable in
  observer.on(.next(0))
  observer.onNext(1)
  observer.onNext(2)
  
  observer.onCompleted()
  
  return Disposables.create()
}

print("---------------------------------------------------------")

o1.subscribe {
  // 값은 $0.element 속성을 통해 접근 가능, 옵셔널
  // 이 메소드는 클로저를 파라미터로 받음
  // 클로저로 이벤트가 전달, 이곳에서 이벤트를 직접 처리, 이 곳이 observer
  
  print("Start")
  print($0)
  
  if let elem = $0.element {
    print(elem)
  }
  print("End")
}

print("---------------------------------------------------------")

//o1.subscribe(onNext: <#T##((Int) -> Void)?##((Int) -> Void)?##(Int) -> Void#>,
//             onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>,
//             onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>,
//             onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)

o1.subscribe(onNext: { e in
  print("~Start")
  print(e)
  print("~Stop")
})

print("---------------------------------------------------------")

/*:
 - Observable은 이벤트가 어떤 순서로 전달돼야 하는지만 정의
 - 방출과 이벤트 전달은 Observer가 Observable을 구독하기 시작하는 시점에 이뤄짐
 */

/*:
 # Disposables
 - onDisposed는 Observable과 관련된 모든 리소스가 제거된 후 호출
 - 메모리에서 해제되는 순간 onDisposed 클로저 안의 무언가를 실행시키고 싶다면 'onDiposed'
 - Disposed 코드를 작성하지 않아도 err, completd 로 종료되면 관련 리소스가 메모리에서 정상적으로 해제
 - Disposed는 Observable이 호출하는 함수가 아닌, 해당 리소스가 모두 해제되면 자동으로 호출
 */

let subscriptional = Observable.from([1, 2, 3])
  .subscribe(onNext: { (elem) in
    print("onNext", elem)
  }, onError: { (err) in
    print("onError", err)
  }, onCompleted: {
    print("Completed")
  }) {
    print("Disposed")
}


print("---------------------------------------------------------")


/*:
 # Disposebag
 - 자동으로 메모리를 해제해주긴 하지만, 공식적으로 수동으로 메모리 정리하는 것을 권장
 - subscribe가 리턴한 Disposable이 해당 bag에 추가 됨
 - disposebag이 해제될 때 모두 해제
 - ARC에서 오토릴리즈풀과 비슷한 개념
 */

subscriptional.dispose() // 리소스를 메모리에서 해제

var bag = DisposeBag() // disposable을 담았다가, 한 번에 해제
Observable.from([1, 2, 3])
  .subscribe {
    print($0)
}.disposed(by: bag) // bag에 담기


bag = DisposeBag()
// 이렇게 해주면 이전 DisposeBag에 있는 Diposable은 해제되고 새로운 DisposeBag()으로 초기화 된다.


print("---------------------------------------------------------")


let subscription2 = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
  .subscribe(onNext: { (elem) in
    print("onNext", elem)
  }, onError: { (err) in
    print("onError", err)
  }, onCompleted: {
    print("Completed")
  }, onDisposed: {
    print("Disposed")
  })
// 1씩 증가하는 정수를 1초마다 방출하는 Observable
// 무한정 방출하기 때문에 중단 방법이 필요

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  subscription2.dispose() // 여기서 dispose() 호출
}

/*:
 - dispose 메소드를 호출하는 즉시 모든 리소스가 메모리에서 해제
 - Next까지만 호출, Completed 메서드는 호출되지 않고 dispose
 - 따라서 dispose() 직접 호출은 비추천
 - Take, Until 등의 연산자를 활용하여 구현하는 것을 추천
 */

print("---------------------------------------------------------")


/*:
 # 연산자
 - Obsevable Type Protocol 들을 연산자라고 한다
 - 대부분 연산자들은 Observable 상에서 동작하고, 새로운 Observable을 리턴한다
 - Observable을 리턴하므로 두 개 이상의 연산자를 연달아 호출 할 수 있다
 */

bag = DisposeBag()

Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9])
  
  .take(5) // 처음 5개의 요소만 방출
  .filter { $0.isMultiple(of: 2) }
  .subscribe { print($0) }
  .disposed(by: bag)

//: [Next](@next:/MyPlaygroundRx2.playground)
