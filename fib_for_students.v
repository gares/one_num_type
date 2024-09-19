Require Import Reals List Lra R_subsets rec_def R_compute rec_def_examples.
(* TODO: remove this line when the file contains only stuff for the student's
eyes*)
Require Import Lia.
Open Scope R_scope.

(* You can type numeric formulas.  The result is a real number. *)

Check (3 + 5).

(* The command "Check" helps you test if you can write a formula that the
  proof assistant will be able to understand.  When it understand a formula,
  this command returns information about the type of the object that you
  gave it. *)

Definition add5 (x : R) := x + 5.
(* Parameter add5 : R -> R.
Axiom add5_def : forall x, add5 x = (x + 5). *)

(* when you use the Check command, you can give a function name to it.  The
  command returns different information than for a number.  Here the information
  explains that the object is a function, that it expects an argument of type R,
  and that it will return a value of type R. *)

Check add5.

(* Because the function expects a number argument, you can apply it to something
  that is a number.  For instance, we already know that (3 + 5) is a real number,
  so we can write the following formula, which is well formed. *)

Check add5 (3 + 5).

(* On the other hand, we cannot apply the function to itself, because the function
  is not a number.  Here I use the prefix command "Fail" to warn the system that
  I know this is an error, and it should not get to upset. *)

Fail Check add5 (add5).

(* Similarly, a number is not a function so, it cannot be applied to another number. 
  This kind of consistency checking of formulas is one of the first benefits of
  using a proof assistant to write mathematics. *)

Fail Check 3 (3).

(* A notation habit of this proof tool is that parentheses are not necessarily
  written around the argument of functions.  Here is an example.  the function
  add is applied to 3, and then the result is multiplied by 5. *)

Check add5 3 * 5.

(* If on the other hand one wishes to write the formula where the function is
  applied to the result of the multiplication, one needs to add the parentheses
  explicitly. *)

Check add5 (3 * 5).

(*  Computing. *)
(* To compute formulas, one need to start a proof, where one describes explicitly
   the results that one expect. *)

Example exercise1 : add5 (3 * 5) = 20.
Proof.
(* The proof tool is candid: it knows very little.  In particular, it does not
  know what the function add5 does, so we need to explicitly instruct it to
  unfold the definition. *)
unfold add5. (* rewrite add5_def. *)
(* On the other hand, once we have a formula that contains only operations
  it already knows, it can berform the computation for us.  The command
  to perform the computation of a subformula in the goal is called 
  ring_simplify. *)
ring_simplify (3 * 5 + 5).
(* After this step, it is easy to recognize that we want to prove an
  quality between a number and itself.   We can ask the system to do it
  with the "easy" proof command. *)
easy.
Qed.

(* A notion that if often studied in mathematics is the notion of recursive
  sequences of numbers.  The following command shows how to define such a
  recursive sequence, where we specify the value of the first element of the
  sequence (dd 0)  and then we show how to obtain the value for some n by
  using the value at the previous position.  We call this function dd because
  it actually returns the double of n. *)
Recursive
  (def dd such that dd 0 = 0 /\ 
   forall n, Rnat (n - 1) -> dd n = 2 + dd (n - 1)).

(* When you use the this command, it constructs the function dd and also
  provides a theorem that repeats the specification.  This theorem can
  be used to show properties of the sequence. *)

Check dd_eqn.

(* We shall now write a very simple theorem, which shows how we can use
  the specification to compute the actual value of dd for a given index.
  We wish to prove dd 2 = 4 *)

(* Before proving this theorem, let's review a few automatic tools available
  to us.
  Commands that are called when a goal needs to be solved are called tactic.
  When a goal is about comparing two mathematical expressions built with
  + * - and constants, the command to call is lra.  It will fail if the
  comparison one wants to prove is not valid.  Here is an example.  *)

Lemma compare_two_formulas : 1 + 2 * 5 < 3 * 4.
Proof. lra. Qed.

(* When we want to simplify some computation with constants, multiplication,
  addition, subtraction, and constants, we use a tactic called ring_simplify.
  *)
Lemma replace_formula_by_result_of_computation : dd (5 + 2) = dd 7.
Proof.
ring_simplify (5 + 2).
(* Where initially there was (5 + 2) we now have the result of the computation
*)
(* Now, when a statement to prove is an equality with the same thing on 
  both side, we can use an simple automation tactic called "easy". *)
easy.
Qed.

Lemma prove_that_a_number_is_a_natural_number : Rnat 4 /\ Rnat 0 /\ Rnat (6 + 7)
  /\ Rnat (9 - 2) /\ Rnat (5 + (9 - 2)).
Proof.
(* Proving a conjunction can be done step by step. *)
split.
  (* Proving that a constant like 4 is a natural number is done automatically
    using a tactic provided by this course. *)
  solve_Rnat.
split.
  solve_Rnat.
split.
  solve_Rnat.
split.
(* In the present version, the automatic tool does not take of subtractions,
  but there is a theorem explaining that you only need to check that the
  two numbers are already natural numbers and the first is larger than the
  second one.  This theorem is used with a command named "apply". *)
  apply Rnat_sub.
      solve_Rnat.
    solve_Rnat.
  (* For the comparison we can use the tactic "lra" that we already encountered. *)
  lra.
  (* When there is an addition and one of the terms cannot be solved automatically
    we need to decompose the problem by hand.  A similar theorem can be used here. *)
apply Rnat_add.
  solve_Rnat.
  (* Here we have to do the same proof as before. *)
apply Rnat_sub.
    solve_Rnat.
  solve_Rnat.
lra.
Qed.

