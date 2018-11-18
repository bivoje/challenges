
Definition Nat : (Type) :=
  forall (X :Type), (X -> X) -> X -> X.

Definition zero : Nat :=
  fun _ _ x => x.

Definition one : Nat :=
  fun _ f x => f x.

Definition N2n (N : Nat) : nat :=
  N nat (fun n => n + 1) 0.

Example one_1 : N2n one = 1.
Proof. reflexivity. Qed.

Definition two : Nat :=
  fun _ f x => f (f x).

Definition three : Nat :=
  fun _ f x => f (f (f x)).

Definition succ (n : Nat) : Nat :=
  fun X f x => f (n X f x).

Definition four : Nat := succ three.

Example four_4 : N2n four = 4.
Proof. reflexivity. Qed.

Definition plus (n m : Nat) : Nat :=
  fun X f x => n X f (m X f x).

Definition five : Nat := plus two three.

Example five_5 : N2n five = 5.
Proof. reflexivity. Qed.

Reserved Notation "n == m" (at level 70, no associativity).

Inductive eq_Nat (n m : Nat) :=
  eqN : (forall (X : Type) (f : X -> X) (x : X), n X f x = m X f x) -> n == m
  where "n == m" := (eq_Nat n m).

Theorem eq_Nat_refl : forall n : Nat,
  n == n.
Proof.
  intro n.
  apply eqN.
  intros X f x.
  reflexivity.
Qed.

Example eq_Nat_one_Szero : one == succ zero.
Proof.
  apply eqN. intros X f x.
  unfold zero, one, succ.
  reflexivity.
Qed.

(* from https://coq.inria.fr/library/Coq.Logic.FunctionalExtensionality.html *)
Axiom functional_extensionality : forall {A} {B : A -> Type},
  forall (f g : forall x : A, B x),
  (forall x, f x = g x) -> f = g.

Theorem eq_Nat_eq : forall n m : Nat,
  n = m <-> n == m.
Proof.
  intros n m. split.
  - intro Heq. subst. apply eq_Nat_refl.
  - intro Heq. unfold Nat in n, m. inversion Heq.
    apply functional_extensionality. intro X.
    apply functional_extensionality. intro f.
    apply functional_extensionality. intro x.
    apply H.
Qed.

Tactic Notation "fune" := apply functional_extensionality.
Tactic Notation "fune3" ident(X) ident(f) ident(x) :=
  fune; intro X; fune; intro f; fune; intro x.

Theorem plus_O_n : forall n : Nat, plus zero n = n.
Proof.
  intro n. unfold plus, zero.
  fune3 X f x. reflexivity.
Qed.

Theorem plus_comm : forall n m : Nat, plus n m = plus m n.
Proof.
  intros n m. unfold plus. fune3 X f e.
  Abort.

(* Nat type does not contain context of repeated application.
   Nat only states function's types.
   but with such restriction, isn't it the only way to implement Nat instance
   to make a repeated application?
   Any way, without it, we can't prove commutativity *)

Theorem plus_Sn_m


콬으로 람다식을 증명하는데 이런 표현방법으로는 부족함이 있다.
콬은 말하자면 람다대수 그 자체이다. 좀 fancy한 람다대수.
거기서 람다식을 bare expression으로 표현하면 그에 대한 증명을 하기
(불가능?) 어렵다.
예컨데 람다대수에 대한 증명은 람다대수 상위의, 메타수학이 있어야 한다는 것이다.
덧셈과 관련된 증명을 위해서는 단순히 'n : a -> a' 이상의 context가 필요하다.
동일한 함수의 연속된 application은 순서에 상관없다는 사실이 있어야만
덧셈의 commutivity를 증명할 수 있기 때문이다.
'자연수를 iteration function으로 정의한다'는 명제는 람다식으로 표현할 수가 없다.
그렇기에 위의 접근법은 실패한다. 내가 써 놓은 명제들은 증명할 수가 없다.

정말로 콬을 이용해서 그런 것들을 증명하고 싶다면 콬으로 람다대수를 모델링할 수 있어야 한다.
Imp.v에서 한 것처럼 람다식을 Inductive Type으로 표현하고 그에 관한 명제들을 만드는건 증명할 수 있을것이다.

