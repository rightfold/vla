module Main
  ( main
  ) where

import VLA.CRM.Account.Detail (initialize)
import Stuff

main :: IOSync Unit
main = initialize Nothing
