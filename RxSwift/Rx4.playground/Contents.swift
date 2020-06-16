import RxSwift

let disposeBag = DisposeBag()

//: # Filtering Operators

/*:
 ## ignoreElements
 
 - 작업의 성공과 실패만 중요할 때 사용
 - Observable이 방출하는 next event를 필터링하고, completed, error 만 구독자로 전달
 - 파라미터를 받지 않고, 리턴형은 Completable(nextEvent무시, comple, err만 전달)
 */

print("\n*-*-*-*-*-*-*-*-*-*-* ignoreElements *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from(["a", "b", "c"]) // 방출되지만
  .ignoreElements() // 필터링되어
  .subscribe { print($0) } // 구독자에게는 completed event만 전달
  .disposed(by: disposeBag)

/*:
 ## elementAt
 
 - 특정 index에 위치한 요소를 제한적으로 방출하는 연산자
 - 파라미터(index: Int) -> 리턴(Observable<Element>)
 */

print("\n*-*-*-*-*-*-*-*-*-*-* elementAt *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from(["어","느","것","이"])
  .elementAt(2)
  .subscribe { print($0) }
  .disposed(by: disposeBag)


/*:
 ## filter
 
 - 클로저를 파라미터로 받는다
 - 이 클로저에서 true를 리턴하는 요소가 filter 연산자가 방출할 Observable 요소로 포함된다
 */

print("\n*-*-*-*-*-*-*-*-*-*-* filter *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from([1, 2, 3, 4, 5])
  .filter { $0.isMultiple(of: 2) }
  .subscribe { print($0) }
  .disposed(by: disposeBag)

/*:
 ## skip, skipWhile, skipUntil
 
 - 특정 요소를 무시하는 연산자들
 
 - skip
    - 정수를 파라미터로 받는다.
    - Observable이 방출하는 요소들을 정수(갯수)만큼 무시하고, 그 이후에 방출되는 요소들만 구독자로 전달한다
 - skipWhile :
    - 클로저를 파라미터로 받는다.
    - 클로저에서 true를 리턴하는 동안 방출된 요소들을 무시한다.
    - 클로저에서 false를 리턴하면 이후 조건과 관계 없이 모든 요소를 방출한다.
 - skipUntil :
    - ObservableType을 파라미터로 받는다. 즉 다른 Observable을 파라미터로 받는다.
    - 받은 Observable 이 next evnet 를 전달하기 전까지 원본 Observable 이 전달하는 이벤트를 무시한다.
    - 이런 특성으로 skipUntil 연산자가 파라미터로 받는 Observable 을 Trigger 라고 부르기도 한다.
 
 */

print("\n*-*-*-*-*-*-*-*-*-*-* skip *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from([1, 2, 3, 4, 5, 6, 7, 8])
  .skip(3)
  .subscribe { print($0) }
  .disposed(by: disposeBag)

print("\n*-*-*-*-*-*-*-*-*-*-* skipWhile *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from([1, 2, 3, 4, 5, 6, 7, 8])
  .skipWhile { !$0.isMultiple(of: 3) } // 3일때 true 를 리턴하게 되면서 그 뒤 모두 방출
  .subscribe { print($0) }
.disposed(by: disposeBag)

print("\n*-*-*-*-*-*-*-*-*-*-* skipUntil *-*-*-*-*-*-*-*-*-*-*\n")

let subject = PublishSubject<Int>()
let trigger = PublishSubject<Int>()

subject.skipUntil(trigger)
  .subscribe { print($0) }
.disposed(by: disposeBag)

subject.onNext(1)
trigger.onNext(0)
subject.onNext(3)


/*:
 ## take, takeWhile, takeUntil, takeLast
 
 - 요소의 방출 조건을 다양하게 설정하는 연산자들
 
 - take
    - 정수를 파라미터로 받아서, 해당 숫자만큼 요소만을 방출함
 - takeWhile
    - 클로저를 파라미터로 받아서, 연산자가 true를 리턴하면 구독자에게 요소를 전달한다
    - false를 리턴한 순간부터 더 이상 방출하지 않는다
 - takeIntil
    - ObservableType을 파라미터로 받고, 받은 Observable이 nextEvent를 전달하기 전까지 원본 Observable이 방출하는 nextEvent를 구독자에게 전달한다
 - takeLast
    - 정수를 파라미터로 받아 옵저버블을 리턴
    - 리턴되는 옵저버블에는 원본 옵저버블이 방출하는 요소들 중에서 마지막에 방출한 n개의 요소가 포함
    - 이 연산자에서 중요한 것은, 구독자로 전달되는 시점에 딜레이 된다는 것
 */

print("\n*-*-*-*-*-*-*-*-*-*-* take *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from([1, 2, 3, 4, 5])
  .take(3)
  .subscribe { print($0) }
.disposed(by: disposeBag)

print("\n*-*-*-*-*-*-*-*-*-*-* takeWhile *-*-*-*-*-*-*-*-*-*-*\n")

Observable.from([1, 2, 3, 4, 5])
  .takeWhile { !$0.isMultiple(of: 2) }
  .subscribe { print($0) }
  .disposed(by: disposeBag)

print("\n*-*-*-*-*-*-*-*-*-*-* takeUntil *-*-*-*-*-*-*-*-*-*-*\n")

let aSubject = PublishSubject<Int>()
let aTrigger = PublishSubject<Int>()

aSubject.takeUntil(aTrigger)
  .subscribe { print($0) }
  .disposed(by: disposeBag)

aSubject.onNext(1)
aSubject.onNext(2)
aTrigger.onNext(0)
aSubject.onNext(3)

print("\n*-*-*-*-*-*-*-*-*-*-* takeLast *-*-*-*-*-*-*-*-*-*-*\n")

enum MyError: Error {
  case err
}

let tSubject = PublishSubject<Int>()

tSubject.takeLast(2)
  .subscribe { print($0) }
  .disposed(by: disposeBag)

[1, 2, 3, 4].forEach { tSubject.onNext($0) } // 출력 X

tSubject.onNext(10) // 출력 X, 버퍼 저장 값: 3, 4

tSubject.onCompleted() // 버퍼 저장 값: 4, 10 출력

tSubject.onError(MyError.err) // completed 없이 error 찍으면 error 만 방출

/*:
 ## single Operator
 
 - single은 원본 Observable에서 첫번째 요소만 방출하거나, 조건과 일치하는 첫번째 요소만 방출
 - 두 개 이상의 요소가 방출되면 err 발생
 */

