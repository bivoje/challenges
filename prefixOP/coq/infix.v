
Inductive Tree {A} : Type :=
  | Leaf : A -> Tree
  | Node : A -> Tree -> Tree -> Tree.

(* prevent implicit parameter for Tree.
   while leaving Leaf and Node to accept implicit. *)
Arguments Tree (A) : clear implicits.

Definition tree_eg : Tree nat :=
  Node 7
    (Node 5
      (Leaf 1)
      (Node 4
        (Leaf 2)
        (Leaf 3)))
    (Leaf 6).

(* doesn't coq have [Either]?*)
Inductive Report {A} : Type :=
  | Node' : A -> Report
  | Leaf' : A -> Report.
Arguments Report (A) : clear implicits.

Definition Reports A := list (Report A).

Require Import List.
Import ListNotations.

Fixpoint pre_order {A} (t : Tree A) : Reports A :=
  match t with
  | Leaf x => [Leaf' x]
  | Node x tl tr => Node' x :: pre_order tl ++ pre_order tr
  end.

Example preorder_eg : pre_order tree_eg =
  [Node' 7; Node' 5; Leaf' 1; Node' 4; Leaf' 2; Leaf' 3; Leaf' 6].
  auto. Qed.

Fixpoint in_order {A} t : @Reports A :=
  match t with
  | Leaf x => [Leaf' x]
  | Node x tl tr => in_order tl ++ [Node' x] ++ in_order tr
  end.

Example inoder_eg : in_order tree_eg =
  [Leaf' 1; Node' 5; Leaf' 2; Node' 4; Leaf' 3; Node' 7; Leaf' 6].
  auto. Qed.

Fixpoint post_order {A} t : Reports A :=
  match t with
  | Leaf x => [Leaf' x]
  | Node x tl tr => post_order tl ++ post_order tr ++ [Node' x]
  end.

Example postorder_eg : post_order tree_eg =
  [Leaf' 1; Leaf' 2; Leaf' 3; Node' 4; Node' 5; Leaf' 6; Node' 7].
  auto. Qed.

(* cannot be directly defined in coq *)
Fixpoint order_pre {A} (rps : Report A) : option (Tree A * Report A).
Abort.

Fixpoint order_post' {A} stack rps : option (Tree A) :=
  match rps with
  | [] => match stack with | [T] => Some T | _ => None end
  | Leaf' x :: rest => order_post' (Leaf x :: stack) rest
  | Node' x :: rest => match stack with
    | a :: b :: stack' => order_post' (Node x b a :: stack') rest
    | _ => None
    end
  end.

Definition order_post {A} := @order_post' A [].

Example post_rev_eg : order_post (post_order tree_eg) = Some tree_eg.
  auto. Qed.

Lemma order_post_advance : forall A (t : Tree A) stack rps,
  order_post' stack (post_order t ++ rps)
  = order_post' (t :: stack) rps.
Proof.
  intros A t. induction t. reflexivity.
  intros stack rps. simpl. do 2 rewrite <- app_assoc.
  rewrite IHt1. rewrite IHt2. simpl. reflexivity.
Qed.

Theorem post_rev : forall A (t : Tree A),
  order_post (post_order t) = Some t.
Proof.
  intros. induction t. reflexivity.
  unfold order_post. simpl.
  do 2 rewrite order_post_advance.
  simpl. reflexivity.
Qed.

Example inorder_ambiguous :
  in_order (Node 1 (Node 2 (Leaf 3) (Leaf 4)) (Leaf 5)) =
  in_order (Node 2 (Leaf 3) (Node 1 (Leaf 4) (Leaf 5))).
  auto. Qed.

Inductive Report_ {A} : Type :=
  | Leaf_ : A -> Report_
  | Node_ : A -> Report_
  | Open_ : Report_
  | Clos_ : Report_.
Arguments Report_ (A) : clear implicits.

Definition Reports_ A := list (Report_ A).

(* wraps every operator execution with parenthesis.
   no ternary (or more) terms.
   adds minimal + 2 (outermost) parenthesis
   that makes it unambigous without precedence. TODO proof? *)
Fixpoint in_order1 {A} (t : Tree A) : Reports_ A :=
  match t with
  | Leaf x => [Leaf_ x]
  | Node x tl tr => [Open_] ++ in_order1 tl ++ [Node_ x] ++ in_order1 tr ++ [Clos_]
  end.

Example inorder_eg_ : in_order1 tree_eg =
  [Open_; Open_; Leaf_ 1; Node_ 5; Open_; Leaf_ 2; Node_ 4; Leaf_ 3; Clos_; Clos_; Node_ 7; Leaf_ 6; Clos_].
  auto. Qed. (* ((1 <5> (2 <4> 3)) <7> 6) *)

Fixpoint order_in1' {A} stack rps : option (Tree A) :=
  let push st r t := order_in1' (Some t :: st) r in
  match rps with
  | [] => match stack with | [Some T] => Some T | _ => None end
  | Open_   :: rest => order_in1' (None :: stack) rest
  | Leaf_ x :: rest => push stack rest (Leaf x)
  | Node_ x :: rest => push stack rest (Leaf x)
  | Clos_   :: rest => match stack with
    | Some tr :: Some (Leaf x) :: Some tl :: None :: stack'
        => push stack' rest (Node x tl tr)
    | _ => None
    end
  end.

Definition order_in1 {A} := @order_in1' A [].

Example in_rev_eg1 : order_in1 (in_order1 tree_eg) = Some tree_eg.
  auto. Qed.

Lemma order_in_advance1 : forall A (t : Tree A) stack rps,
  order_in1' stack (in_order1 t ++ rps)
  = order_in1' (Some t :: stack) rps.
Proof.
  intros A t. induction t. reflexivity.
  intros stack rps. simpl.
  rewrite <- app_assoc. rewrite IHt1. simpl.
  rewrite <- app_assoc. rewrite IHt2. simpl.
  reflexivity.
Qed.

Theorem in_rev1 : forall A (t : Tree A),
  order_in1 (in_order1 t) = Some t.
Proof.
  intros. induction t. reflexivity.
  unfold order_in1. simpl.
  rewrite order_in_advance1. simpl.
  rewrite order_in_advance1. simpl.
  reflexivity.
Qed.

Require Import Nat.

(* adds minimal parenthesis that makes it unambigous with
   precedence. TODO proof? *)
Fixpoint in_order2 {A} (prec : Tree A -> nat) (t : Tree A) : Reports_ A :=
  let wrap t' := let rps := in_order2 prec t' in
    if prec t <? prec t' then [Open_] ++ rps ++ [Clos_] else rps
  in match t with
  | Leaf x => [Leaf_ x]
  | Node x tl tr => wrap tl ++ [Node_ x] ++ wrap tr
  end.

Definition natprec (t : Tree nat) :=
  match t with
  | Leaf _ => 0 (* highst *)
  | Node x _ _ => x
  end.

Example inorder2_eg1 : in_order2 natprec tree_eg =
  [Leaf_ 1; Node_ 5; Leaf_ 2; Node_ 4; Leaf_ 3; Node_ 7; Leaf_ 6].
  auto. Qed. (* 1 <5> 2 <4> 3 <7> 6 *)

Definition tree_eg2 : Tree nat :=
  Node 2
    (Node 5
      (Leaf 1)
      (Node 4
        (Leaf 7)
        (Leaf 3)))
    (Leaf 6).

Example inorder2_eg2 : in_order2 natprec tree_eg2 =
  [Open_; Leaf_ 1; Node_ 5; Leaf_ 7; Node_ 4; Leaf_ 3; Clos_; Node_ 2; Leaf_ 6].
  auto. Qed. (* (1 <5> 7 <4> 3) <2> 6 *)

Definition comsume {A} prec stack : option (Reports_ A * Tree_ A) :=
  match stack with
  | [] => Notihng
  | Node_ x :: Leaf_ r :: Leaf_ l :: stack' => Node 

Definition order_in_' {A} (prec : Tree A -> nat) (rps : Reports_ A) : option (Tree A).
Admitted.

Example in_rev_eg_' : True. Admitted.

Theorem in_rev_ : True. Admitted.

Theorem in_rev_' : True. Admitted.

Definition in_post {A} : Reports_ A -> Reports A.
Admitted.

use Clear to redefine previous definition, instead of deleting it.