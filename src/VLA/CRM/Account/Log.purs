module VLA.CRM.Account.Log
  ( runAccounts
  ) where

import Stuff
import VLA.CRM.Account.Algebra (Accounts(..))

runAccounts :: ∀ m a. MonadIOSync m => Accounts a -> m Unit
runAccounts (FetchAccount accountID _) = liftIOSync $
  log $ "fetchAccount " <> show accountID
runAccounts (CreateAccount accountID account _) = liftIOSync $
  log $ "createAccount " <> show accountID <> " " <> show account
runAccounts (UpdateAccount accountID account _) = liftIOSync $
  log $ "updateAccount " <> show accountID <> " " <> show account
