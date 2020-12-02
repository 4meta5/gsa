:- use_module(library(clpfd)).

inv(app,slot).
inv(X,Y) :- inv(Y,X).
apps([a,b,c]).
slots([x,y,z]).
agent(app,X) :- apps(X).
agent(slot,X) :- slots(X).
app(A):-apps(X),member(A,X).
slot(A):-slots(X),member(A,X).

prefs(a,[x,y,z]).
prefs(b,[x,y,z]).
prefs(c,[z,x,y]).
prefs(x,[b,a,c]).
prefs(y,[b,a,c]).
prefs(z,[c,a,b]).

prefer(Who,Yes,No) :-
    prefs(Who,Rank),member(Yes,Rank),not(member(No,Rank)).
prefer(Who,Yes,No) :-
    prefs(Who,Rank),member(Yes,Rank),member(No,Rank),
    append(_,[Yes|Rest],Rank),
    member(No,Rest).
pair([A,B]) :- app(A),slot(B).
all_pairs(R) :- findall([A,B],pair([A,B]),R).
all_free(Goal,R) :-
    agent(Goal,_),
    findall([A,om],(call(Goal,A)),R).
mrg(X,Y,Z) :- append([X],[Y],Z).
border :- write('--------------------------------------'),nl.
gsa(Goal,R) :-
    agent(Goal,Proposers),inv(Goal,Accp),all_free(Accp,Accepters),
    findall(X,(member(Y,Proposers),prefs(Y,X)),ProposerRks),
    findall(Z,(member([W,_],Accepters),prefs(W,Z)),AccepterRks),
    maplist(mrg,Proposers,ProposerRks,PRK),
    border,write('Proposers with preferences: '),write(PRK),nl,
    write('Accepters: '),write(Accepters),nl,write('Accepter preferences: '),write(AccepterRks),nl,
    run(Accepters,PRK,[],R).
/*run(Unpaired,ProposersWithRkings,Accumulator,ResultPairs)*/
run(_,[],R,R).
run(U,[[_,[]]|P],S,R) :- run(U,P,S,R).
run(Unp,[[P,[X|Z]]|Props],Prs,R) :-
    border,write(P),write(' is proposing to '),write(X),nl,
    write('The accumulator state is: '),write(Prs),nl,
    (member([X,XX],Unp) -> append(Prs,[[X,P]],Pr2),border,write('New accumulator state is: '),write(Pr2),nl,
        del([X,XX],Unp,Unp2),write('New unpaired state is: '),write(Unp2),nl,run(Unp2,Props,Pr2,R);
    member([X,CP],Prs) -> 
            (prefer(X,P,CP) -> border,write(X),write(' accepts proposal from '),write(P),write(' and displaces '),write(CP),nl,
                prefs(CP,Y),insert([CP,Y],Props,Prop2),del([X,CP],Prs,Pr2),insert([X,P],Pr2,Pr3),run(Unp,Prop2,Pr3,R);
            border,write(X),write(' rejects proposal from '),write(P),nl,run(Unp,[[P,Z]|Props],Prs,R));
    run(Unp,[[P,Z]|Props],Prs,R)).
del(X,[X|T],T).
del(X,[Y|T],[Y|T2]) :-
    del(X,T,T2).
insert(X,L,L2) :-
    del(X,L2,L).