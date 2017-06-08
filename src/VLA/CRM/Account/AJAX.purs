module VLA.CRM.Account.AJAX
  ( runAccounts
  ) where

import Control.Monad.Error.Class (try)
import Control.Monad.Eff.Exception (error)
import Data.Argonaut.Decode.Class (class DecodeJson, decodeJson)
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Network.HTTP.Affjax as AJAX
import Stuff
import VLA.CRM.Account.Algebra (Accounts(..))

runAccounts :: ∀ m a. MonadIO m => Accounts a -> m a
runAccounts (FetchAccount accountID next) =
  next <$> request "http://vbox.example.com:3000/CRM/Account/fetchAccount" accountID
runAccounts (UpdateAccount accountID account next) =
  next <$> request "http://vbox.example.com:3000/CRM/Account/updateAccount" (accountID /\ account)

request :: ∀ m i o. MonadIO m => EncodeJson i => DecodeJson o => String -> i -> m (Either Error o)
request url req = liftIO \ liftAff $ do
  res <- try $ AJAX.post url (encodeJson req)
  pure $ lmap error \ join \ decodeJson \ _.response =<< res
