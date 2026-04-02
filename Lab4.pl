% ===========================================================
% Расставить на клеточном поле всеми возможными способами фишки таким образом,
% чтобы в каждой линии (горизонтальной, вертикальной, диагональной) располагалось
% четное число фишек.
% ===========================================================

; -----------------------------
; ШАБЛОНЫ
; -----------------------------

(deftemplate cell
  (slot row)
  (slot col)
  (slot value)) ; 0 или 1

(deftemplate size
  (slot n))

(deftemplate step
  (slot row)
  (slot col))

(deftemplate solution)
(deftemplate invalid)

; -----------------------------
; НАЧАЛЬНЫЕ ДАННЫЕ
; -----------------------------

(deffacts start
  (size (n 4))        ; размер поля N×N 
  (step (row 0) (col 0))
)

; -----------------------------
; ФУНКЦИЯ ПЕРЕХОДА К СЛЕДУЮЩЕЙ КЛЕТКЕ
; -----------------------------

(deffunction next-step (?r ?c)
  (bind ?n (fact-slot-value (find-fact ((?f size)) TRUE) n))
  (if (< (+ ?c 1) ?n) then
      (assert (step (row ?r) (col (+ ?c 1))))
  else
      (if (< (+ ?r 1) ?n) then
          (assert (step (row (+ ?r 1)) (col 0)))
      else
          (assert (solution))
      )
  )
)

; -----------------------------
; ГЕНЕРАЦИЯ ПЕРЕБОРНЫХ КОМБИНАЦИЙ
; -----------------------------

(defrule generate
  ?s <- (step (row ?r) (col ?c))
  =>
  ; вариант 0
  (assert (cell (row ?r) (col ?c) (value 0)))
  (next-step ?r ?c)

  ; вариант 1
  (assert (cell (row ?r) (col ?c) (value 1)))
  (next-step ?r ?c)

  (retract ?s)
)

; -----------------------------
; ПРОВЕРКА СТРОК
; -----------------------------

(defrule check-rows
  (size (n ?n))
  =>
  (loop-for-count (?i 0 (- ?n 1))
    (bind ?sum 0)
    (do-for-all-facts ((?c cell)) (eq ?c:row ?i)
      (bind ?sum (+ ?sum ?c:value))
    )
    (if (neq (mod ?sum 2) 0) then
        (assert (invalid))
    )
  )
)

; -----------------------------
; ПРОВЕРКА СТОЛБЦОВ
; -----------------------------

(defrule check-cols
  (size (n ?n))
  =>
  (loop-for-count (?j 0 (- ?n 1))
    (bind ?sum 0)
    (do-for-all-facts ((?c cell)) (eq ?c:col ?j)
      (bind ?sum (+ ?sum ?c:value))
    )
    (if (neq (mod ?sum 2) 0) then
        (assert (invalid))
    )
  )
)

; -----------------------------
; ПРОВЕРКА ДИАГОНАЛЕЙ
; -----------------------------

(defrule check-diagonals
  (size (n ?n))
  =>
  (bind ?sum1 0)
  (bind ?sum2 0)
  (do-for-all-facts ((?c cell))
    (if (eq ?c:row ?c:col) then
      (bind ?sum1 (+ ?sum1 ?c:value))
    )
    (if (eq (+ ?c:row ?c:col) (- ?n 1)) then
      (bind ?sum2 (+ ?sum2 ?c:value))
    )
  )
  (if (or (neq (mod ?sum1 2) 0) (neq (mod ?sum2 2) 0)) then
      (assert (invalid))
  )
)

; -----------------------------
; ОТСЕЧЕНИЕ (Pruning)
; -----------------------------

(defrule prune
  ?i <- (invalid)
  =>
  (retract ?i)
  (do-for-all-facts ((?c cell)) TRUE
    (retract ?c)
  )
)

; -----------------------------
; ВЫВОД РЕШЕНИЯ
; -----------------------------

(defrule print-solution
  (solution)
  (not (invalid))
  =>
  (printout t "Solution:" crlf)
  (do-for-all-facts ((?c cell)) TRUE
    (printout t "Row " ?c:row " Col " ?c:col " = " ?c:value crlf)
  )
  (printout t "------------------------" crlf)
)
