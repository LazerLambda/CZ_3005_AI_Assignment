:- (dynamic collection/1).
:- (dynamic state/1).
:- (dynamic counter/1).


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
    findnsols(100, X, collection(X), Z),                            % get a list of the previous selection
    (   member(healthy, Z)                                          % check wether healthy is part of the previous selection
    ->  findnsols(100, Y, healthytrack(L, Y), Output)               % Assign the list of the allowed options to the Output Var
    ;   member(veggie, Z)                                           % check wether veggie is part of the previous selection
    ->  findnsols(100, Y, veggietrack(L, Y), Output)                % Assign the list of the allowed options to the Output Var
    ;   append([], L, Output)                                       % Output has to be L
    ).


% display options
options(Name) :-
    call(Name, L),                                                  % get List of predicate with the name 'Name'
    suggested(L, Lst),                                              % get the allowed suggestions for this list
    print("The following options are available for your order:"),
    options_(Lst).                                                  % print the possible options

% helper function to display the items in multiple lines
options_([]).                                                       % termination condition
options_([Head|Tail]) :-                                    
    print(Head),                                                    % print the first element of the list
    put(10),                                                        % newline
    options_(Tail).                                                 % recursive call of the function with the rest / tail of the list


% switch state -> next selection
selected(0) :-
    state(X),                                                       % get current state
    (   X==breads                                                   % check for specific state (1)
    ->  switchState(breads, main),                                  % change to the new state  (2)
        print("Choose the main topping now!"),
        put(10), printhelpnote()
    ;   X==main                                                     % analogous to (1)
    ->  switchState(main, veggies),                                 % analogous to (2)
        print("Choose the vegetables now!"),
        put(10)
    ;   
    % specific case for veggies. There can be more than one item selected
    X==veggies                                                      % analogous to (1)
    -> 
        (
            mulitpleSelection(maxVeggies);                          % check for multiple selection
            % continue with the next case, set new state
            switchState(veggies, sauce),                            % switch to next state
            print("Choose the sauce now!"),                      
            put(10)
        )
    ;
   X==sauce                                                         % analogous to (1)
    ->  switchState(sauce, sides),                                  % analogous to (2)
        print("Choose the sides now!"),
        put(10)
    ;   X==sides                                                    % analogous to (1)
    ->  switchState(sides, breads),                                 % analogous to (2)
        done(1),                                                    % show results
                 
        % reset states 

        abolish(collection/1),                                      % clear collection predicate 
        assert(collection(nothing)),                                % reassert collection predicate with nohing
        counter(Y),                                                 % get actual Variable from counter
        retract(counter(Y)),                                        % remove Variable from counter
        assert(counter(0)),                                         % reassert counter predicate with 0
        print("Thanks for eating at Subway"),
        put(10)
    ).

% change state
switchState(X,Y):- retract(state(X)), assert(state(Y)).             % retract old state and assert new state

% Rule for multiple selection
mulitpleSelection(MaxPred):-                                        % Variable MaxPred can be any maximum for a multi selection
    call(MaxPred, MAX),                                             % get Variable of predicate MaxPred 
    counter(Number),                                                % get Counter Variable
    (
    % Ask for more toppings
    Number < MAX ->                                                 % check if the maximum is reached
        print("Do you want to choose more? [y/n]"),                 % askk the user for more toppings
        read(Like),                                                     
        Like==y
        ->  retract(counter(Number)),                               % update the counter state, retract actual number
            assert(counter(Number + 1))                             % assert new updated number
    ).


% add order
selected(X, L) :-
    call(L, Lst),                                                   % get List from predicate name
    state(Y),                                                       % get state
    (   Y==L                                                        % check if selected is in the correct state
    ->  suggested(Lst, SuggLst),                                    % get the suggested list
        (   member(X, SuggLst)                                      % check if the option is member of the suggested list, so that the options will stay on track
        ->  addToSelection(X),                                      % add to selection
            print("Good choice."),
            put(10),
            selected(0)                                             % go to next list
        ;   print("I am sorry. This item is unfortunately not available.")
        )                                                           % error messae if the option is not member of the suggested list
    ;   print("Something went wrong. You have to choose"),          % error message if the state is not correct
        print(Y),   
        put(10)
    ).

addToSelection(X) :-
    (   collection(Y),                                              % get the collection
Y==nothing                                                          % check if it's nothing to (Beginning of the process)
    ->  retract(collection(Y)),                                     % retract nothing
        assert(collection(X))                                       % assert the choosen option
    ;   assert(collection(X))                                       % assert the choosen option
    ).


% show options
done(1) :-
    print("You selected:"),
    put(10),
    findnsols(100, Y, collection(Y), History),                      % get the collected options as a list
    options_(History),                                              % print the list
    put(10),
    printhelpnote().                                                % print a help note for the user


% specific tracks
veggietrack(Lst, X) :-                                              % check if element of Lst is also part of the veggietrack
    veggiemember(Vl),                                               % get all veggie options
    member(X, Lst),                                                 % check if the Variable is in Lst and in Vl
    member(X, Vl).
healthytrack(Lst, X) :-                                             % analogous to veggietrack
    healthymember(Vl),  
    member(X, Lst),
    member(X, Vl).


% Knowledge base

% Max for Veggie selection
maxVeggies(3).                                                      % const for the maximum of veggie selections


% everything that is allowed in a specific track
veggiemember([lettuce, tomato, mustard, chipotle, bbq, mayonaise, chilli, soda, cookie, apple]).
healthymember([lettuce, tomato, chipotle, bbq, chilli, soda, apple]).


% offers
breads([parmesan, honeywheat, italian, cheddar, flatbread, honeyoat]).
main([chicken, tuna, veggie, italian_bmt, healthy]).
veggies([cucumber, lettuce, tomato, jalapeno, spinach]).
sauce([mustard, chipotle, bbq, mayonaise, chilli, cesarsauce]).
sides([soup, soda, cookie, apple]).