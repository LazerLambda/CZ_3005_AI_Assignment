:- (dynamic liked/1).
:- (dynamic state/1).

% listed with all selected items
liked(nothing).
% state for asking the reight questions
state(breads).


% compute suggested Options
suggested(L, Output) :-
    findnsols(100, X, liked(X), Z),
    (   member(healthy, Z)
    ->  findnsols(100, Y, healthytrack(L, Y), Output)
    ;   member(veggie, Z)
    ->  findnsols(100, Y, veggietrack(L, Y), Output)
    ;   append([], L, Output)
    ).


% display options
options(Name) :-
    call(Name, L),
    suggested(L, Lst),
    print("The following options are available for your order:"),
    options_(Lst).

options_([]).
options_([Head|Tail]) :-
    print(Head),
    put(10),
    options_(Tail).


% switch state -> next selection
selected(0) :-
    state(X),
    (   X==breads
    ->  retract(state(breads)),
        assert(state(main)),
        print("Choose the main topping now!"),
        put(10)
    ;   X==main
    ->  retract(state(main)),
        assert(state(veggies)),
        print("Choose the vegetables now!"),
        put(10)
    ;   X==veggies
    ->  print("Do you want to choose more veggetables? [y/n]"),
        read(Like),
        (   Like==y
        ->  print("OK")
        ),
        retract(state(veggies)),
        assert(state(sauce)),
        print("Choose the sauce now!"),
        put(10)
    ;
   %         );
   X==sauce
    ->  retract(state(sauce)),
        assert(state(sides)),
        print("Choose the sides now!"),
        put(10)
    ;   X==sides
    ->  retract(state(sides)),
        assert(state(breads)),
        done(1),
        abolish(liked/1),
        assert(liked(nothing)),
        print("Thanks for eating at Subway"),
        put(10)
    ).


% add order
selected(X, L) :-
    call(L, Lst),
    state(Y),
    (   Y==L
    ->  suggested(Lst, SuggLst),
        (   member(X, SuggLst)
        ->  addToSelection(X),
            print("Good choice."),
            put(10),
            selected(0)
        ;   print("I am sorry. This item is unfortunately not available.")
        )
    ;   print("Something went wrong. You have to choose"),
        print(Y),
        put(10)
    ).

addToSelection(X) :-
    (   liked(Y),
        Y==nothing
    ->  retract(liked(Y)),
        assert(liked(X))
    ;   assert(liked(X))
    ).


% show options
done(1) :-
    print("You selected:"),
    put(10),
    findnsols(100, Y, liked(Y), History),
    options_(History),
    put(10).


% specific tracks
veggietrack(Lst, X) :-
    veggiemember(Vl),
    member(X, Lst),
    member(X, Vl).
healthytrack(Lst, X) :-
    healthymember(Vl),
    member(X, Lst),
    member(X, Vl).


% Knowledge base
veggiemember([lettuce, tomato, mustard, chipotle, bbq, mayonaise, chilli, soda, cookie, apple]).
healthymember([lettuce, tomato, chipotle, bbq, chilli, soda, apple]).

breads([parmesan, honeywheat, italian]).
main([chicken, tuna, veggie, italian_bmt, healthy]).
veggies([lettuce, tomato]).
sauce([mustard, chipotle, bbq, mayonaise, chilli]).
sides([soup, soda, cookie, apple]).