% ===========================================================
% Расставить на клеточном поле всеми возможными способами фишки таким образом,
% чтобы в каждой линии (горизонтальной, вертикальной, диагональной) располагалось
% четное число фишек.
% ===========================================================
% Значения клетки: 0 - пусто, 1 - фишка
val(0).
val(1).

% Проверка списка на четную сумму элементов
is_even(List) :-
    sum_list(List, Sum),
    Sum mod 2 =:= 0.

% Генерация списка заданной длины
gen_list(0, []).
gen_list(N, [H|T]) :-
    N > 0,
    val(H),
    N1 is N - 1,
    gen_list(N1, T).

% -----------------------------------------------------------
% Наивный алгоритм (полный перебор)
% -----------------------------------------------------------

% Генерация матрицы N*N без проверок
gen_matrix_naive(0, _, []).
gen_matrix_naive(Rows, Cols, [Row|Rest]) :-
    Rows > 0,
    gen_list(Cols, Row),
    Rows1 is Rows - 1,
    gen_matrix_naive(Rows1, Cols, Rest).

% Проверка всех ограничений (строки, столбцы, диагонали)
check_all(Matrix) :-
    maplist(is_even, Matrix),
    transpose(Matrix, Cols),
    maplist(is_even, Cols),
    diagonals(Matrix, D1, D2),
    is_even(D1),
    is_even(D2).

% Наивное решение: сначала генерируем, потом проверяем
% Трудоемкость: O(2^(N*N)). Проверка выполняется в листьях дерева поиска.
% Для N=4 перебираются 65536 вариантов.
solve_naive(N, Matrix) :-
    gen_matrix_naive(N, N, Matrix),
    check_all(Matrix).

% -----------------------------------------------------------
% Усовершенствованный алгоритм (с отсечением)
% -----------------------------------------------------------

% Генерация с немедленной проверкой строк
% Ускорение: Если сумма строки нечетная, алгоритм сразу делает откат.
% Это отсекает 50% вариантов на каждом шаге генерации строки.
gen_matrix_smart(0, _, []).
gen_matrix_smart(Rows, Cols, [Row|Rest]) :-
    Rows > 0,
    gen_list(Cols, Row),
    is_even(Row), % Отсечение (Pruning)
    Rows1 is Rows - 1,
    gen_matrix_smart(Rows1, Cols, Rest).

% Оптимизированное решение
solve_improved(N, Matrix) :-
    gen_matrix_smart(N, N, Matrix),
    transpose(Matrix, Cols),
    maplist(is_even, Cols),
    diagonals(Matrix, D1, D2),
    is_even(D1),
    is_even(D2).

% -----------------------------------------------------------
% Вспомогательные предикаты
% -----------------------------------------------------------

% Транспонирование матрицы
transpose([], []).
transpose([F|Fs], Ts) :- 
    transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :- 
    lists_firsts_rests(Ms, Ts, Ms1), 
    transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :- 
    lists_firsts_rests(Rest, Fs, Oss).

% Получение диагоналей матрицы
diagonals(Matrix, D1, D2) :-
    main_diag(Matrix, 0, D1),
    reverse(Matrix, RevM),
    main_diag(RevM, 0, D2).

% Вспомогательный предикат для диагонали
main_diag([], _, []).
main_diag([Row|Rest], I, [X|Dr]) :-
    nth0(I, Row, X),
    I1 is I + 1,
    main_diag(Rest, I1, Dr).

% -----------------------------------------------------------
% Запуск и сравнение
% -----------------------------------------------------------

% Запуск теста с замером времени
run(N) :-
    writeln('--- Naive Algorithm ---'),
    statistics(runtime, [T0|_]),
    (solve_naive(N, M1) -> print_matrix(M1); writeln('No solution')),
    statistics(runtime, [T1|_]),
    Time1 is T1 - T0,
    format('Time: ~w ms~n', [Time1]),
    nl,
    writeln('--- Improved Algorithm ---'),
    statistics(runtime, [T2|_]),
    (solve_improved(N, M2) -> print_matrix(M2); writeln('No solution')),
    statistics(runtime, [T3|_]),
    Time2 is T3 - T2,
    format('Time: ~w ms~n', [Time2]).

% Вывод матрицы на экран
print_matrix([]).
print_matrix([Row|Rest]) :-
    writeln(Row),
    print_matrix(Rest).
