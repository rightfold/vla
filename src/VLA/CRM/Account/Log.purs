module VLA.CRM.Account.Log
  ( runAccounts
  ) where

import Stuff
import VLA.CRM.Account.Algebra (Accounts(..))

runAccounts :: ∀ m a. MonadIOSync m => Accounts a -> m Unit
runAccounts (FetchAccount _ accountID) = liftIOSync $
  log $ "FetchAccount _ " <> show accountID
runAccounts (UpdateAccount _ accountID account) = liftIOSync $
  log $ "UpdateAccount _ " <> show accountID <> " " <> show account
