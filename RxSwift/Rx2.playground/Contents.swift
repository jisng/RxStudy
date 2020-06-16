import RxSwift

let disposeBag = DisposeBag()

enum MyError: Error {
  case err
}

/*:
 # Subject & Relay
 - Observable은 다른 Obsevable을 구독하지 못함
 - Observer는 다른 Observer로 이벤트를 전달하지 못함
 - Subject는 다른 Observable로부터 이벤트를 받아서 구독자로 전달할 수 있음
 - 즉 Observable인 동시에 Observer이다.
 
 ## Subject
 - PublishSubject: Subject로 전달되는 새로운 이벤트를 구독자로 전달
 - BehaviorSubject: 생성시점의 시작이벤트를 지정. subject로 전달되는 이벤트 중에서 가장 마지막으로 전달된 최신 이벤트를 저장해두었다가, 새로운 구독자에게 최신 이벤트를 전달
 - ReplaySubject: 최신 이벤트를 버퍼에 저장. 옵저버가 구독을 시작하면, 버퍼에 있는 모든 이벤트를 전달
 - AsyncSubject: Subject로 completed이벤트가 전달되는 시점에 마지막으로 전달된 Next event를 구독자로 전달
 */

/*: ### PublishSubject
 - 이벤트 발생 즉시 구독자에게 전달
 - 최초 생성 시점과 첫번째 구독이 시점 사이에 방출된 이벤트는 사라짐
 */

print("=============== PublishSubject ===============")

// 생성자를 호출할 때 파라미터를 전달하지 않으므로, 비어있는 상태로 생성
// 생성 시점에는 저장되어 있는 이벤트 없음

let subject = PublishSubject<String>()
// 문자열이 포함된 Next Event를 받아서 다른 Observer에게 전달할 수 있다.
subject.onNext("Hi?")


// PublishSubject는 구독 이후 전달되는 새로운 이벤트만 구독자에게 전달
// 따라서 위 "Hi?"는 o1에게 전달되지 않음

let o1 = subject.subscribe { print(">> o1", $0)}
o1.disposed(by: disposeBag)

subject.onNext("Hello?")

let o2 = subject.subscribe { print(">> o2", $0)}
o2.disposed(by: disposeBag)

subject.onNext("It's me...")

subject.onCompleted()

//subject.onError(MyError.err)

let o3 = subject.subscribe { print(">> o3", $0)}
o3.disposed(by: disposeBag)


/*: ### BehaviorSubject
 - PublishSubject는 빈 값으로 생성할 수 있지만, BehaivorSubject는 하나의 값을 전달해야 함
 - 즉 생성하면 내부에 Next Event가 만들어 지는 것
 - 따라서 BehaviorSubject를 구독하자마자 next Event 전달
 - 새로운 이벤트 전달 시 기존 저장되어 있는 이벤트 교체, 최종적으로 최신 이벤트를 옵저버로 전달
*/
print("=============== BehaviorSubject ===============")


// 생성 방식
let ps = PublishSubject<Int>()
let bs = BehaviorSubject<Int>(value: 0)

// 구독 현황
ps.subscribe { print("PS >>", $0)}
bs.subscribe { print("BS 1 >>", $0)}.disposed(by: disposeBag)

bs.onNext(1)

bs.subscribe { print("BS 2 >>", $0)}.disposed(by: disposeBag)

// subject로 새로운 이벤트 (1) 이 전달되면 기존 저장 되어 있는 이벤트 교체
// 결과적으로 가장 최신 next event를 옵저버로 전달

bs.onCompleted()

bs.onNext(2)

bs.subscribe { print("BS 3 >>", $0)}.disposed(by: disposeBag)

/*:
 ### ReplaySubject
 - 두 개 이상의 이벤트를 저장하여 새로운 구독자에게 전달하고 싶을 때 사용
 - 생성시 create 메서드 사용, bufferSize를 지정 (버퍼가 몇 개의 이벤트를 저장할지)
 - completed, err 이후 새로운 구독자를 추가하면 버퍼에 저장된 값을 해당 구독자에게 전달 후 completed, err 이벤트가 전달된다
 - ReplaySubject의 경우 종료 여부에 관계 없이 항상 버퍼에 저장되어있는 이벤트를 새로운 구독자에게 전달한다.
 */
print("=============== ReplaySubject ===============")

let rs = ReplaySubject<Int>.create(bufferSize: 3)

(1...10).forEach { rs.onNext($0) }
rs.subscribe { print("Observer 1 >> ", $0)}.disposed(by: disposeBag)

rs.onNext(11)

rs.subscribe { print("-->", $0 )}.disposed(by: disposeBag)

rs.onCompleted()

rs.subscribe { print("4 -->", $0)}.disposed(by: disposeBag)


/*:
 ### AsyncSubject
 
 - Completed Event가 전달되기 전까지 어떤 이벤트도 전달하지 않음
 - Completed 전달되면, 그 시점에서 가장 최근에 전달된 Next Event 하나를 구독자에게 전달
 - Err가 전달되면, 최근 Next Event가 전달되지 않고, err만 전달된다
 */
print("=============== AsyncSubject ===============")


let ass = AsyncSubject<Int>()

ass
  .subscribe { print("Async >>", $0) }
  .disposed(by: disposeBag)

ass.onNext(1)
ass.onNext(2)
ass.onCompleted()


/*:
 ## Relay
 - PublishRelay: PublishSubject를 래핑
 - BehaviorRelay: BehaviorSubject를 래핑
 - Next Event만 받고 Completed와 Error event는 받지 않음
 - 주로 종료 없이 계속 전달되는 Event 시퀀스를 처리할 때 활용
 */
/*:
 ### PublishRelay
 - Subject와 마찬가지로 Source로부터 이벤트를 전달 받아 구독자로 전달
 - 오직 Next Event만 전달 (`create()` 사용)
 - Completed, Error는 받지도, 전달하지도 않음
 - Subject와 달리 구독자가 disposed 되기 전까지 메모리에서 해제되지 않음
 - 이런 특성을 이용하여 주로 UI EVENT 처리에 사용 (Relay를 사용하기 위해서는 RxCocoa)
 */

import RxCocoa

print("=============== PublishRelay ===============")

let pr = PublishRelay<Int>() // 생성
pr.subscribe { print("1: \($0)")} // 구독
  .disposed(by: disposeBag)

pr.accept(1)

print("=============== BehaviorRelay ===============")

let br = BehaviorRelay(value: 1)
br.accept(2)

br.subscribe { print("2: \($0)")}
  .disposed(by: disposeBag)

br.accept(3)

print(br.value)
