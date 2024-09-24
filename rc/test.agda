module Imp.Stmt.Type where

open import Imp.Expr.Type
open import Base.String.Type
open import Base.Nat.Type
open import Base.Bool.Type
open import Base.U64.Type
open import Base.List.Type

-- Statement type
-- TODO(enricozb): need synchronization primitives (block & global)
data Stmt : Set where
  -- Declares local variables
  Locals : List String → Stmt

  -- Variable Assignments
  LSet : String → Expr → Stmt -- set local variable

  -- TODO(enricozb): the atomic operations don't specify a memory order
  SSet : Nat → Expr → Stmt -- set shared variable atomically
  GSet : Nat → Expr → Stmt -- set global variable atomically

  -- Control Flow
  If     : Expr → Stmt → Stmt
  Else   : Stmt → Stmt
  While  : Expr → Stmt → Stmt
  Ret    : Expr → Stmt
  Cont   : Stmt
  Break  : Stmt

  -- Monadic then (>>)
  Then : Stmt → Stmt → Stmt

  -- Executes an expression and drops the value
  Ignore : Expr → Stmt

  -- Calls a function and assigns it to a variable
  -- If the variable is "_", then the result value of the function is dropped
  Call : String → Stmt → Stmt
