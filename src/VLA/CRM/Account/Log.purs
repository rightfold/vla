module VLA.CRM.Account.Log
  ( runAccounts
  ) where

import Stuff
import VLA.CRM.Account.Algebra (Accounts(..))

runAccounts :: ∀ m a. MonadIOSync m => Accounts a -> m Unit
runAccounts (FetchAccount accountID _) = liftIOSync $
  log $ "FetchAccount _ " <> show accountID
runAccounts (UpdateAccount accountID account _) = liftIOSync $
  log $ "UpdateAccount _ " <> show accountID <> " " <> show account
