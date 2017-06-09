module VLA.CRM.Account.PostgreSQL
  ( runAccounts
  ) where

import Control.Monad.Error.Class (try)
import Database.PostgreSQL (Connection)
import Data.String.NonEmpty as NES
import Stuff
import VLA.CRM.Account (Account(..), accountEnabled, accountName)
import VLA.CRM.Account.Algebra (Accounts(..))
import VLA.CRM.Account.PostgreSQL.Queries as Q

runAccounts :: ∀ m a. MonadIO m => Connection -> Accounts a -> m a
runAccounts conn (FetchAccount accountID next) = liftIO \ liftAff $ do
  resultE <- try $ Q.fetchAccount conn (Q.FetchAccountIn (unwrap accountID))
  pure \ next $ decode <$> resultE
  where
  decode [Q.FetchAccountOut row] = Account row.enabled <$> NES.fromString row.name
  decode _ = Nothing
runAccounts conn (CreateAccount accountID account next) = liftIO \ liftAff $ do
  map next \ try \ void \ Q.createAccount conn $ Q.CreateAccountIn
    (unwrap accountID)
    (accountEnabled account)
    (accountName account # NES.toString)
runAccounts conn (UpdateAccount accountID account next) = liftIO \ liftAff $ do
  map next \ try \ void \ Q.updateAccount conn $ Q.UpdateAccountIn
    (unwrap accountID)
    (accountEnabled account)
    (accountName account # NES.toString)