Lemma dd2 : dd 2 = 4.
Proof.
(* The statement of dd_eqn is a conjunction (in other words, an "and" 
  statement).  We give separate names to the two parts of this conjunction. *)
destruct dd_eqn as [dd0 dd_suc].
(* dd_suc is an equality available under some condition.  We can rewrite
  with it, but the system will produce an extra goal to check that the
  condition is satisfied. *)
rewrite dd_suc.
  (* Two goals are generated actually, the first one has (dd 2) replace by
    its value according to the specification, the second has the condition
    that (2 - 1) should be a natural number. *)
  ring_simplify (2 - 1).
(* Now there is another instance of dd, we can rewrite again with dd_suc *)
(* but this time, we anticipate that it will require us to prove that (1 - 1)
  is a natural number, so we prove this fact in advance. *)
assert (nat1 : Rnat (1 - 1)).
  ring_simplify (1 - 1).
  solve_Rnat.
(* Now we can perform the rewrite with dd_suc, but tell directly to the prover
  to use the fact that we proved in advance for the second generated goal. *)
rewrite dd_suc;[ | exact nat1].
ring_simplify (1 - 1).
rewrite dd0.
ring.
(* Now we have to prove the condition that was produced at the first rewrite
  using dd_suc. *)
ring_simplify (2 - 1).
solve_Rnat.
Qed.

Elpi mirror_recursive_definition dd.

Check fib_eqn.

R_compute (dd 212).

R_compute (fib (fib 9)).

Fail R_compute (fib (add5 3)).

(* TODO: improve R_compute so that mirror functions for simple definitions
  like add5 are also generated automatically. *)

Definition add5Z (x : Z) := (x + 5)%Z.

Lemma add5_Z_prf x : add5 (IZR x) = IZR (add5Z x).
Proof.
 now unfold add5Z; rewrite plus_IZR. 
(* now unfold add5Z; rewrite add5_def, plus_IZR. *)
Qed.   

add_computation add5 add5Z add5_Z_prf.

Elpi R_compute (add5 3).

Elpi R_compute (fib (add5 3)).

(* When we want to prove equalities between formulas,
  where the operation are addition multiplication 
  subtraction and division, we use field instead of
  ring. *)

Lemma Fibonacci_and_golden_number n:
  let phi := (sqrt 5 + 1) / 2 in
  let phi' := (1 - sqrt 5) / 2 in
    Rnat n -> 
    fib n = (Rpow phi n - Rpow phi' n)/ sqrt 5.
Proof.
destruct fib_eqn as [fib0 [fib1 fib_suc]].
intros phi phi'.
assert (sqrt5gt0 : 0 < sqrt 5).
  apply sqrt_lt_R0.
  lra.
assert (phi_gt0 : 0 < phi).
  unfold phi.
  lra.
 assert (phi_root :  Rpow phi 2 = phi + 1).
  replace 2 with (1 + 1) by ring.
  rewrite Rpow_add, Rpow1; try typeclasses eauto.
  unfold phi.
  replace ((sqrt 5 + 1) / 2 * ((sqrt 5 + 1) / 2)) with
    ((sqrt 5 * sqrt 5 + 2 * sqrt 5 + 1)  / 4) by field.
  rewrite sqrt_sqrt;[ | lra].
  now field.
assert (phi'_root : Rpow phi' 2 = phi' + 1).
  replace 2 with (1 + 1) by ring.
    rewrite Rpow_add, Rpow1; try typeclasses eauto.
  unfold phi'.
  replace ((1 - sqrt 5) / 2 * ((1 - sqrt 5) / 2)) with
    ((sqrt 5 * sqrt 5 - 2 * sqrt 5 + 1)  / 4) by field.
  rewrite sqrt_sqrt; [ | lra].
  now field.
intros nnat.
enough (main : fib n = (Rpow phi n - Rpow phi' n) / sqrt 5 /\
        fib (n + 1) = (Rpow phi (n + 1) - Rpow phi' (n + 1)) / sqrt 5).
  destruct main as [it _]; exact it.
induction nnat as [ | p pnat Ih].
  split.
    (* Here we prove the equality at 0. *)
    rewrite 2!Rpow0.
    rewrite fib0.
    field.
    lra.
  (* Here we prove the equality at 1. *)
  ring_simplify (0 + 1).
  rewrite fib1.
  rewrite 2!Rpow1.
  unfold phi, phi'.
  field.
  lra.
(* Here we prove the equality at n + 1 and n + 2,
  knowing it already works for n and n + 1. *)
destruct Ih as [Ih1 Ih2].
split;[ assumption | ].
assert (pnat' : Rnat (p + 1 + 1 - 2)).
  ring_simplify (p + 1 + 1 - 2).
  assumption.
rewrite fib_suc; auto. 
ring_simplify (p + 1 + 1 - 2).
ring_simplify (p + 1 + 1 - 1).
rewrite Ih1.
rewrite Ih2.
assert (clever: 
  Rpow phi (p + 1 + 1) = Rpow phi (p + 1) + Rpow phi p).
  replace (p + 1 + 1) with (p + 2) by ring.
  rewrite Rpow_add; solve_Rnat.
  rewrite phi_root.
  rewrite Rpow_add; solve_Rnat.
  rewrite Rpow1.
  ring.
rewrite clever.
assert (clever': 
  Rpow phi'(p + 1 + 1) = Rpow phi' (p + 1) + Rpow phi' p).
  replace (p + 1 + 1) with (p + 2) by ring.
  rewrite Rpow_add; solve_Rnat.
  rewrite phi'_root.
  rewrite Rpow_add; solve_Rnat.
  rewrite Rpow1.
  ring.
rewrite clever'.
field.
lra.
Qed.


