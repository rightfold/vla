module VLA.CRM.Account.Dummy
  ( runAccounts
  ) where

import Data.String.NonEmpty (NonEmptyString(..))
import Stuff
import VLA.CRM.Account (Account(..))
import VLA.CRM.Account.Algebra (Accounts(..))

runAccounts :: ∀ m a. Applicative m => Accounts a -> m a
runAccounts (FetchAccount _ next) = pure \ next $ Right (Just account)
runAccounts (CreateAccount _ _ next) = pure \ next $ Right unit
runAccounts (UpdateAccount _ _ next) = pure \ next $ Right unit

account :: Account
account = Account true (NonEmptyString 'A' "CME Inc.")
