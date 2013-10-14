Require Import
  Coq.Relations.Relations Coq.Relations.Relation_Operators
  Ssreflect.ssreflect Ssreflect.ssrnat.

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.

Notation inclusion R R' := (forall t1 t2, R t1 t2 -> R' t1 t2).
Notation same_relation R R' := (forall t1 t2, R t1 t2 <-> R' t1 t2).
Notation confluent R :=
  (forall t1 t2 t3, R t1 t2 -> R t1 t3 -> exists t4, R t2 t4 /\ R t3 t4).

Notation "[ * R ]" :=
  (clos_refl_trans_1n _ R) (at level 5, no associativity) : type_scope.

Hint Resolve rt1n_refl.

Lemma rtc_trans' A R : transitive A [* R].
Proof.
  move => t1 t2 t3.
  rewrite -!clos_rt_rt1n_iff.
  apply rt_trans.
Qed.

Lemma rtc_step A (R : relation A) : inclusion R [* R].
Proof.
  by move => x y H; apply rt1n_trans with y.
Qed.

Lemma rtc_map A (R R' : relation A) : inclusion R R' -> inclusion [* R] [* R'].
Proof.
  move => H.
  refine (clos_refl_trans_1n_ind A R _ _ _) => // t1 t2 t3 H0 H1 H2.
  apply rt1n_trans with t2; auto.
Qed.

Lemma rtc_nest_elim A (R : relation A) : same_relation [* [* R]] [* R].
Proof.
  move => t1 t2; split.
  - move: t1 t2; refine (clos_refl_trans_1n_ind A _ _ _ _) => //.
    by move => t1 t2 t3 H _ H0; apply rtc_trans' with t2.
  - apply clos_rt1n_step.
Qed.

Lemma rtc_semi_confluent A (R R' : relation A) :
  (forall t1 t2 t3, R t1 t2 -> R' t1 t3 -> exists t4, R' t2 t4 /\ R t3 t4) ->
  (forall t1 t2 t3, [* R] t1 t2 -> R' t1 t3 ->
    exists t4, R' t2 t4 /\ [* R] t3 t4).
Proof.
  move => H t1 t2 t3 H0; move: t1 t2 H0 t3.
  refine (clos_refl_trans_1n_ind A R _ _ _).
  - by move => t1 t3 H0; exists t3.
  - move => t1 t1' t2 H0 H1 IH t3 H2.
    case: (H t1 t1' t3 H0 H2) => t3'; case => {H H0 H2} H H0.
    case: (IH t3' H) => {IH H} t4; case => H H2; exists t4; split => //.
    by apply rt1n_trans with t3'.
Qed.

Lemma rtc_confluent A (R : relation A) : confluent R -> confluent [* R].
Proof.
  move => H.
  apply rtc_semi_confluent.
  move: (rtc_semi_confluent H) => {H} H t1 t2 t3 H0 H1.
  by case: (H t1 t3 t2 H1 H0) => t4; case => H2 H3; exists t4.
Qed.

Lemma rtc_confluent' A (R R' : relation A) :
  inclusion R R' -> inclusion R' [* R] -> confluent R' -> confluent [* R].
Proof.
  move => H H0 H1 t1 t2 t3 H2 H3.
  case (rtc_confluent H1 (rtc_map H H2) (rtc_map H H3))
    => t4 [H4 H5].
  by exists t4; split; rewrite -rtc_nest_elim; apply (rtc_map H0).
Qed.

Theorem rtc_preservation A (P : A -> Prop) (R : relation A) :
  (forall x y, R x y -> P x -> P y) -> forall x y, [* R] x y -> P x -> P y.
Proof.
  move => H.
  refine (clos_refl_trans_1n_ind A R _ _ _) => //= x y z H0 _ H1 H2.
  exact (H1 (H x y H0 H2)).
Qed.
