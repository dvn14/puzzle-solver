%-----------------------------------------------------------------------------
% AUTHOR
%
% Devin Nanayakkara
% Master of Data Science, University of Melbourne
%
% Purpose: Maths Puzzle Solver written in Prolog

%-----------------------------------------------------------------------------
% PROJECT SPECIFICATION: COMP90048 Project 1, 2021 Semester 1
%
% A maths puzzle is a square grid of squares, each to be filled in with a
% single digit 1–9 (zero is not permitted) satisfying these constraints:
%    1. Each row and each column contains no repeated digits;
%    2. All squares on the diagonal line (upper left to lower right) contain
%       the same value; and
%    3. The heading of reach row and column (leftmost square in a row and
%       topmost square in a column) holds either the sum or the product of
%       all the digits in that row or column.
%
% Here is an example puzzle as posed (left) and solved (right) :
% |    | 14 | 10 | 35 |           |    | 14 | 10 | 35 |
% | 14 |    |    |    |           | 14 |  7 |  2 |  1 |
% | 15 |    |    |    |    ==>    | 15 |  3 |  7 |  5 |
% | 28 |    |  1 |    |           | 28 |  4 |  1 |  7 |
%
% GOAL: Fill in all the squares of the Puzzle according to the rules and
% should have at most one solution. Upon success, its argument must be ground.
%
% The program supplies a predicate puzzle_solution(Puzzle) that holds when
% Puzzle is the representation of a solved maths puzzle. If Puzzle is not 
% solvable, the predicate should fail.
%
% A maths puzzle will be represented as a list of lists (NxN), each of the
% same length, representing a single row of the puzzle. Puzzle parsed will be
% partially instentiated. Each element of the first list is the header
% for that column, except for the first element which is ignored. Second list
% onwards, the first element of each list is the header for that row.

%-----------------------------------------------------------------------------
% ASSUMPTIONS
% 
% 1. Bound and unbound elements: when puzzle_solution/1 predicate is called,
%    its argument will be a proper list of proper lists, and all the header
%    squares of the puzzle (plus the ignored corner square) are bound to
%    integers. Some of the other squares in the puzzle may also be bound to
%    integers, but the others will be unbound.
% 2. puzzle_solution/1 predicate will only be tested with proper puzzles,
%    which have at most one solution.

%-----------------------------------------------------------------------------
% LIBRARIES
%
% This programme uses the clpfd library for numorous arithmetic constraints
% and other functions.

:- ensure_loaded(library(clpfd)).

%-----------------------------------------------------------------------------
% PUZZLE SOLVER
%
% puzzle_solution(+ListOfLists)
% puzzle_solution(Puzzle) holds when Puzzle is the representation of a
% solved maths puzzle.
%
% Step 1: Check if the length of each list in Puzzle is the same.
% Step 2: Check if the squares of Puzzle are single digit between 1–9.
% Step 3: Introduce the transpose of Puzzle, i.e. PuzzleT, because the
%         predicates test/validate on rows.
% Step 4: Validate constraint 1.
% Step 5: Validate constraint 2.
% Step 6: Validate constraint 3.
% Step 7: Ground all variables.

puzzle_solution(Puzzle) :-
    maplist(same_length(Puzzle), Puzzle),
    digit_check(Puzzle),
    transpose(Puzzle, PuzzleT),
    repeat_check(Puzzle),
    repeat_check(PuzzleT),
    unify_diag(Puzzle),
    validate_row(Puzzle),
    validate_row(PuzzleT),
    ground_vars(Puzzle).
    
%-----------------------------------------------------------------------------
% digit_check(+ListOfLists)
% digit_check/1 is used to ensure that squares of the Puzzle are filled in
% with a single digit between 1 and 9. This predicate takes in the Puzzle,
% i.e. list of lists, omits the first list as it contains the header of each
% column (these will be integers as per assumption 1) and then applies
% digits/1 to each row, to ensure the single digit constraint.

digit_check([_HeaderRow|Rows]) :-
    maplist(digits, Rows).

% digits(+List)
% digits/1 takes in a lists and unpacks the row to obtain the squares (omitting
% the header) and ensures that each element of Row are between 1 and 9. The
% ins/2 function from clpfd is used for this feature.

