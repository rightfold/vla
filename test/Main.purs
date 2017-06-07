module Test.Main
  ( main
  ) where

import Stuff
import Test.Data.UUID as Data.UUID
import Test.Spec.Reporter.Tap (tapReporter)
import Test.Spec.Runner (run)

main :: IOSync Unit
main = liftEff $ run [tapReporter] do
  Data.UUID.spec
