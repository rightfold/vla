module Main.Client
  ( main
  ) where

import Control.Monad.Free (foldFree)
import Data.UUID (nil)
import Stuff
import VLA.CRM.Account (AccountID(..))
import VLA.CRM.Account.AJAX as Account.AJAX
import VLA.CRM.Account.Detail (initializeForm)

main :: IOSync Unit
main = launchIO $
  initializeForm (foldFree Account.AJAX.runAccounts)
                 (Just (AccountID nil))
