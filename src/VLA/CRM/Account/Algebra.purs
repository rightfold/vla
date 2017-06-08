module VLA.CRM.Account.Algebra
  ( Accounts(..)
  , fetchAccount, fetchAccount'
  , updateAccount, updateAccount'
  ) where

import Control.Monad.Except.Trans (ExceptT)
import Control.Monad.Free (Free, liftF)
import Stuff
import VLA.CRM.Account (Account, AccountID)

data Accounts a
  = FetchAccount (Error \/ Maybe Account -> a) AccountID
  | UpdateAccount (Error \/ Unit -> a) AccountID Account

fetchAccount :: AccountID -> ExceptT Error (Free Accounts) (Maybe Account)
fetchAccount = wrap \ liftF \ FetchAccount id

fetchAccount' :: AccountID -> ExceptT Error (Free Accounts) (Maybe Account)
fetchAccount' = fetchAccount

updateAccount :: AccountID -> Account -> ExceptT Error (Free Accounts) Unit
updateAccount = wrap \\ liftF \\ UpdateAccount id

updateAccount' :: AccountID /\ Account -> ExceptT Error (Free Accounts) Unit
updateAccount' = uncurry updateAccount