digits([_Header|Row]) :-
    Row ins 1..9.

%-----------------------------------------------------------------------------
% Constraint 1: each row and each column contains no repeated digits
%
% repeat_check(+ListOfLists)
% repeat_check/1 takes in Puzzle, omits the header row and appplies
% not_repeated/1 to each row and holds when each row contains no repeated
% digits. Notice that when the transposed Puzzle is parsed, not_repeated/1
% ensures that each column of Puzzle contains no repeated digits. Thus
% ensuring whether constraint 1 is satisfied. 

repeat_check([_HeaderRow|Rows]) :-
    maplist(not_repeated, Rows).

% not_repeated(+List)
% not_repeated/1 takes a list, omits the header and holds when each element
% of Row are distinct. The all_distinct/1 function from clpfd is used for
% this feature.

not_repeated([_Header|Row]) :-
    all_distinct(Row).

%-----------------------------------------------------------------------------
% Constraint 2: all squares on the diagonal line from upper left to lower
% right contain the same value
%
% unify_diag(+ListOfLists)
% unify_diag/1 takes the Puzzle, omits the header row, and holds when
% constraint 2 is satisfied. It obtains N which is the number of rows and uses
% unify/4 to unify the diagonal elements to the same value. Notice that the
% unifying variable (X) is parsed as a "don't care" to aviod singleton
% variable warning and it will be unified in the first instance of the unify/4
% predicate call. The built-in length/2 predicate is used for this feature.

unify_diag([_HeaderRow|Rows]) :-
    length(Rows, N),
    unify(Rows, _X, 1, N).

% unify(+ListOfLists, ?X, +I, +N)
% unify/4 takes a list of lists, unifying variable(X), row index (I) and total
% number of rows (N). unify/4 holds when all digonal elements are unified to
% the value/variable X. An arithmetic constraint (between I and N) is initially
% applied to avoid any overflow situations. The built-in nth0/3 predicate is
% used to unify the I-th element of the Row to X. Thus starting at I = 1, when
% iterating through the rows, the diagonal elements will be unified to X.

unify([],_,_,_).
unify([Row|RemRows], X, I, N) :-
    I =< N,
    nth0(I, Row, X),
    Inew is I + 1,
    unify(RemRows, X, Inew, N).

%-----------------------------------------------------------------------------
% Constraint 3 : the heading of reach row and column holds either the sum or
% the product of all the digits in that row or column.
%
% validate_row(+ListOfLists)
% validate_row/1 takes the Puzzle, omits the header row, appplies validate/1
% to each row and holds when the header of each row is the sum or product of
% the elements in that row. Notice that when transpose of Puzzle is parsed,
% the columns of Puzzle will be validated. Thus satisfies constraint 3 

validate_row([_HeaderRow|Rows]) :-
    maplist(validate, Rows).

% validate(+List)
% validate/1 takes in a list and unpacks the Header and remaining elements of
% the row (Row). The predicate holds when the Header is either the sum or
% product of the elements in Row. The first uses the sum/3 predicate from
% clpfd to check if the elements of Row sum to Header. While the second uses
% the product/3 to check if the product of elements in Row is Header.

validate([Header|Row]) :- 
    sum(Row, #=, Header).
validate([Header|Row]) :- 
    product(Row, 1, Header).

% product(+List, +Prod0, ?Prod)
% product/3 takes a list of elements, an accumulator initiated to 1 and the
% product of the elements (Prod). This predicate holds when the accumulator
% calculates the product of all elements in the list and is unified with Prod.

product([], Prod, Prod).
product([Elm|Rem], Prod0, Prod) :-
    Prod1 #= Prod0 * Elm,
    product(Rem, Prod1, Prod).

%-----------------------------------------------------------------------------
% ground_vars(+ListOfLists)
% ground_vars/1 takes the Puzzle, omits the header row and appplies label/1
% from clpfd to each row and holds when all variables are ground. The label/1
% systematically tries out values until all the variables are ground.
% Note: ground/1 would work for a single solution but doesn't hold when
% there are multiple solutions. Thus the ground_vars/1 alternative is used
% to cater to a finite domain of solutions.

ground_vars([_HeaderRow|Rows]) :-
    maplist(label, Rows).