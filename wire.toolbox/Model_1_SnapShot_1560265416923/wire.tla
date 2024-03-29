-------------------------------- MODULE wire --------------------------------

EXTENDS Integers

(*--algorithm wire
  variables
    people = {"alice", "bob"},
    acc = [p \in people |-> 5];

define
  NoOverdrafts == \A p \in people: acc[p] >= 0
end define;

process Wire \in 1..2
  variables
    sender = "alice",
    receiver = "bob",
    amount \in 1..acc[sender];
begin
  Withdraw:
    acc[sender] := acc[sender] - amount;
  Deposit:
    acc[receiver] := acc[receiver] + amount;
end process;
  end algorithm;*)
\* BEGIN TRANSLATION
VARIABLES people, acc, pc

(* define statement *)
NoOverdrafts == \A p \in people: acc[p] >= 0

VARIABLES sender, receiver, amount

vars == << people, acc, pc, sender, receiver, amount >>

ProcSet == (1..2)

Init == (* Global variables *)
        /\ people = {"alice", "bob"}
        /\ acc = [p \in people |-> 5]
        (* Process Wire *)
        /\ sender = [self \in 1..2 |-> "alice"]
        /\ receiver = [self \in 1..2 |-> "bob"]
        /\ amount \in [1..2 -> 1..acc[sender[CHOOSE self \in  1..2 : TRUE]]]
        /\ pc = [self \in ProcSet |-> "Withdraw"]

Withdraw(self) == /\ pc[self] = "Withdraw"
                  /\ acc' = [acc EXCEPT ![sender[self]] = acc[sender[self]] - amount[self]]
                  /\ pc' = [pc EXCEPT ![self] = "Deposit"]
                  /\ UNCHANGED << people, sender, receiver, amount >>

Deposit(self) == /\ pc[self] = "Deposit"
                 /\ acc' = [acc EXCEPT ![receiver[self]] = acc[receiver[self]] + amount[self]]
                 /\ pc' = [pc EXCEPT ![self] = "Done"]
                 /\ UNCHANGED << people, sender, receiver, amount >>

Wire(self) == Withdraw(self) \/ Deposit(self)

Next == (\E self \in 1..2: Wire(self))
           \/ (* Disjunct to prevent deadlock on termination *)
              ((\A self \in ProcSet: pc[self] = "Done") /\ UNCHANGED vars)

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION

=============================================================================
\* Modification History
\* Last modified Tue Jun 11 22:58:05 CST 2019 by oskarth
\* Created Tue Jun 11 22:17:04 CST 2019 by oskarth
