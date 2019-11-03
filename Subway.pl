:- (dynamic collection/1).
:- (dynamic state/1).
:- (dynamic counter/1).

main:- helpsubway().

% listed with all selected items
collection(nothing).
% state for asking the reight questions
state(breads).
% state for toppings that can be choosen multiple times
counter(0).

% User Experience
printhelpnote():- print("Type helpsubway(). for help!"), put(10).

helpsubway():-
    print("Use options(<parts-of-your-sandwich>). to get the information about all items."),put(10),
    print("parts-of-your-sandwich: breads, main, veggies, sauce, sides"), put(10),
    print("Use selected(<option>,<parts-of-your-sandwich>). to choose your items.").


% compute suggested Options
suggested(L, Output) :-
    findnsols(100, X, collection(X), Z),
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

% helper function to display the items in multiple lines
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
        put(10), printhelpnote()
    ;   X==main
    ->  retract(state(main)),
        assert(state(veggies)),
        print("Choose the vegetables now!"),
        put(10)
    ;   
    % specific case for veggies. There can be more than one item selected
    X==veggies
    -> 
        counter(Number),
        maxVeggies(Max), 
        (
            (
            % Ask for another veggie topping
            Number < Max -> print("Do you want to choose more? [y/n]"),
                read(Like),
                Like==y
                ->  retract(counter(Number)), 
                    assert(counter(Number + 1))
                    );
            % continue with the next case, set new state
            retract(state(veggies)),
            assert(state(sauce)),
            print("Choose the sauce now!"),
            put(10)
        )
    ;
   X==sauce
    ->  retract(state(sauce)),
        assert(state(sides)),
        print("Choose the sides now!"),
        put(10)
    ;   X==sides
    ->  retract(state(sides)),
        assert(state(breads)),
        done(1),
        % reset states
        abolish(counter/1),
        assert(counter(0)),
        abolish(collection/1),
        assert(collection(nothing)),
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
    (   collection(Y),
        Y==nothing
    ->  retract(collection(Y)),
        assert(collection(X))
    ;   assert(collection(X))
    ).


% show options
done(1) :-
    print("You selected:"),
    put(10),
    findnsols(100, Y, collection(Y), History),
    options_(History),
    put(10),
    printhelpnote().


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

% Max for Veggie selection
maxVeggies(3).


% everything that is allowed in a specific track
veggiemember([lettuce, tomato, mustard, chipotle, bbq, mayonaise, chilli, soda, cookie, apple]).
healthymember([lettuce, tomato, chipotle, bbq, chilli, soda, apple]).


% offers
breads([parmesan, honeywheat, italian]).
main([chicken, tuna, veggie, italian_bmt, healthy]).
veggies([lettuce, tomato]).
sauce([mustard, chipotle, bbq, mayonaise, chilli]).
sides([soup, soda, cookie, apple]).